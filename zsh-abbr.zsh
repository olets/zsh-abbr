# abbreviation management for zsh, inspired by fish shell and enhanced
# https://github.com/olets/zsh-abbr
# v3.3.4
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Should `abbr-load` run before every `abbr` command? (default true)
ABBR_AUTOLOAD=${ABBR_AUTOLOAD:-1}

# Log debugging messages?
ABBR_DEBUG=${ABBR_DEBUG:-0}

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
# (default true)
ABBR_DEFAULT_BINDINGS=${ABBR_DEFAULT_BINDINGS:-1}

# Behave as if `--dry-run` was passed? (default false)
ABBR_DRY_RUN=${ABBR_DRY_RUN:-0}

# Behave as if `--force` was passed? (default false)
ABBR_FORCE=${ABBR_FORCE:-0}

# Behave as if `--quiet` was passed? (default false)
ABBR_QUIET=${ABBR_QUIET:-0}

# File abbreviations are stored in
ABBR_USER_ABBREVIATIONS_FILE=${ABBR_USER_ABBREVIATIONS_FILE:-$HOME/.config/zsh/abbreviations}

# FUNCTIONS
# ---------

_abbr() {
  emulate -LR zsh

  {
    local action dry_run error_color force has_error number_opts opt logs \
          output quiet release_date scope should_exit success_color \
          type version warn_color
    dry_run=$ABBR_DRY_RUN
    force=$ABBR_FORCE
    number_opts=0
    quiet=$ABBR_QUIET
    release_date="July 26 2020"
    version="zsh-abbr version 3.3.4"

    if ! (( ${+NO_COLOR} )); then
      error_color="%F{red}"
      success_color="%F{green}"
      warn_color="%F{yellow}"
    fi

    if (( ABBR_LOADING_USER_ABBREVIATIONS )); then
      quiet=1
    fi

    _abbr:add() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr clear-session: Unexpected argument"
        return
      fi

      REGULAR_SESSION_ABBREVIATIONS=()
      GLOBAL_SESSION_ABBREVIATIONS=()
    }

    _abbr:erase() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation
      local abbreviations_sets
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
          if (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && _abbr_echo "  Found a global session abbreviation"
            abbreviations_sets+=( GLOBAL_SESSION_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && _abbr_echo "  Found a regular session abbreviation"
            abbreviations_sets+=( REGULAR_SESSION_ABBREVIATIONS )
          fi
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
          fi

          if (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && _abbr_echo "  Found a global user abbreviation"
            abbreviations_sets+=( GLOBAL_USER_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
          fi

          if (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ABBR_DEBUG )) && _abbr_echo "  Found a regular user abbreviation"
            abbreviations_sets+=( REGULAR_USER_ABBREVIATIONS )
          fi
        fi
      fi

      if ! (( ${#abbreviations_sets} )); then
        _abbr:util_error "abbr erase: No ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` found"
      elif [[ ${#abbreviations_sets} == 1 ]]; then
        verb_phrase="Would erase"

        if ! (( dry_run )); then
          verb_phrase="Erased"
          unset "${abbreviations_sets}[${(b)abbreviation}]" # quotation marks required

          if [[ $abbreviations_sets =~ USER ]]; then
            _abbr:util_sync_user
          fi
        fi

        _abbr:util_log "${success_color}$verb_phrase%f ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\`"
      else
        verb_phrase="Did not erase"
        (( dry_run )) && verb_phrase="Would not erase"

        message="${error_color}$verb_phrase%f abbreviation \`$abbreviation\`. Please specify one of"
        message=$'\n'

        for abbreviations_set in ${abbreviations_sets[@]}; do
          message+="  ${${${abbreviations_set:l}//_/ }//abbreviations/}"
          message=$'\n'
        done

        _abbr:util_error $message
      fi
    }

    _abbr:expand() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local type_saved
      local output_path

      type_saved=$type
      output_path=$1

      if [[ $# > 1 ]]; then
        _abbr:util_error "abbr export-aliases: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="alias"
      user_prefix="alias"

      _abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    _abbr:import_aliases() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
        aliases_to_import=( ${(f)"$(_abbr_alias -r)"} )
        for alias_to_import in $aliases_to_import; do
          _abbr:util_import_alias $alias_to_import
        done
      fi

      if [[ $saved_type != 'regular' ]]; then
        type='global'

        aliases_to_import=( ${(f)"$(_abbr_alias -g)"} )
        for alias_to_import in $aliases_to_import; do
          _abbr:util_import_alias $alias_to_import
        done
      fi

      type=$saved_type
    }

    _abbr:import_fish() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local git_alias
      local git_aliases

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr import-git-aliases: Unexpected argument"
        return
      fi

      typeset -a git_aliases
      git_aliases=( ${(f)"$(git config --get-regexp '^alias\.')"} )

      for git_alias in $git_aliases; do
        key=${${git_alias%% *}#alias.}
        value=${git_alias#* }

        if [[ ${value[1]} == '!' ]]; then
          verb_phrase="was not imported"
          ((dry_run)) && verb_phrase="would not be imported"

          _abbr:util_warn "The Git alias \`$key\` $verb_phrase because its expansion is a function"
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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr list: Unexpected argument"
        return
      fi

      _abbr:util_list
    }

    _abbr:list_commands() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local include_expansion
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

    _abbr:list_abbreviations() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local include_expansion

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr list definitions: Unexpected argument"
        return
      fi

      include_expansion=1

      _abbr:util_list $include_expansion
    }

    _abbr:print_version() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr version: Unexpected argument"
        return
      fi

      _abbr:util_print $version
    }

    _abbr:rename() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
          expansion=${GLOBAL_SESSION_ABBREVIATIONS[$current_abbreviation]}
        else
          expansion=${REGULAR_SESSION_ABBREVIATIONS[$current_abbreviation]}
        fi
      else
        if [[ $type == 'global' ]]; then
          expansion=${GLOBAL_USER_ABBREVIATIONS[$current_abbreviation]}
        else
          expansion=${REGULAR_USER_ABBREVIATIONS[$current_abbreviation]}
        fi
      fi

      if [[ $expansion ]]; then
        _abbr:util_add $new_abbreviation $expansion
        _abbr:erase $current_abbreviation
      else
        _abbr:util_error "abbr rename: No ${type:-regular} ${scope:-user} abbreviation \`$current_abbreviation\` exists"
      fi
    }

    _abbr:util_add() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation
      local cmd
      local expansion
      local job_group
      local success
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
          if ! (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
            fi

            success=1
          fi
        elif ! (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
          _abbr:util_check_command $abbreviation || return

          if ! (( dry_run )); then
            REGULAR_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
          fi

          success=1
        fi
      else
        if [[ $type == 'global' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
          fi

          if ! (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              GLOBAL_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _abbr:util_sync_user
            fi

            success=1
          fi
        else
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
          fi

          if ! (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            _abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              REGULAR_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _abbr:util_sync_user
            fi

            success=1
          fi
        fi
      fi

      if (( success )); then
        verb_phrase="Added"
        (( dry_run )) && verb_phrase="Would add"

        _abbr:util_log "${success_color}$verb_phrase%f the ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\`"
      else
        verb_phrase="was not added"
        (( dry_run )) && verb_phrase="would not be added"

        _abbr:util_error "The ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` $verb_phrase because it already exists"
      fi
    }

    _abbr:util_alias() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation
      local abbreviations_set
      local expansion
      local output_path

      abbreviations_set=$1
      output_path=$2

      for abbreviation in ${(iko)${(P)abbreviations_set}}; do
        alias_definition="alias "
        expansion=${${(P)abbreviations_set}[$abbreviation]}
        if [[ $type == 'global' ]]; then
          alias_definition+="-g "
        fi
        alias_definition+="$abbreviation='$expansion'"

        if [[ $output_path ]]; then
          _abbr_echo "$alias_definition" >> "$output_path"
        else
          print "$alias_definition"
        fi
      done
    }

    _abbr:util_bad_options() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      has_error=1
      logs+=${logs:+$'\n'}"${error_color}$@%f"
      should_exit=1
    }

    _abbr:util_import_alias() {
      local abbreviation
      local expansion

      abbreviation=${1%%=*}
      expansion=${1#*=}

      _abbr:util_add $abbreviation "$(_abbr_echo $expansion)"
    }

    _abbr:util_check_command() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation

      abbreviation=$1

      # Warn if abbreviation would interfere with system command use, e.g. `cp="git cherry-pick"`
      # Apply force to add regardless
      if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
        cmd=$(_abbr_command -v $abbreviation)

        if [[ $cmd && ${cmd:0:6} != 'alias ' ]]; then
          if (( force )); then
            verb_phrase="will now expand"
            (( dry_run )) && verb_phrase="would now expand"

            _abbr:util_log "\`$abbreviation\` $verb_phrase as an abbreviation"
          else
            verb_phrase="was not added"
            (( dry_run )) && verb_phrase="would not be added"

            _abbr:util_warn "The abbreviation \`$abbreviation\` $verb_phrase because a command with the same name exists"
            return 1
          fi
        fi
      fi
    }

    _abbr:util_list() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation
      local expansion
      local include_expansion
      local session_prefix
      local user_prefix

      include_expansion=$1
      session_prefix=$2
      user_prefix=$3

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation in ${(iko)GLOBAL_USER_ABBREVIATIONS}; do
            expansion=${include_expansion:+${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}}
            _abbr:util_list_item $abbreviation $expansion ${user_prefix:+$user_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)REGULAR_USER_ABBREVIATIONS}; do
            expansion=${include_expansion:+${REGULAR_USER_ABBREVIATIONS[$abbreviation]}}
            _abbr:util_list_item $abbreviation $expansion $user_prefix
          done
        fi
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation in ${(iko)GLOBAL_SESSION_ABBREVIATIONS}; do
            expansion=${include_expansion:+${GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}}
            _abbr:util_list_item $abbreviation $expansion ${session_prefix:+$session_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)REGULAR_SESSION_ABBREVIATIONS}; do
            expansion=${include_expansion:+${REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}}
            _abbr:util_list_item $abbreviation $expansion $session_prefix
          done
        fi
      fi
    }

    _abbr:util_list_item() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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

    _abbr:util_log() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      logs+=${logs:+'\n'}"$1"
    }

    _abbr:util_print() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      output+=${output:+'\n'}"$1"
    }

    _abbr:util_set_once() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

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
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      (( ABBR_LOADING_USER_ABBREVIATIONS )) && return

      local abbreviation
      local expansion
      local user_updated

      user_updated=$(mktemp ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations_updated.XXXXXX)

      typeset -p GLOBAL_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      for abbreviation in ${(iko)GLOBAL_USER_ABBREVIATIONS}; do
        expansion=${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
        _abbr_echo "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p REGULAR_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      for abbreviation in ${(iko)REGULAR_USER_ABBREVIATIONS}; do
        expansion=${REGULAR_USER_ABBREVIATIONS[$abbreviation]}
        _abbr_echo "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> $user_updated
      done

      mv $user_updated $ABBR_USER_ABBREVIATIONS_FILE
    }

    _abbr:util_usage() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      _abbr_man abbr 2>/dev/null || _abbr_cat ${ABBR_SOURCE_PATH}/man/abbr.txt | _abbr_less -F
    }

    _abbr:util_warn() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      logs+=${logs:+'\n'}"${warn_color}$@%f"
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
          importing=1
          ;;
        "import-fish")
          _abbr:util_set_once action import_fish
          importing=1
          ;;
        "import-git-aliases")
          _abbr:util_set_once action import_git_aliases
          importing=1
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
        job=$(_abbr_job_name)
        _abbr_job_push $job $action

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
        _abbr:list_abbreviations $@
      fi
    fi

    if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
      _abbr_job_pop $job
    fi

    if ! (( quiet )); then
      if [[ -n $logs ]]; then
        output=$logs${output:+$'\n'$output}
      fi

      if (( dry_run )); then
        output+=$'\n'
        output+="${warn_color}Dry run. Changes not saved.%f"
      fi
    fi

    if [[ -n $has_error ]]; then
      [[ -n $output ]] && _abbr_print -P - $output >&2
      return 1
    else
      [[ -n $output ]] && _abbr_print -P - $output >&1
      return 0
    fi
  }
}

_abbr_bind_widgets() {
  emulate -LR zsh

  (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

  # spacebar expands abbreviations
  zle -N _abbr_expand_and_space
  bindkey " " _abbr_expand_and_space

  # control-spacebar is a normal space
  bindkey "^ " magic-space

  # when running an incremental search,
  # spacebar behaves normally and control-space expands abbreviations
  bindkey -M isearch "^ " _abbr_expand_and_space
  bindkey -M isearch " " magic-space

  # enter key expands and accepts abbreviations
  zle -N _abbr_expand_and_accept
  bindkey "^M" _abbr_expand_and_accept
}

_abbr_cmd_expansion() {
  emulate -LR zsh

  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}

  if [[ ! $expansion ]]; then
    source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
    expansion=${REGULAR_USER_ABBREVIATIONS[$abbreviation]}
  fi

  _abbr_echo - $expansion
}

_abbr_deprecated() {
  emulate -LR zsh
  local message

  message="$1 is deprecated. Please use $2 instead."
  if ! (( ${+NO_COLOR} )); then
    message="%F{yellow}$message%f"
  fi
  _abbr_print $message
}

_abbr_expand_and_accept() {
  emulate -LR zsh

  # do not support debug message

  local trailing_space
  trailing_space=${LBUFFER##*[^[:IFSSPACE:]]}

  if [[ -z $trailing_space ]]; then
    zle _abbr_expand_widget
  fi

  zle accept-line
}

_abbr_expand_and_space() {
  emulate -LR zsh

  # do not support debug message

  zle _abbr_expand_widget
  zle self-insert
}

_abbr_global_expansion() {
  emulate -LR zsh

  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}

  if [[ ! $expansion ]]; then
    source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
    expansion=${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
  fi

  _abbr_echo - $expansion
}

_abbr_init() {
  emulate -LR zsh

  local job

  typeset -gA REGULAR_USER_ABBREVIATIONS
  typeset -gA GLOBAL_USER_ABBREVIATIONS
  typeset -gA REGULAR_SESSION_ABBREVIATIONS
  typeset -gA GLOBAL_SESSION_ABBREVIATIONS

  job=$(_abbr_job_name)
  REGULAR_SESSION_ABBREVIATIONS=()
  GLOBAL_SESSION_ABBREVIATIONS=()

  _abbr_job_push $job initialization
  (( ABBR_DEBUG )) && _abbr_print $funcstack[1]
  _abbr_load_user_abbreviations
  _abbr_job_pop $job
}

_abbr_job_push() {
  emulate -LR zsh

  {
    (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

    local next_job
    local next_job_age
    local next_job_path
    local job_description
    local job_dir
    local job_id
    local job_path
    local timeout_age

    job_id=${(q)1}
    job_description=$2
    job_dir=${TMPDIR:-/tmp/}zsh-abbr/jobs
    job_path=$job_dir/$job_id
    timeout_age=30 # seconds

    function _abbr_job_push:add_job() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      if ! [[ -d $job_dir ]]; then
        mkdir -p $job_dir
      fi

      _abbr_echo $job_description > $job_path
    }

    function _abbr_job_push:next_job_id() {
      # cannout support debug message

      _abbr_ls -t $job_dir | tail -1
    }

    function _abbr_job_push:handle_timeout() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      next_job_path=$job_dir/$next_job

      _abbr_print "abbr: A job added at $(strftime '%T %b %d %Y' ${next_job%.*}) has timed out."
      _abbr_print "The job was related to $(cat $next_job_path)."
      _abbr_print "This could be the result of manually terminating an abbr activity, for example during session startup."
      _abbr_print "If you believe it reflects a abbr bug, please report it at https://github.com/olets/zsh-abbr/issues/new"
      _abbr_print

      rm $next_job_path &>/dev/null
    }

    function _abbr_job_push:wait_turn() {
      while [[ $(_abbr_job_push:next_job_id) != $job_id ]]; do
        next_job=$(_abbr_job_push:next_job_id)
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
    unfunction -m _abbr_job_push:next_job_id
    unfunction -m _abbr_job_push:handle_timeout
    unfunction -m _abbr_job_push:wait_turn
  }
}

_abbr_job_pop() {
  emulate -LR zsh

  (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

  local job

  job=${(q)1}

  rm ${TMPDIR:-/tmp/}zsh-abbr/jobs/$job &>/dev/null
}

_abbr_job_name() {
  emulate -LR zsh

  # cannout support debug message

  _abbr_echo "$(date +%s).$RANDOM"
}

_abbr_load_user_abbreviations() {
  emulate -LR zsh

  {
    (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

    function _abbr_load_user_abbreviations:setup() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      REGULAR_USER_ABBREVIATIONS=()
      GLOBAL_USER_ABBREVIATIONS=()

      if ! [[ -d ${TMPDIR:-/tmp/}zsh-abbr ]]; then
        mkdir -p ${TMPDIR:-/tmp/}zsh-abbr
      fi

      if ! [[ -f ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations ]]; then
        touch ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      fi

      if ! [[ -f ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations ]]; then
        touch ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      fi
    }

    function _abbr_load_user_abbreviations:load() {
      (( ABBR_DEBUG )) && _abbr_print $funcstack[1]

      local abbreviation
      local arguments
      local program
      local shwordsplit_on
      typeset -a user_abbreviations

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

      typeset -p REGULAR_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      typeset -p GLOBAL_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
    }

    ABBR_LOADING_USER_ABBREVIATIONS=1

    _abbr_load_user_abbreviations:setup
    _abbr_load_user_abbreviations:load

    ABBR_LOADING_USER_ABBREVIATIONS=0

    return
  } always {
    unfunction -m _abbr_load_user_abbreviations:setup
    unfunction -m _abbr_load_user_abbreviations:load
  }
}

_abbr_wrap_external_commands() {
  emulate -LR zsh

  _abbr_alias() {
    \builtin \alias $@
  }

  _abbr_cat() {
    \command \cat $@
  }

  _abbr_command() {
    \builtin \command $@
  }

  _abbr_echo() {
    \builtin \echo $@
  }

  _abbr_less() {
    \command \less $@
  }

  _abbr_ls() {
    \command \ls $@
  }

  _abbr_man() {
    \command \man $@
  }

  _abbr_print() {
    \builtin \print $@
  }
}

# WIDGETS
# -------

_abbr_expand_widget() {
  emulate -LR zsh

  local expansion
  local word
  local words
  local word_count

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

zle -N _abbr_expand_widget


# SHARE
# -----

abbr() {
  emulate -LR zsh

  (( ABBR_DEBUG )) && _abbr_print $funcstack[1]
  _abbr $*
}

# DEPRECATION
# -----------


# INITIALIZATION
# --------------

! (( ${+NO_COLOR} )) && autoload -U colors && colors
ABBR_SOURCE_PATH=${0:A:h}
_abbr_wrap_external_commands
_abbr_init
(( $ABBR_DEFAULT_BINDINGS )) &&  _abbr_bind_widgets
