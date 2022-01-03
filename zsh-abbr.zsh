# abbreviation management for zsh, inspired by fish shell and enhanced
# https://github.com/olets/zsh-abbr
# v4.7.1
# Copyright (c) 2019-present Henry Bley-Vroman


# CONFIGURATION
# -------------

# Should `abbr-load` run before every `abbr` command? (default true)
typeset -gi ABBR_AUTOLOAD=${ABBR_AUTOLOAD:-1}

# Log debugging messages?
typeset -gi ABBR_DEBUG=${ABBR_DEBUG:-0}

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
# (default true)
typeset -gi ABBR_DEFAULT_BINDINGS=${ABBR_DEFAULT_BINDINGS:-1}

# Behave as if `--dry-run` was passed? (default false)
typeset -gi ABBR_DRY_RUN=${ABBR_DRY_RUN:-0}

# Behave as if `--force` was passed? (default false)
typeset -gi ABBR_FORCE=${ABBR_FORCE:-0}

# Enable logging after commands, for example to warn that a deprecated widget was used?
typeset -gi ABBR_PRECMD_LOGS=${ABBR_PRECMD_LOGS:-1}

# Behave as if `--quiet` was passed? (default false)
typeset -gi ABBR_QUIET=${ABBR_QUIET:-0}

# Behave as if `--quieter` was passed? (default false)
typeset -gi ABBR_QUIETER=${ABBR_QUIETER:-0}

# Temp files are stored in
typeset -g ABBR_TMPDIR=${ABBR_TMPDIR:-${${TMPDIR:-/tmp}%/}/zsh-abbr/}

# File abbreviations are stored in
typeset -g ABBR_USER_ABBREVIATIONS_FILE=${ABBR_USER_ABBREVIATIONS_FILE:-$HOME/.config/zsh/abbreviations}

# FUNCTIONS
# ---------

_abbr() {
  emulate -LR zsh

  {
    local action error_color job_name logs_silent_when_quiet logs_silent_when_quieter \
      opt output release_date scope success_color type version warn_color
    local -i dry_run force has_error number_opts quiet quieter should_exit

    dry_run=$ABBR_DRY_RUN
    force=$ABBR_FORCE
    number_opts=0
    quiet=$ABBR_QUIET
    quiet=$(( ABBR_QUIETER || ABBR_QUIET ))
    quieter=$ABBR_QUIETER
    release_date="January 3 2022"
    version="zsh-abbr version 4.7.1"

    # Deprecation notices for values that could be meaningfully set after initialization
    # Example form:
    # (( ${+DEPRECATED_VAL} )) && _abbr_warn_deprecation DEPRECATED_VAL VAL
    # VAL=$DEPRECATED_VAL

    if (( ABBR_LOADING_USER_ABBREVIATIONS )); then
      quiet=1
      quieter=1
    elif ! _abbr_no_color; then
      error_color="$fg[red]"
      success_color="$fg[green]"
      warn_color="$fg[yellow]"
    fi

    _abbr:add() {
      _abbr_debugger

      local abbreviation
      local expansion

      if [[ $# > 1 ]]; then
        _abbr:util_error "abbr add: Expected one argument, got $#: $*"
        return
      fi

      abbreviation=${1%%=*}
      expansion=${1#*=}

      if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
        abbreviation=${(q)abbreviation}
        expansion=${(q)expansion}
      fi

      if ! [[ $abbreviation && $expansion && $abbreviation != $1 ]]; then
        _abbr:util_error "abbr add: Requires abbreviation and expansion"
        return
      fi

      _abbr:util_add $abbreviation $expansion
    }

    _abbr:clear_session() {
      _abbr_debugger

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr clear-session: Unexpected argument"
        return
      fi

      ABBR_REGULAR_SESSION_ABBREVIATIONS=()
      ABBR_GLOBAL_SESSION_ABBREVIATIONS=()
    }

    _abbr:erase() {
      _abbr_debugger

      local abbreviation
      local -a abbreviations_sets
      local message
      local verb_phrase

      if [[ $# > 1 ]]; then
        _abbr:util_error "abbr erase: Expected one argument"
        return
      elif [[ $# < 1 ]]; then
        _abbr:util_error "abbr erase: Erase needs a variable name"
        return
      fi

      abbreviation=$1
      abbreviations_sets=()

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          if (( ${+ABBR_GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a global session abbreviation"
            abbreviations_sets+=( ABBR_GLOBAL_SESSION_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if (( ${+ABBR_REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a regular session abbreviation"
            abbreviations_sets+=( ABBR_REGULAR_SESSION_ABBREVIATIONS )
          fi
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${ABBR_TMPDIR}global-user-abbreviations
          fi

          if (( ${+ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a global user abbreviation"
            abbreviations_sets+=( ABBR_GLOBAL_USER_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${ABBR_TMPDIR}regular-user-abbreviations
          fi

          if (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a regular user abbreviation"
            abbreviations_sets+=( ABBR_REGULAR_USER_ABBREVIATIONS )
          fi
        fi
      fi

      if ! (( ${#abbreviations_sets} )); then
        _abbr:util_error "abbr erase: No${type:+ $type}${scope:+ $scope} abbreviation \`$abbreviation\` found"
      elif [[ ${#abbreviations_sets} == 1 ]]; then
        verb_phrase="Would erase"

        if ! (( dry_run )); then
          verb_phrase="Erased"
          unset "${abbreviations_sets}[${(b)abbreviation}]" # quotation marks required

          if [[ $abbreviations_sets =~ USER ]]; then
            _abbr:util_sync_user
          fi
        fi

        _abbr:util_log_unless_quiet "$success_color$verb_phrase$reset_color $(_abbr:util_set_to_typed_scope $abbreviations_sets) \`$abbreviation\`"
      else
        verb_phrase="Did not erase"
        (( dry_run )) && verb_phrase="Would not erase"

        message="$error_color$verb_phrase$reset_color abbreviation \`$abbreviation\`. Please specify one of\\n"

        for abbreviations_set in $abbreviations_sets; do
          message+="  $(_abbr:util_set_to_typed_scope $abbreviations_set)\\n"
        done

        _abbr:util_error $message
      fi
    }

    _abbr:expand() {
      _abbr_debugger

      local abbreviation
      local expansion

      abbreviation=$1

      if [[ $# != 1 ]]; then
        _abbr:util_error "abbr expand: requires exactly one argument"
        return
      fi

      expansion=$(_abbr_cmd_expansion "$abbreviation")

      if [[ ! "$expansion" ]]; then
        expansion=$(_abbr_global_expansion "$abbreviation")
      fi
      _abbr:util_print "${(Q)expansion}"
    }

    _abbr:export_aliases() {
      _abbr_debugger

      local type_saved

      type_saved=$type

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr export-aliases: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="alias"
      user_prefix="alias"

      _abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    _abbr:import_aliases() {
      _abbr_debugger

      local alias_to_import
      local abbreviation
      local expansion
      local saved_type

      typeset -a aliases_to_import

      saved_type=$type

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr import-aliases: Unexpected argument"
        return
      fi

      if [[ $saved_type != 'global' ]]; then
        aliases_to_import=( ${(f)"$('builtin' 'alias' -r)"} )
        for alias_to_import in $aliases_to_import; do
          _abbr:util_import_alias $alias_to_import
        done
      fi

      if [[ $saved_type != 'regular' ]]; then
        type='global'

        aliases_to_import=( ${(f)"$('builtin' 'alias' -g)"} )
        for alias_to_import in $aliases_to_import; do
          _abbr:util_import_alias $alias_to_import
        done
      fi

      type=$saved_type
    }

    _abbr:import_fish() {
      _abbr_debugger

      local abbreviation
      local abbreviations
      local expansion
      local input_file

      if [[ $# != 1 ]]; then
        _abbr:util_error "abbr import-fish: requires exactly one argument"
        return
      fi

      input_file=$1
      abbreviations=( ${(f)"$(<$input_file)"} )

      for abbreviation in $abbreviations; do
        def=${line#* -- }
        abbreviation=${def%% *}
        expansion=${def#* }

        _abbr:util_add $abbreviation $expansion
      done
    }

    _abbr:import_git_aliases() {
      _abbr_debugger

      local config_file
      local git_alias
      local -a git_aliases

      if [[ ($# != 0 && $# != 2) || ($# == 2 && $1 != "--file") ]]; then
        _abbr:util_error "abbr import-git-aliases: Unexpected argument"
        return
      fi

      if [[ -n $1 ]]; then
        config_file=$2

        if [[ ! -f $config_file ]]; then
          _abbr:util_error "abbr import-git-aliases: Config file not found"
          return
        fi

        git_aliases=( ${(ps|\nalias.|)"$(git config --file $config_file --get-regexp '^alias\.')"} )
      else
        git_aliases=( ${(ps|\nalias.|)"$(git config --get-regexp '^alias\.')"} )
      fi

      for git_alias in $git_aliases; do
        key=${${git_alias%% *}#alias.}
        value=${git_alias#* }

        if [[ ${value[1]} == '!' ]]; then
          verb_phrase="Did not"
          ((dry_run)) && verb_phrase="Would not"

          _abbr:util_warn "$verb_phrase import the Git alias \`$key\` because its expansion is a function"
        else
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            key=${(q)key}
            value=${(q)value}
          fi

          type="global"
          _abbr:util_add "g$key" "git $value"

          type="regular"
          _abbr:util_add "$key" "git $value"
        fi
      done
    }

    _abbr:list() {
      _abbr_debugger

      local -i include_expansion

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr list definitions: Unexpected argument"
        return
      fi

      include_expansion=1

      _abbr:util_list $include_expansion
    }

    _abbr:list_abbreviations() {
      _abbr_debugger

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr list: Unexpected argument"
        return
      fi

      _abbr:util_list
    }

    _abbr:list_commands() {
      _abbr_debugger

      local -i include_expansion
      local session_prefix
      local user_prefix

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr list commands: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="abbr -S"
      user_prefix=abbr

      _abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    _abbr:print_version() {
      _abbr_debugger

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr version: Unexpected argument"
        return
      fi

      _abbr:util_print $version
    }

    _abbr:rename() {
      _abbr_debugger

      local err
      local expansion
      local new
      local old

      if [[ $# != 2 ]]; then
        _abbr:util_error "abbr rename: Requires exactly two arguments"
        return
      fi

      current_abbreviation=$1
      new_abbreviation=$2
      job_group='_abbr:rename'

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          expansion=${ABBR_GLOBAL_SESSION_ABBREVIATIONS[$current_abbreviation]}
        else
          expansion=${ABBR_REGULAR_SESSION_ABBREVIATIONS[$current_abbreviation]}
        fi
      else
        if [[ $type == 'global' ]]; then
          expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[$current_abbreviation]}
        else
          expansion=${ABBR_REGULAR_USER_ABBREVIATIONS[$current_abbreviation]}
        fi
      fi

      if [[ $expansion ]]; then
        _abbr:util_add $new_abbreviation $expansion
        _abbr:erase $current_abbreviation
      else
        _abbr:util_error "abbr rename: No${type:+ $type}${scope:+ $scope} abbreviation \`$current_abbreviation\` exists"
      fi
    }

    _abbr:util_add() {
      _abbr_debugger

      local abbreviation
      local cmd
      local expansion
      local job_group
      local -a success
      local typed_scope
      local verb_phrase

      abbreviation=$1
      expansion=$2
      success=0

      if [[ ${(w)#abbreviation} > 1 ]]; then
        _abbr:util_error "abbr add: ABBREVIATION (\`$abbreviation\`) must be only one word"
        return
      fi

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        _abbr:util_error "abbr add: ABBREVIATION (\`$abbreviation\`) may not contain an equals sign"
        return
      fi

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          typed_scope=$(_abbr:util_set_to_typed_scope ABBR_GLOBAL_SESSION_ABBREVIATIONS)

          if ! (( ${+ABBR_GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              ABBR_GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
            fi

            success=1
          fi
        else
          typed_scope=$(_abbr:util_set_to_typed_scope ABBR_REGULAR_SESSION_ABBREVIATIONS)

          if ! (( ${+ABBR_REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              ABBR_REGULAR_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
            fi

            success=1
          fi
        fi
      else
        if [[ $type == 'global' ]]; then
          typed_scope=$(_abbr:util_set_to_typed_scope ABBR_GLOBAL_USER_ABBREVIATIONS)

          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${ABBR_TMPDIR}global-user-abbreviations
          fi

          if ! (( ${+ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _abbr:util_sync_user
            fi

            success=1
          fi
        else
          typed_scope=$(_abbr:util_set_to_typed_scope ABBR_REGULAR_USER_ABBREVIATIONS)

          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${ABBR_TMPDIR}regular-user-abbreviations
          fi

          if ! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return
            typed_scope=$(_abbr:util_set_to_typed_scope ABBR_REGULAR_USER_ABBREVIATIONS)

            if ! (( dry_run )); then
              ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _abbr:util_sync_user
            fi

            success=1
          fi
        fi
      fi

      if (( success )); then
        verb_phrase="Added"
        (( dry_run )) && verb_phrase="Would add"

        _abbr:util_log_unless_quiet "$success_color$verb_phrase$reset_color the $typed_scope \`$abbreviation\`"
      else
        verb_phrase="Did not"
        (( dry_run )) && verb_phrase="Would not"

        _abbr:util_error "$verb_phrase add the $typed_scope \`$abbreviation\` because it already exists"
      fi
    }

    _abbr:util_alias() {
      _abbr_debugger

      local abbreviation
      local abbreviations_set
      local expansion

      abbreviations_set=$1

      for abbreviation in ${(iko)${(P)abbreviations_set}}; do
        expansion=${${(P)abbreviations_set}[$abbreviation]}

        alias_definition="alias "
        if [[ $type == 'global' ]]; then
          alias_definition+="-g "
        fi
        alias_definition+="$abbreviation='$expansion'"

        'builtin' 'print' "$alias_definition"
      done
    }

    _abbr:util_bad_options() {
      _abbr_debugger

      _abbr:util_error "abbr: Illegal combination of options"
    }

    _abbr:util_deprecated() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local message
      local new
      local old

      old=$1
      new=$2

      message="$1 is deprecated and will be dropped in a future version."

      if [[ $new ]]; then
        message+=" Please use $new instead."
      fi

      _abbr:util_warn $message
    }

    _abbr:util_error() {
      _abbr_debugger

      has_error=1
      logs_silent_when_quiet+="${logs_silent_when_quiet:+\\n}$error_color$@$reset_color"
      should_exit=1
    }

    _abbr:util_import_alias() {
      local abbreviation
      local expansion

      abbreviation=${1%%=*}
      expansion=${1#*=}

      _abbr:util_add $abbreviation "$('builtin' 'echo' $expansion)"
    }

    _abbr:util_check_command() {
      _abbr_debugger

      local abbreviation

      abbreviation=$1

      (( ABBR_LOADING_USER_ABBREVIATIONS )) && return 0

      (( force && quieter )) && return 0

      # Warn if abbreviation would interfere with system command use, e.g. `cp="git cherry-pick"`
      # Apply force to add regardless
      cmd=$('builtin' 'command' -v $abbreviation)

      if [[ $cmd && ${cmd:0:6} != 'alias ' ]]; then
        if (( force )); then
          verb_phrase="will now expand"
          (( dry_run )) && verb_phrase="would now expand"

          _abbr:util_log_unless_quieter "\`$abbreviation\` $verb_phrase as an abbreviation"
        else
          verb_phrase="Did not"
          (( dry_run )) && verb_phrase="Would not"

          _abbr:util_warn "$verb_phrase add the abbreviation \`$abbreviation\` because a command with the same name exists"
          return 1
        fi
      fi
    }

    _abbr:util_list() {
      _abbr_debugger

      local abbreviation
      local expansion
      local -i include_expansion
      local session_prefix
      local user_prefix

      include_expansion=$1
      session_prefix=$2
      user_prefix=$3

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation in ${(iko)ABBR_GLOBAL_USER_ABBREVIATIONS}; do
            (( include_expansion )) && expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
            _abbr:util_list_item $abbreviation $expansion ${user_prefix:+$user_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)ABBR_REGULAR_USER_ABBREVIATIONS}; do
            (( include_expansion )) && expansion=${ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]}
            _abbr:util_list_item $abbreviation $expansion $user_prefix
          done
        fi
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation in ${(iko)ABBR_GLOBAL_SESSION_ABBREVIATIONS}; do
            (( include_expansion )) && expansion=${ABBR_GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}
            _abbr:util_list_item $abbreviation $expansion ${session_prefix:+$session_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)ABBR_REGULAR_SESSION_ABBREVIATIONS}; do
            (( include_expansion )) && expansion=${ABBR_REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}
            _abbr:util_list_item $abbreviation $expansion $session_prefix
          done
        fi
      fi
    }

    _abbr:util_list_item() {
      _abbr_debugger

      local abbreviation
      local expansion
      local prefix

      abbreviation=$1
      expansion=$2
      prefix=$3

      result=$abbreviation

      if [[ $expansion ]]; then
        result+="=${(qqq)${(Q)expansion}}"
      fi

      if [[ $prefix ]]; then
        result="$prefix $result"
      fi

      _abbr:util_print $result
    }

    _abbr:util_log_unless_quiet() {
      _abbr_debugger

      logs_silent_when_quiet+="${logs_silent_when_quiet:+\\n}$1"
    }

    _abbr:util_log_unless_quieter() {
      _abbr_debugger

      logs_silent_when_quieter+="${logs_silent_when_quieter:+\\n}$1"
    }

    _abbr:util_print() {
      _abbr_debugger

      output+="${output:+\\n}$1"
    }

    _abbr:util_set_once() {
      _abbr_debugger

      local option value

      option=$1
      value=$2

      if [[ ${(P)option} ]]; then
        return
      fi

      eval $option=$value
      ((number_opts++))
    }

    _abbr:util_sync_user() {
      _abbr_debugger

      (( ABBR_LOADING_USER_ABBREVIATIONS )) && return

      local abbreviation
      local expansion
      local user_updated

      user_updated=$(mktemp ${ABBR_TMPDIR}regular-user-abbreviations_updated.XXXXXX)

      typeset -p ABBR_GLOBAL_USER_ABBREVIATIONS > ${ABBR_TMPDIR}global-user-abbreviations
      for abbreviation in ${(iko)ABBR_GLOBAL_USER_ABBREVIATIONS}; do
        expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
        'builtin' 'echo' "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p ABBR_REGULAR_USER_ABBREVIATIONS > ${ABBR_TMPDIR}regular-user-abbreviations
      for abbreviation in ${(iko)ABBR_REGULAR_USER_ABBREVIATIONS}; do
        expansion=${ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]}
        'builtin' 'echo' "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> $user_updated
      done

      mv $user_updated $ABBR_USER_ABBREVIATIONS_FILE
    }

    _abbr:util_set_to_typed_scope() {
      _abbr_debugger

      local abbreviations_set
      abbreviations_set=$1

      'builtin' 'echo' ${${${${abbreviations_set:l}%s}#abbr_}//_/ }
    }

    _abbr:util_usage() {
      _abbr_debugger

      'command' 'man' abbr 2>/dev/null || 'command' 'man' ${ABBR_SOURCE_PATH}/man/man1/abbr.1
    }

    _abbr:util_warn() {
      _abbr_debugger

      logs_silent_when_quiet+="${logs_silent_when_quiet:+\\n}$warn_color$@$reset_color"
    }

    for opt in "$@"; do
      if (( should_exit )); then
        return
      fi

      case $opt in
        "add"|\
        "a")
          _abbr:util_set_once action add
          ;;
        "clear-session"|\
        "c")
          _abbr:util_set_once action clear_session
          ;;
        "--dry-run")
          dry_run=1
          ((number_opts++))
          ;;
        "erase"|\
        "e")
          _abbr:util_set_once action erase
          ;;
        "expand"|\
        "x")
          _abbr:util_set_once action expand
          ;;
        "export-aliases")
          _abbr:util_set_once action export_aliases
          ;;
        "--force"|\
        "-f")
          force=1
          ((number_opts++))
          ;;
        "--global"|\
        "-g")
          _abbr:util_set_once type global
          ;;
        "help"|\
        "--help")
          _abbr:util_usage
          should_exit=1
          ;;
        "import-aliases")
          _abbr:util_set_once action import_aliases
          ;;
        "import-fish")
          _abbr:util_set_once action import_fish
          ;;
        "import-git-aliases")
          _abbr:util_set_once action import_git_aliases
          ;;
        "list")
          _abbr:util_set_once action list
          ;;
        "list-abbreviations"|\
        "l")
          _abbr:util_set_once action list_abbreviations
          ;;
        "list-commands"|\
        "L"|\
        "-L")
          # -L option is to match the builtin alias's `-L`
          _abbr:util_set_once action list_commands
          ;;
        "load")
          _abbr_load_user_abbreviations
          should_exit=1
          ;;
        "--quiet"|\
        "-q")
          quiet=1
          ((number_opts++))
          ;;
        "--quieter"|\
        "-qq")
          quiet=1
          quieter=1
          ((number_opts++))
          ;;
        "--regular"|\
        "-r")
          _abbr:util_set_once type regular
          ;;
        "rename"|\
        "R")
          _abbr:util_set_once action rename
          ;;
        "--session"|\
        "-S")
          _abbr:util_set_once scope session
          ;;
        "--user"|\
        "-U")
          _abbr:util_set_once scope user
          ;;
        "version"|\
        "--version"|\
        "-v")
          _abbr:util_set_once action print_version
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if ! (( should_exit )); then
      shift $number_opts

      if ! (( ABBR_LOADING_USER_ABBREVIATIONS )) && [[ $scope != 'session' ]]; then
        job_name=$(_abbr_job_name)
        _abbr_job_push $job_name $action

        if (( ABBR_AUTOLOAD )); then
          _abbr_load_user_abbreviations
        fi
      fi

      if [[ $action ]]; then
        _abbr:$action $@
      elif [[ $# > 0 ]]; then
        # default if arguments are provided
        _abbr:add $@
      else
        # default if no argument is provided
        _abbr:list $@
      fi
    fi

    if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
      _abbr_job_pop $job_name
    fi

    if ! (( quiet )); then
      if [[ -n $logs_silent_when_quiet ]]; then
        output=$logs_silent_when_quiet${output:+\\n$output}
      fi
    fi

    if ! (( quieter )); then
      if [[ -n $logs_silent_when_quieter ]]; then
        output=$logs_silent_when_quieter${output:+\\n$output}
      fi
    fi

    if (( has_error )); then
      [[ -n $output ]] && 'builtin' 'echo' - $output >&2
      return 1
    else
      if (( dry_run && ! ABBR_TESTING )); then
        output+="\\n${warn_color}Dry run. Changes not saved.$reset_color"
      fi

      [[ -n $output ]] && 'builtin' 'echo' - $output >&1
      return 0
    fi
  }
}

_abbr_add_widgets() {
  emulate -LR zsh

  _abbr_debugger

  zle -N abbr-expand _abbr_widget_expand
  zle -N abbr-expand-and-accept _abbr_widget_expand_and_accept
  zle -N abbr-expand-and-space _abbr_widget_expand_and_space

  zle -N _abbr_widget_expand
  zle -N _abbr_widget_expand_and_accept
  zle -N _abbr_widget_expand_and_space
}

_abbr_bind_widgets() {
  emulate -LR zsh

  _abbr_debugger

  # spacebar expands abbreviations
  bindkey " " _abbr_widget_expand_and_space

  # control-spacebar is a normal space
  bindkey "^ " magic-space

  # when running an incremental search,
  # spacebar behaves normally and control-space expands abbreviations
  bindkey -M isearch "^ " _abbr_widget_expand_and_space
  bindkey -M isearch " " magic-space

  # enter key expands and accepts abbreviations
  bindkey "^M" _abbr_widget_expand_and_accept
}

_abbr_no_color() {
  local -a shell_vars
  local -i found

  shell_vars=( ${(k)parameters} )

  found=$(( ! $shell_vars[(Ie)NO_COLOR] ))

  return $found
}

_abbr_cmd_expansion() {
  emulate -LR zsh

  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${ABBR_REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}

  if [[ ! $expansion ]]; then
    _abbr_create_files
    source ${ABBR_TMPDIR}regular-user-abbreviations
    expansion=${ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]}
  fi

  'builtin' 'echo' - $expansion
}

_abbr_create_files() {
  emulate -LR zsh

  _abbr_debugger

  [[ -d $ABBR_TMPDIR ]] || mkdir -p $ABBR_TMPDIR

  [[ -f ${ABBR_TMPDIR}regular-user-abbreviations ]] || touch ${ABBR_TMPDIR}regular-user-abbreviations

  [[ -f ${ABBR_TMPDIR}global-user-abbreviations ]] || touch ${ABBR_TMPDIR}global-user-abbreviations
}

_abbr_debugger() {
  emulate -LR zsh

  # user abbreviations are loaded on every git subcommand, making noise
  (( ABBR_LOADING_USER_ABBREVIATIONS && ! ABBR_INITIALIZING )) && return

  (( ABBR_DEBUG )) && 'builtin' 'echo' - $funcstack[2]
}

_abbr_global_expansion() {
  emulate -LR zsh

  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${ABBR_GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}

  if [[ ! $expansion ]]; then
    _abbr_create_files
    source ${ABBR_TMPDIR}global-user-abbreviations
    expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
  fi

  'builtin' 'echo' - $expansion
}

_abbr_init() {
  emulate -LR zsh

  local job_name

  typeset -gA ABBR_GLOBAL_SESSION_ABBREVIATIONS
  typeset -gA ABBR_GLOBAL_USER_ABBREVIATIONS
  typeset -gi ABBR_INITIALIZING
  typeset -g ABBR_PRECMD_MESSAGE
  typeset -gA ABBR_REGULAR_SESSION_ABBREVIATIONS
  typeset -gA ABBR_REGULAR_USER_ABBREVIATIONS

  ABBR_INITIALIZING=1
  ABBR_PRECMD_MESSAGE=
  ABBR_REGULAR_SESSION_ABBREVIATIONS=()
  ABBR_GLOBAL_SESSION_ABBREVIATIONS=()

  job_name=$(_abbr_job_name)

  if ! _abbr_no_color; then
    'builtin' 'autoload' -U colors && colors
  fi

  _abbr_job_push $job_name initialization
  _abbr_debugger

  'builtin' 'autoload' -Uz add-zsh-hook
  add-zsh-hook precmd _abbr_precmd

  _abbr_load_user_abbreviations
  _abbr_add_widgets
  _abbr_deprecations
  (( ABBR_DEFAULT_BINDINGS )) &&  _abbr_bind_widgets

  _abbr_job_pop $job_name
  unset ABBR_INITIALIZING
}

_abbr_job_pop() {
  emulate -LR zsh

  _abbr_debugger

  local job_name

  job_name=$1

  'command' 'rm' ${ABBR_TMPDIR}jobs/$job_name &>/dev/null
}

_abbr_job_push() {
  emulate -LR zsh

  {
    _abbr_debugger

    local next_job
    local next_job_age
    local next_job_path
    local job_description
    local job_name
    local job_path
    local timeout_age

    job_name=$1
    job_description=$2
    timeout_age=30 # seconds

    function _abbr_job_push:add_job() {
      _abbr_debugger

      if ! [[ -d ${ABBR_TMPDIR}jobs ]]; then
        mkdir -p ${ABBR_TMPDIR}jobs
      fi

      'builtin' 'echo' $job_description > ${ABBR_TMPDIR}jobs/$job_name
    }

    function _abbr_job_push:next_job_name() {
      # cannout support debug message

      'command' 'ls' -t ${ABBR_TMPDIR}jobs | tail -1
    }

    function _abbr_job_push:handle_timeout() {
      _abbr_debugger

      next_job_path=${ABBR_TMPDIR}jobs/$next_job

      'builtin' 'echo' "abbr: A job added at $(strftime '%T %b %d %Y' ${next_job%.*}) has timed out."
      'builtin' 'echo' "The job was related to $(cat $next_job_path)."
      'builtin' 'echo' "This could be the result of manually terminating an abbr activity, for example during session startup."
      'builtin' 'echo' "If you believe it reflects a abbr bug, please report it at https://github.com/olets/zsh-abbr/issues/new"
      'builtin' 'echo'

      'command' 'rm' $next_job_path &>/dev/null
    }

    function _abbr_job_push:wait_turn() {
      while [[ $(_abbr_job_push:next_job_name) != $job_name ]]; do
        next_job=$(_abbr_job_push:next_job_name)
        next_job_age=$(( $(date +%s) - ${next_job%.*} ))

        if ((  $next_job_age > $timeout_age )); then
          _abbr_job_push:handle_timeout
        fi

        sleep 0.01
      done
    }

    _abbr_job_push:add_job
    _abbr_job_push:wait_turn
  } always {
    unfunction -m _abbr_job_push:add_job
    unfunction -m _abbr_job_push:next_job_name
    unfunction -m _abbr_job_push:handle_timeout
    unfunction -m _abbr_job_push:wait_turn
  }
}

_abbr_job_name() {
  emulate -LR zsh

  # cannout support debug message

  'builtin' 'echo' "$(date +%s).$RANDOM"
}

_abbr_load_user_abbreviations() {
  emulate -LR zsh

  {
    _abbr_debugger

    function _abbr_load_user_abbreviations:setup() {
      _abbr_debugger

      ABBR_REGULAR_USER_ABBREVIATIONS=()
      ABBR_GLOBAL_USER_ABBREVIATIONS=()

      _abbr_create_files
    }

    function _abbr_load_user_abbreviations:load() {
      _abbr_debugger

      local abbreviation
      local arguments
      local program
      local -i shwordsplit_on
      typeset -a user_abbreviations

      typeset -gi ABBR_LOADING_USER_ABBREVIATIONS

      shwordsplit_on=0

      if [[ $options[shwordsplit] = on ]]; then
        shwordsplit_on=1
      fi

      # Load saved user abbreviations
      if [[ -f $ABBR_USER_ABBREVIATIONS_FILE ]]; then
        unsetopt shwordsplit

        user_abbreviations=( ${(f)"$(<$ABBR_USER_ABBREVIATIONS_FILE)"} )

        for abbreviation in $user_abbreviations; do
          program="${abbreviation%% *}"
          arguments="${abbreviation#* }"

          # Only execute abbr commands
          if [[ $program == "abbr" && $program != $abbreviation ]]; then
            abbr ${(z)arguments}
          fi
        done

        if (( shwordsplit_on )); then
          setopt shwordsplit
        fi
        unset shwordsplit_on
      else
        mkdir -p ${ABBR_USER_ABBREVIATIONS_FILE:A:h}
        touch $ABBR_USER_ABBREVIATIONS_FILE
      fi

      typeset -p ABBR_REGULAR_USER_ABBREVIATIONS > ${ABBR_TMPDIR}regular-user-abbreviations
      typeset -p ABBR_GLOBAL_USER_ABBREVIATIONS > ${ABBR_TMPDIR}global-user-abbreviations
    }

    ABBR_LOADING_USER_ABBREVIATIONS=1
    _abbr_load_user_abbreviations:setup
    _abbr_load_user_abbreviations:load
    unset ABBR_LOADING_USER_ABBREVIATIONS
    return
  } always {
    unfunction -m _abbr_load_user_abbreviations:setup
    unfunction -m _abbr_load_user_abbreviations:load
  }
}

_abbr_precmd() {
  emulate -LR zsh

  # do not support debug message

  (( ABBR_PRECMD_LOGS )) || return

  if [[ -n $ABBR_PRECMD_MESSAGE ]]; then
    'builtin' 'print' -P $ABBR_PRECMD_MESSAGE
    ABBR_PRECMD_MESSAGE=
  fi
}

# WIDGETS
# -------

_abbr_widget_expand() {
  emulate -LR zsh

  local expansion
  local word
  local words
  local -i word_count

  words=(${(z)LBUFFER})
  word=$words[-1]
  word_count=${#words}

  if [[ $word_count == 1 ]]; then
    expansion=$(_abbr_cmd_expansion $word)
  fi

  if [[ ! $expansion ]]; then
    expansion=$(_abbr_global_expansion $word)
  fi

  if [[ -n $expansion ]]; then
    local preceding_lbuffer
    preceding_lbuffer=${LBUFFER%%$word}
    LBUFFER=$preceding_lbuffer${(Q)expansion}
  fi
}

_abbr_widget_expand_and_accept() {
  emulate -LR zsh

  # do not support debug message

  local trailing_space
  trailing_space=${LBUFFER##*[^[:IFSSPACE:]]}

  if [[ -z $trailing_space ]]; then
    zle _abbr_widget_expand
  fi

  'builtin' 'command' -v _zsh_autosuggest_clear &>/dev/null && _zsh_autosuggest_clear

  zle accept-line
}

_abbr_widget_expand_and_space() {
  emulate -LR zsh

  _abbr_widget_expand
  zle self-insert
}


# SHARE
# -----

abbr() {
  emulate -LR zsh

  _abbr_debugger
  _abbr $*
}

# DEPRECATION
# -----------

_abbr_deprecations() {
  {
    emulate -LR zsh

    _abbr_debugger

    # Deprecation notices for values that could not be meaningfully set after initialization
    # Example form:
    # (( ${+DEPRECATED_VAL} )) && _abbr_warn_deprecation DEPRECATED_VAL VAL
    # VAL=$DEPRECATED_VAL

    # Deprecation notices for functions
    # Example form:
    # deprecated_fn() {
    #   _abbr_warn_deprecation deprecated_fn fn
    #   fn
    # }

    # Deprecation notices for zle widgets
    _abbr_deprecations:widgets() {
      _abbr_debugger

      local bindkey_declaration
      local bindkey_declarations
      local replacement
      local deprecated
      local -A deprecated_widgets

      bindkey_declarations=$(bindkey)

      for deprecated replacement in ${(kv)deprecated_widgets}; do
        bindkey_declaration=$('builtin' 'echo' $bindkey_declarations | grep $deprecated)

        zle -N $deprecated

        if [[ -n $bindkey_declaration ]]; then
          _abbr_warn_deprecation $deprecated $replacement "bindkey $bindkey_declaration"
        fi
      done
    }

    _abbr_deprecations:widgets
  } always {
    unfunction -m _abbr_deprecations:widgets
  }
}

_abbr_warn_deprecation() {
  emulate -LR zsh

  _abbr_debugger

  local callstack
  local deprecated
  local message
  local replacement

  deprecated=$1
  replacement=$2
  callstack=$3

  message="$deprecated is deprecated. Please use $replacement instead."

  if [[ -n $callstack ]]; then
    message+="\\n${warn_color}Called by \`$callstack\`$reset_color"
  fi

  'builtin' 'print' -P $message
}

# INITIALIZATION
# --------------

typeset -g ABBR_SOURCE_PATH
ABBR_SOURCE_PATH=${0:A:h}
_abbr_init
