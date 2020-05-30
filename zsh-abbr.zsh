# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v3.3.1
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Should `abbr-load` run before every `abbr` command? (default true)
ZSH_ABBR_AUTOLOAD=${ZSH_ABBR_AUTOLOAD:-1}

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
# (default true)
ZSH_ABBR_DEFAULT_BINDINGS=${ZSH_ABBR_DEFAULT_BINDINGS:-1}

# Behave as if `--dry-run` was passed? (default false)
ZSH_ABBR_DRY_RUN=${ZSH_ABBR_DRY_RUN:-0}

# Behave as if `--force` was passed? (default false)
ZSH_ABBR_FORCE=${ZSH_ABBR_FORCE:-0}

# Behave as if `--quiet` was passed? (default false)
ZSH_ABBR_QUIET=${ZSH_ABBR_QUIET:-0}

# File abbreviations are stored in
ZSH_ABBR_USER_PATH=${ZSH_ABBR_USER_PATH=${HOME}/.config/zsh/abbreviations}


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action dry_run force has_error number_opts opt logs output \
          quiet release_date scope should_exit text_bold text_reset \
          type version
    dry_run=$ZSH_ABBR_DRY_RUN
    force=$ZSH_ABBR_FORCE
    number_opts=0
    quiet=$ZSH_ABBR_QUIET
    release_date="May 11 2020"
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    version="zsh-abbr version 3.3.0"

    if (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
      quiet=1
    fi

    _zsh_abbr:add() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation
      local expansion

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error "abbr add: Expected one argument, got $#: $*"
        return
      fi

      abbreviation=${1%%=*}
      expansion=${1#*=}

      if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
        abbreviation=${(q)abbreviation}
        expansion=${(q)expansion}
      fi

      if ! [[ $abbreviation && $expansion && $abbreviation != $1 ]]; then
        _zsh_abbr:util_error "abbr add: Requires abbreviation and expansion"
        return
      fi

      _zsh_abbr:util_add $abbreviation $expansion
    }

    _zsh_abbr:clear_session() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr clear-session: Unexpected argument"
        return
      fi

      REGULAR_SESSION_ABBREVIATIONS=()
      GLOBAL_SESSION_ABBREVIATIONS=()
    }

    _zsh_abbr:erase() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation
      local abbreviations_sets
      local message
      local verb_phrase

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error "abbr erase: Expected one argument"
        return
      elif [[ $# < 1 ]]; then
        _zsh_abbr:util_error "abbr erase: Erase needs a variable name"
        return
      fi

      abbreviation=$1
      abbreviations_sets=()

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          if (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo "  Found a global session abbreviation"
            abbreviations_sets+=( GLOBAL_SESSION_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo "  Found a regular session abbreviation"
            abbreviations_sets+=( REGULAR_SESSION_ABBREVIATIONS )
          fi
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
          fi

          if (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo "  Found a global user abbreviation"
            abbreviations_sets+=( GLOBAL_USER_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
          fi

          if (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo "  Found a regular user abbreviation"
            abbreviations_sets+=( REGULAR_USER_ABBREVIATIONS )
          fi
        fi
      fi

      if ! (( ${#abbreviations_sets} )); then
        _zsh_abbr:util_error "abbr erase: No ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` found"
      elif [[ ${#abbreviations_sets} == 1 ]]; then
        verb_phrase="Would erase"

        if ! (( dry_run )); then
          verb_phrase="Erased"
          unset "${abbreviations_sets}[${(b)abbreviation}]" # quotation marks required

          if [[ $abbreviations_sets =~ USER ]]; then
            _zsh_abbr:util_sync_user
          fi
        fi

        _zsh_abbr:util_log "$fg[green]$verb_phrase$reset_color ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\`"
      else
        verb_phrase="Did not erase"
        (( dry_run )) && verb_phrase="Would not erase"

        message="$fg[red]$verb_phrase$reset_color abbreviation \`$abbreviation\`. Please specify one of\\n"

        for abbreviations_set in ${abbreviations_sets[@]}; do
          message+="  ${${${abbreviations_set:l}//_/ }//abbreviations/}\\n"
        done

        _zsh_abbr:util_error $message
      fi
    }

    _zsh_abbr:expand() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation
      local expansion

      abbreviation=$1

      if [[ $# != 1 ]]; then
        _zsh_abbr:util_error "abbr expand: requires exactly one argument"
        return
      fi

      expansion=$(_zsh_abbr_cmd_expansion "$abbreviation")

      if [ ! "$expansion" ]; then
        expansion=$(_zsh_abbr_global_expansion "$abbreviation")
      fi
      _zsh_abbr:util_print "${(Q)expansion}"
    }

    _zsh_abbr:export_aliases() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local type_saved
      local output_path

      type_saved=$type
      output_path=$1

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error "abbr export-aliases: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="alias"
      user_prefix="alias"

      _zsh_abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    _zsh_abbr:import_aliases() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local alias_to_import
      local abbreviation
      local expansion
      local saved_type

      typeset -a aliases_to_import

      saved_type=$type

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr import-aliases: Unexpected argument"
        return
      fi

      if [[ $saved_type != 'global' ]]; then
        aliases_to_import=( ${(f)"$(_zsh_abbr_alias -r)"} )
        for alias_to_import in $aliases_to_import; do
          _zsh_abbr:util_import_alias $alias_to_import
        done
      fi

      if [[ $saved_type != 'regular' ]]; then
        type='global'

        aliases_to_import=( ${(f)"$(_zsh_abbr_alias -g)"} )
        for alias_to_import in $aliases_to_import; do
          _zsh_abbr:util_import_alias $alias_to_import
        done
      fi

      type=$saved_type
    }

    _zsh_abbr:import_fish() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation
      local abbreviations
      local expansion
      local input_file

      if [[ $# != 1 ]]; then
        _zsh_abbr:util_error "abbr import-fish: requires exactly one argument"
        return
      fi

      input_file=$1
      abbreviations=( ${(f)"$(<$input_file)"} )

      for abbreviation in $abbreviations; do
        def=${line#* -- }
        abbreviation=${def%% *}
        expansion=${def#* }

        _zsh_abbr:util_add $abbreviation $expansion
      done
    }

    _zsh_abbr:import_git_aliases() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local git_alias
      local git_aliases

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr import-git-aliases: Unexpected argument"
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

          _zsh_abbr:util_warn "The Git alias \`$key\` $verb_phrase because its expansion is a function"
        else
          if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
            key=${(q)key}
            value=${(q)value}
          fi

          type="global"
          _zsh_abbr:util_add "g$key" "git $value"

          type="regular"
          _zsh_abbr:util_add "$key" "git $value"
        fi
      done
    }

    _zsh_abbr:list() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr list: Unexpected argument"
        return
      fi

      _zsh_abbr:util_list
    }

    _zsh_abbr:list_commands() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local include_expansion
      local session_prefix
      local user_prefix

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr list commands: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="abbr -S"
      user_prefix=abbr

      _zsh_abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    _zsh_abbr:list_abbreviations() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local include_expansion

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr list definitions: Unexpected argument"
        return
      fi

      include_expansion=1

      _zsh_abbr:util_list $include_expansion
    }

    _zsh_abbr:print_version() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error "abbr version: Unexpected argument"
        return
      fi

      _zsh_abbr:util_print $version
    }

    _zsh_abbr:rename() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local err
      local expansion
      local new
      local old

      if [[ $# != 2 ]]; then
        _zsh_abbr:util_error "abbr rename: Requires exactly two arguments"
        return
      fi

      current_abbreviation=$1
      new_abbreviation=$2
      job_group='_zsh_abbr:rename'

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

      if [ $expansion ]; then
        _zsh_abbr:util_add $new_abbreviation $expansion
        _zsh_abbr:erase $current_abbreviation
      else
        _zsh_abbr:util_error "abbr rename: No ${type:-regular} ${scope:-user} abbreviation \`$current_abbreviation\` exists"
      fi
    }

    _zsh_abbr:util_add() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

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
        _zsh_abbr:util_error "abbr add: ABBREVIATION (\`$abbreviation\`) must be only one word"
        return
      fi

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        _zsh_abbr:util_error "abbr add: ABBREVIATION (\`$abbreviation\`) may not contain an equals sign"
        return
      fi

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          if ! (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            _zsh_abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
            fi

            success=1
          fi
        elif ! (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
          _zsh_abbr:util_check_command $abbreviation || return

          if ! (( dry_run )); then
            REGULAR_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
          fi

          success=1
        fi
      else
        if [[ $type == 'global' ]]; then
          if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
          fi

          if ! (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            _zsh_abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              GLOBAL_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _zsh_abbr:util_sync_user
            fi

            success=1
          fi
        else
          if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
          fi

          if ! (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            _zsh_abbr:util_check_command $abbreviation || return

            if ! (( dry_run )); then
              REGULAR_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _zsh_abbr:util_sync_user
            fi

            success=1
          fi
        fi
      fi

      if (( success )); then
        verb_phrase="Added"
        (( dry_run )) && verb_phrase="Would add"

        _zsh_abbr:util_log "$fg[green]$verb_phrase$reset_color the ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\`"
      else
        verb_phrase="was not added"
        (( dry_run )) && verb_phrase="would not be added"

        _zsh_abbr:util_error "The ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` $verb_phrase because it already exists"
      fi
    }

    _zsh_abbr:util_alias() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

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

        if [ $output_path ]; then
          _zsh_abbr_echo "$alias_definition" >> "$output_path"
        else
          print "$alias_definition"
        fi
      done
    }

    _zsh_abbr:util_bad_options() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      _zsh_abbr:util_error "abbr: Illegal combination of options"
    }

    _zsh_abbr:util_error() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      has_error=1
      logs+="${logs:+\\n}$fg[red]$@$reset_color"
      should_exit=1
    }

    _zsh_abbr:util_import_alias() {
      local abbreviation
      local expansion

      abbreviation=${1%%=*}
      expansion=${1#*=}

      _zsh_abbr:util_add $abbreviation "$(_zsh_abbr_echo $expansion)"
    }

    _zsh_abbr:util_check_command() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation

      abbreviation=$1

      # Warn if abbreviation would interfere with system command use, e.g. `cp="git cherry-pick"`
      # Apply force to add regardless
      if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
        cmd=$(_zsh_abbr_command -v $abbreviation)

        if [[ $cmd && ${cmd:0:6} != 'alias ' ]]; then
          if (( force )); then
            verb_phrase="will now expand"
            (( dry_run )) && verb_phrase="would now expand"

            _zsh_abbr:util_log "\`$abbreviation\` $verb_phrase as an abbreviation"
          else
            verb_phrase="was not added"
            (( dry_run )) && verb_phrase="would not be added"

            _zsh_abbr:util_warn "The abbreviation \`$abbreviation\` $verb_phrase because a command with the same name exists"
            return 1
          fi
        fi
      fi
    }

    _zsh_abbr:util_list() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

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
            _zsh_abbr:util_list_item $abbreviation $expansion ${user_prefix:+$user_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)REGULAR_USER_ABBREVIATIONS}; do
            expansion=${include_expansion:+${REGULAR_USER_ABBREVIATIONS[$abbreviation]}}
            _zsh_abbr:util_list_item $abbreviation $expansion $user_prefix
          done
        fi
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation in ${(iko)GLOBAL_SESSION_ABBREVIATIONS}; do
            expansion=${include_expansion:+${GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}}
            _zsh_abbr:util_list_item $abbreviation $expansion ${session_prefix:+$session_prefix -g}
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation in ${(iko)REGULAR_SESSION_ABBREVIATIONS}; do
            expansion=${include_expansion:+${REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}}
            _zsh_abbr:util_list_item $abbreviation $expansion $session_prefix
          done
        fi
      fi
    }

    _zsh_abbr:util_list_item() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local abbreviation
      local expansion
      local prefix

      abbreviation=$1
      expansion=$2
      prefix=$3

      result=$abbreviation

      if [ $expansion ]; then
        result+="=${(qqq)${(Q)expansion}}"
      fi

      if [ $prefix ]; then
        result="$prefix $result"
      fi

      _zsh_abbr:util_print $result
    }

    _zsh_abbr:util_log() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      logs+="${logs:+\\n}$1"
    }

    _zsh_abbr:util_print() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      output+="${output:+\\n}$1"
    }

    _zsh_abbr:util_set_once() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      local option value

      option=$1
      value=$2

      if [ ${(P)option} ]; then
        _zsh_abbr:util_bad_options
        return
      fi

      eval $option=$value
      ((number_opts++))
    }

    _zsh_abbr:util_sync_user() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )) && return

      local abbreviation
      local expansion
      local user_updated

      user_updated=$(mktemp ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations_updated.XXXXXX)

      typeset -p GLOBAL_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      for abbreviation in ${(iko)GLOBAL_USER_ABBREVIATIONS}; do
        expansion=${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
        _zsh_abbr_echo "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p REGULAR_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      for abbreviation in ${(iko)REGULAR_USER_ABBREVIATIONS}; do
        expansion=${REGULAR_USER_ABBREVIATIONS[$abbreviation]}
        _zsh_abbr_echo "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> $user_updated
      done

      mv $user_updated $ZSH_ABBR_USER_PATH
    }

    _zsh_abbr:util_usage() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      _zsh_abbr_man abbr 2>/dev/null || _zsh_abbr_cat ${ZSH_ABBR_SOURCE_PATH}/man/abbr.txt | _zsh_abbr_less -F
    }

    _zsh_abbr:util_warn() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      has_error=1
      logs+="${logs:+\\n}$fg[yellow]$@$reset_color"
    }

    for opt in "$@"; do
      if (( should_exit )); then
        return
      fi

      case "$opt" in
        "--add"|\
        "-a")
          _zsh_abbr:util_set_once action add
          ;;
        "--clear-session"|\
        "-c")
          _zsh_abbr:util_set_once action clear_session
          ;;
        "--dry-run")
          dry_run=1
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          _zsh_abbr:util_set_once action erase
          ;;
        "--expand"|\
        "-x")
          _zsh_abbr:util_set_once action expand
          ;;
        "--export-aliases")
          _zsh_abbr:util_set_once action export_aliases
          ;;
        "--force"|\
        "-f")
          force=1
          ((number_opts++))
          ;;
        "--global"|\
        "-g")
          _zsh_abbr:util_set_once type global
          ;;
        "--help"|\
        "-h")
          _zsh_abbr:util_usage
          should_exit=1
          ;;
        "--import-aliases")
          _zsh_abbr:util_set_once action import_aliases
          importing=1
          ;;
        "--import-fish")
          _zsh_abbr:util_set_once action import_fish
          importing=1
          ;;
        "--import-git-aliases")
          _zsh_abbr:util_set_once action import_git_aliases
          importing=1
          ;;
        "--list")
          _zsh_abbr:util_set_once action list
          ;;
        "--list-abbreviations"|\
        "-l")
          _zsh_abbr:util_set_once action list_abbreviations
          ;;
        "--list-commands"|\
        "-L"|\
        "--show"|\
        "-s") # "show" is for backwards compatability with v2
          _zsh_abbr:util_set_once action list_commands
          ;;
        "--quiet"|\
        "-q")
          quiet=1
          ((number_opts++))
          ;;
        "--regular"|\
        "-r")
          _zsh_abbr:util_set_once type regular
          ;;
        "--rename"|\
        "-R")
          _zsh_abbr:util_set_once action rename
          ;;
        "--session"|\
        "-S")
          _zsh_abbr:util_set_once scope session
          ;;
        "--user"|\
        "-U")
          _zsh_abbr:util_set_once scope user
          ;;
        "--version"|\
        "-v")
          _zsh_abbr:util_set_once action print_version
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if ! (( should_exit )); then
      shift $number_opts

      if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )) && [[ $scope != 'session' ]]; then
        job=$(_zsh_abbr_job_name)
        _zsh_abbr_job_push $job $action

        if (( ZSH_ABBR_AUTOLOAD )); then
          _zsh_abbr_load_user_abbreviations
        fi
      fi

      if [ $action ]; then
        _zsh_abbr:$action $@
      elif [[ $# > 0 ]]; then
        # default if arguments are provided
        _zsh_abbr:add $@
      else
        # default if no argument is provided
        _zsh_abbr:list_abbreviations $@
      fi
    fi

    if ! (( ZSH_ABBR_LOADING_USER_ABBREVIATIONS )); then
      _zsh_abbr_job_pop $job
    fi

    if ! (( quiet )); then
      if [[ -n $logs ]]; then
        output=$logs${output:+\\n$output}
      fi

      if (( dry_run )); then
        logs+="\\n$fg[yellow]Dry run. Changes not saved.$reset_color"
      fi
    fi

    if [[ -n $has_error ]]; then
      [[ -n $output ]] && _zsh_abbr_echo - $output >&2
      return 1
    else
      [[ -n $output ]] && _zsh_abbr_echo - $output >&1
      return 0
    fi
  }
}

_zsh_abbr_bind_widgets() {
  (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

  # spacebar expands abbreviations
  zle -N _zsh_abbr_expand_and_space
  bindkey " " _zsh_abbr_expand_and_space

  # control-spacebar is a normal space
  bindkey "^ " magic-space

  # when running an incremental search,
  # spacebar behaves normally and control-space expands abbreviations
  bindkey -M isearch "^ " _zsh_abbr_expand_and_space
  bindkey -M isearch " " magic-space

  # enter key expands and accepts abbreviations
  zle -N _zsh_abbr_expand_and_accept
  bindkey "^M" _zsh_abbr_expand_and_accept
}

_zsh_abbr_cmd_expansion() {
  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${REGULAR_SESSION_ABBREVIATIONS[$abbreviation]}

  if [ ! $expansion ]; then
    source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
    expansion=${REGULAR_USER_ABBREVIATIONS[$abbreviation]}
  fi

  _zsh_abbr_echo - $expansion
}

_zsh_abbr_expand_and_accept() {
  # do not support debug message

  local trailing_space
  trailing_space=${LBUFFER##*[^[:IFSSPACE:]]}

  if [[ -z $trailing_space ]]; then
    zle _zsh_abbr_expand_widget
  fi

  zle accept-line
}

_zsh_abbr_expand_and_space() {
  # do not support debug message

  zle _zsh_abbr_expand_widget
  zle self-insert
}

_zsh_abbr_global_expansion() {
  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation=$1
  expansion=${GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]}

  if [ ! $expansion ]; then
    source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
    expansion=${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
  fi

  _zsh_abbr_echo - $expansion
}

_zsh_abbr_init() {
  {
    (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

    local job

    typeset -gA REGULAR_USER_ABBREVIATIONS
    typeset -gA GLOBAL_USER_ABBREVIATIONS
    typeset -gA REGULAR_SESSION_ABBREVIATIONS
    typeset -gA GLOBAL_SESSION_ABBREVIATIONS

    function _zsh_abbr_init:clean() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      # clean up deprecated temp files

      if [ -d ${TMPDIR:-/tmp/}zsh-abbr-jobs ]; then
        rm -rf ${TMPDIR:-/tmp/}zsh-abbr-jobs 2> /dev/null
      fi

      if [ -f ${TMPDIR:-/tmp/}zsh-user-global-abbreviations ]; then
        rm ${TMPDIR:-/tmp/}zsh-user-global-abbreviations 2> /dev/null
      fi

      if [ -f ${TMPDIR:-/tmp/}zsh-user-abbreviations ]; then
        rm ${TMPDIR:-/tmp/}zsh-user-abbreviations 2> /dev/null
      fi

      if [ -f ${TMPDIR:-/tmp/}zsh-abbr-initializing ]; then
        rm ${TMPDIR:-/tmp/}zsh-abbr-initializing
      fi

      if [ -f ${TMPDIR:-/tmp/}abbr_universals ]; then
        rm ${TMPDIR:-/tmp/}abbr_universals
      fi
    }

    job=$(_zsh_abbr_job_name)
    _zsh_abbr_job_push $job initialization
    _zsh_abbr_init:clean
    _zsh_abbr_load_user_abbreviations

    _zsh_abbr_job_pop $job
  } always {
    unfunction -m _zsh_abbr_init:clean
  }
}

_zsh_abbr_job_push() {
  {
    (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

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

    function _zsh_abbr_job_push:add_job() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      if ! [ -d $job_dir ]; then
        mkdir -p $job_dir
      fi

      _zsh_abbr_echo $job_description > $job_path
    }

    function _zsh_abbr_job_push:next_job_id() {
      # cannout support debug message

      _zsh_abbr_ls -t $job_dir | tail -1
    }

    function _zsh_abbr_job_push:handle_timeout() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      next_job_path=$job_dir/$next_job

      _zsh_abbr_echo "abbr: A job added at $(strftime '%T %b %d %Y' ${next_job%.*}) has timed out."
      _zsh_abbr_echo "The job was related to $(cat $next_job_path)."
      _zsh_abbr_echo "This could be the result of manually terminating an zsh-abbr activity, for example during session startup."
      _zsh_abbr_echo "If you believe it reflects a zsh-abbr bug, please report it at https://github.com/olets/zsh-abbr/issues/new"
      _zsh_abbr_echo

      rm $next_job_path &>/dev/null
    }

    function _zsh_abbr_job_push:wait_turn() {
      while [[ $(_zsh_abbr_job_push:next_job_id) != $job_id ]]; do
        next_job=$(_zsh_abbr_job_push:next_job_id)
        next_job_age=$(( $(date +%s) - ${next_job%.*} ))

        if ((  $next_job_age > $timeout_age )); then
          _zsh_abbr_job_push:handle_timeout
        fi

        sleep 0.01
      done
    }

    _zsh_abbr_job_push:add_job
    _zsh_abbr_job_push:wait_turn
  } always {
    unfunction -m _zsh_abbr_job_push:add_job
    unfunction -m _zsh_abbr_job_push:next_job_id
    unfunction -m _zsh_abbr_job_push:handle_timeout
    unfunction -m _zsh_abbr_job_push:wait_turn
  }
}

_zsh_abbr_job_pop() {
  (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

  local job

  job=${(q)1}

  rm ${TMPDIR:-/tmp/}zsh-abbr/jobs/$job &>/dev/null
}

_zsh_abbr_job_name() {
  # cannout support debug message

  _zsh_abbr_echo "$(date +%s).$RANDOM"
}

_zsh_abbr_load_user_abbreviations() {
  {
    (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

    function _zsh_abbr_load_user_abbreviations:setup() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

      REGULAR_SESSION_ABBREVIATIONS=()
      GLOBAL_SESSION_ABBREVIATIONS=()
      REGULAR_USER_ABBREVIATIONS=()
      GLOBAL_USER_ABBREVIATIONS=()

      if ! [ -d ${TMPDIR:-/tmp/}zsh-abbr ]; then
        mkdir -p ${TMPDIR:-/tmp/}zsh-abbr
      fi

      if ! [ -f ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations ]; then
        touch ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      fi

      if ! [ -f ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations ]; then
        touch ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      fi
    }

    function _zsh_abbr_load_user_abbreviations:load() {
      (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]

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
      if [ -f $ZSH_ABBR_USER_PATH ]; then
        unsetopt shwordsplit

        user_abbreviations=( ${(f)"$(<$ZSH_ABBR_USER_PATH)"} )

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
        mkdir -p ${ZSH_ABBR_USER_PATH:A:h}
        touch $ZSH_ABBR_USER_PATH
      fi

      typeset -p REGULAR_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      typeset -p GLOBAL_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
    }

    ZSH_ABBR_LOADING_USER_ABBREVIATIONS=1

    _zsh_abbr_load_user_abbreviations:setup
    _zsh_abbr_load_user_abbreviations:load

    ZSH_ABBR_LOADING_USER_ABBREVIATIONS=0

    return
  } always {
    unfunction -m _zsh_abbr_load_user_abbreviations:setup
    unfunction -m _zsh_abbr_load_user_abbreviations:load
  }
}

_zsh_abbr_wrap_external_commands() {
  _zsh_abbr_alias() {
    \builtin \alias $@
  }

  _zsh_abbr_cat() {
    \command \cat $@
  }

  _zsh_abbr_command() {
    \builtin \command $@
  }

  _zsh_abbr_echo() {
    \builtin \echo $@
  }

  _zsh_abbr_less() {
    \command \less $@
  }

  _zsh_abbr_ls() {
    \command \ls $@
  }

  _zsh_abbr_man() {
    \command \man $@
  }
}

# WIDGETS
# -------

_zsh_abbr_expand_widget() {
  local expansion
  local word
  local words
  local word_count

  words=(${(z)LBUFFER})
  word=$words[-1]
  word_count=${#words}

  if [[ $word_count == 1 ]]; then
    expansion=$(_zsh_abbr_cmd_expansion $word)
  fi

  if [ ! $expansion ]; then
    expansion=$(_zsh_abbr_global_expansion $word)
  fi

  if [[ -n $expansion ]]; then
    local preceding_lbuffer
    preceding_lbuffer=${LBUFFER%%$word}
    LBUFFER=$preceding_lbuffer${(Q)expansion}
  fi
}

zle -N _zsh_abbr_expand_widget


# SHARE
# -----

abbr() {
  (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]
  _zsh_abbr $*
}

abbr-load() {
  (( ZSH_ABBR_DEBUG )) && _zsh_abbr_echo $funcstack[1]
  _zsh_abbr_load_user_abbreviations

  local job

  job=$(_zsh_abbr_job_name)

  _zsh_abbr_job_push $job $funcstack[1]
  _zsh_abbr_load_user_abbreviations

  _zsh_abbr_job_pop $job
}


# INITIALIZATION
# --------------

autoload -U colors && colors
ZSH_ABBR_SOURCE_PATH=${0:A:h}
_zsh_abbr_wrap_external_commands
_zsh_abbr_init
if (( $ZSH_ABBR_DEFAULT_BINDINGS )) || [ $ZSH_ABBR_DEFAULT_BINDINGS = true ]; then
  _zsh_abbr_bind_widgets
fi
