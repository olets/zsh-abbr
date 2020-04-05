# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v3.1.2
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=1}"

# File abbreviations are stored in
ZSH_ABBR_USER_PATH="${ZSH_ABBR_USER_PATH="${HOME}/.config/zsh/abbreviations"}"


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action number_opts opt dry_run release_date scope should_exit \
          text_bold text_reset type version
    dry_run=0
    number_opts=0
    release_date="March 22 2020"
    should_exit=0
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    version="zsh-abbr version 3.1.2"

    function _zsh_abbr:add() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:add"

      local abbreviation
      local expansion

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error " add: Expected one argument, got $#: $*"
        return
      fi

      abbreviation=${1%%=*}
      expansion=${1#*=}
      if ! (( ZSH_ABBR_INITIALIZING )); then
        abbreviation=${(q)abbreviation}
        expansion=${(q)expansion}
      fi

      if ! [[ $abbreviation && $expansion && $abbreviation != $1 ]]; then
        _zsh_abbr:util_error " add: Requires abbreviation and expansion"
        return
      fi

      _zsh_abbr:util_add $abbreviation $expansion
    }

    function _zsh_abbr:clear_session() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:clear_session"

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " clear-session: Unexpected argument"
        return
      fi

      REGULAR_SESSION_ABBREVIATIONS=()
      GLOBAL_SESSION_ABBREVIATIONS=()
    }

    function _zsh_abbr:erase() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:erase"

      local abbreviation
      local abbreviations_sets
      local message

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error " erase: Expected one argument"
        return
      elif [[ $# < 1 ]]; then
        _zsh_abbr:util_error " erase: Erase needs a variable name"
        return
      fi

      abbreviation=$1
      abbreviations_sets=()

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          if (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && echo "  Found a global session abbreviation"
            abbreviations_sets+=( GLOBAL_SESSION_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && echo "  Found a regular session abbreviation"
            abbreviations_sets+=( REGULAR_SESSION_ABBREVIATIONS )
          fi
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          source "${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations"

          if (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && echo "  Found a global user abbreviation"
            abbreviations_sets+=( GLOBAL_USER_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          source "${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations"

          if (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            (( ZSH_ABBR_DEBUG )) && echo "  Found a regular user abbreviation"
            abbreviations_sets+=( REGULAR_USER_ABBREVIATIONS )
          fi
        fi
      fi

      if ! (( ${#abbreviations_sets} )); then
        _zsh_abbr:util_error " erase: No ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` found"
      elif [[ ${#abbreviations_sets} == 1 ]]; then
        if (( dry_run )); then
          echo "Erase ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\`"
        else
          unset "${abbreviations_sets}[${(b)abbreviation}]" # quotation marks required

          if [[ $abbreviations_sets =~ USER ]]; then
            _zsh_abbr:util_sync_user
          fi
        fi
      else
        message=" erase: Multiple abbreviations \`$abbreviation\`. Please specify one of\\n"

        for abbreviations_set in ${abbreviations_sets[@]}; do
          message+="  ${${${abbreviations_set:l}//_/ }//abbreviations/}\\n"
        done

        _zsh_abbr:util_error $message
      fi
    }

    function _zsh_abbr:expand() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:expand"

      local abbreviation
      local expansion

      abbreviation=$1

      if [[ $# != 1 ]]; then
        echo "expand requires exactly one argument"
        return
      fi

      expansion=$(_zsh_abbr_cmd_expansion "$abbreviation")

      if [ ! "$expansion" ]; then
        expansion=$(_zsh_abbr_global_expansion "$abbreviation")
      fi

      echo - "${(Q)expansion}"
    }

    function _zsh_abbr:export_aliases() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:export_aliases"

      local type_saved
      local output_path

      type_saved=$type
      output_path=$1

      if [[ $# > 1 ]]; then
        _zsh_abbr:util_error " export-aliases: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="alias"
      user_prefix="alias"

      _zsh_abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    function _zsh_abbr:import_aliases() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:import_aliases"

      local _alias

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " import-aliases: Unexpected argument"
        return
      fi

      while read -r _alias; do
        add $_alias
      done < <(alias -r)

      type='global'

      while read -r _alias; do
        add $_alias
      done < <(alias -g)

      if ! (( dry_run )); then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function _zsh_abbr:import_fish() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:import_fish"

      local abbreviation
      local expansion
      local input_file

      if [[ $# != 1 ]]; then
        echo "expand requires exactly one argument"
        return
      fi

      input_file=$1

      while read -r line; do
        def=${line#* -- }
        abbreviation=${def%% *}
        expansion=${def#* }

        _zsh_abbr:util_add $abbreviation $expansion
      done < $input_file

      if ! (( dry_run )); then
        echo "Abbreviations imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function _zsh_abbr:import_git_aliases() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:import_git_aliases"

      local git_aliases
      local abbr_git_aliases

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " import-git-aliases: Unexpected argument"
        return
      fi

      git_aliases=(${(@f)$(git config --get-regexp '^alias\.')})
      typeset -A abbr_git_aliases

      for git_alias in $git_aliases; do
        key=${$(echo - $git_alias | awk '{print $1;}')##alias.}
        value=${$(echo - $git_alias)##alias.$key }

        _zsh_abbr:util_add "g$key" "git ${value# }"
      done

      if ! (( dry_run )); then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function _zsh_abbr:list() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:list"

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " list: Unexpected argument"
        return
      fi

      _zsh_abbr:util_list
    }

    function _zsh_abbr:list_commands() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:list_commands"

      local include_expansion
      local session_prefix
      local user_prefix

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " list commands: Unexpected argument"
        return
      fi

      include_expansion=1
      session_prefix="abbr -S"
      user_prefix=abbr

      _zsh_abbr:util_list $include_expansion $session_prefix $user_prefix
    }

    function _zsh_abbr:list_abbreviations() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:list_abbreviations"

      local include_expansion

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " list definitions: Unexpected argument"
        return
      fi

      include_expansion=1

      _zsh_abbr:util_list $include_expansion
    }

    function _zsh_abbr:print_version() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:print_version"

      if [[ $# > 0 ]]; then
        _zsh_abbr:util_error " version: Unexpected argument"
        return
      fi

      echo $version
    }

    function _zsh_abbr:rename() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:rename"

      local err
      local expansion
      local new
      local old

      if [[ $# != 2 ]]; then
        _zsh_abbr:util_error " rename: Requires exactly two arguments"
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
        _zsh_abbr:util_error " rename: No ${type:-regular} ${scope:-user} abbreviation $current_abbreviation exists"
      fi
    }

    function _zsh_abbr:util_add() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_add"

      local abbreviation
      local expansion
      local job_group
      local success

      abbreviation=$1
      expansion=$2
      success=0

      if [[ ${(w)#abbreviation} > 1 ]]; then
        _zsh_abbr:util_error " add: ABBREVIATION (\`$abbreviation\`) must be only one word"
        return
      fi

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        _zsh_abbr:util_error " add: ABBREVIATION (\`$abbreviation\`) may not contain an equals sign"
      fi

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          if ! (( ${+GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr -S -g $abbreviation=${(Q)expansion}"
            else
              GLOBAL_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
            fi
            success=1
          fi
        elif ! (( ${+REGULAR_SESSION_ABBREVIATIONS[$abbreviation]} )); then
          if (( dry_run )); then
            echo "abbr -S $abbreviation=${(Q)expansion}"
          else
            REGULAR_SESSION_ABBREVIATIONS[$abbreviation]=$expansion
          fi
          success=1
        fi
      else
        if [[ $type == 'global' ]]; then
          source ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations

          if ! (( ${+GLOBAL_USER_ABBREVIATIONS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr -g $abbreviation=${(Q)expansion}"
            else
              GLOBAL_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _zsh_abbr:util_sync_user
            fi
            success=1
          fi
        else
          source ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations

          if ! (( ${+REGULAR_USER_ABBREVIATIONS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr ${(Q)abbreviation}=${(Q)expansion}"
            else
              REGULAR_USER_ABBREVIATIONS[$abbreviation]=$expansion
              _zsh_abbr:util_sync_user
            fi
            success=1
          fi
        fi
      fi

      if ! (( success )); then
        _zsh_abbr:util_error " add: A ${type:-regular} ${scope:-user} abbreviation \`$abbreviation\` already exists"
      fi
    }

    _zsh_abbr:util_alias() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_alias"

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
          echo "$alias_definition" >> "$output_path"
        else
          print "$alias_definition"
        fi
      done
    }

    function _zsh_abbr:util_bad_options() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_bad_options"

      _zsh_abbr:util_error ": Illegal combination of options"
    }

    function _zsh_abbr:util_error() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_error"

      echo "abbr$@"
      echo "For help run abbr --help"
      should_exit=1
    }

    function _zsh_abbr:util_list() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_list"

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

    function _zsh_abbr:util_list_item() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_list_item"

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

      echo $result
    }

    function _zsh_abbr:util_set_once() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_set_once"
      local option value

      option=$1
      value=$2

      (( ZSH_ABBR_DEBUG )) && echo "util_set_once $option $value"

      if [ ${(P)option} ]; then
        _zsh_abbr:util_bad_options
        return
      fi

      eval $option=$value
      ((number_opts++))
    }

    function _zsh_abbr:util_sync_user() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_sync_user"

      (( ZSH_ABBR_INITIALIZING )) && return

      local abbreviation
      local expansion
      local user_updated

      user_updated=$(mktemp ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations_updated.XXXXXX)

      typeset -p GLOBAL_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      for abbreviation in ${(iko)GLOBAL_USER_ABBREVIATIONS}; do
        expansion=${GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
        echo "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p REGULAR_USER_ABBREVIATIONS > ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      for abbreviation in ${(iko)REGULAR_USER_ABBREVIATIONS}; do
        expansion=${REGULAR_USER_ABBREVIATIONS[$abbreviation]}
        echo "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> $user_updated
      done

      mv $user_updated $ZSH_ABBR_USER_PATH
    }

    function _zsh_abbr:util_usage() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr:util_usage"

      man abbr 2>/dev/null || cat ${ZSH_ABBR_SOURCE_PATH}/man/abbr.txt | less -F
    }

    for opt in "$@"; do
      if (( should_exit )); then
        should_exit=0
        return
      fi

      case "$opt" in
        "--add"|\
        "-a")
          _zsh_abbr:util_set_once "action" "add"
          ;;
        "--clear-session"|\
        "-c")
          _zsh_abbr:util_set_once "action" "clear_session"
          ;;
        "--dry-run")
          dry_run=1
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          _zsh_abbr:util_set_once "action" "erase"
          ;;
        "--expand"|\
        "-x")
          _zsh_abbr:util_set_once "action" "expand"
          ;;
        "--export-aliases")
          _zsh_abbr:util_set_once "action" "export_aliases"
          ;;
        "--global"|\
        "-g")
          _zsh_abbr:util_set_once "type" "global"
          ;;
        "--help"|\
        "-h")
          _zsh_abbr:util_usage
          should_exit=1
          ;;
        "--import-aliases")
          _zsh_abbr:util_set_once "action" "import_aliases"
          ;;
        "--import-fish")
          _zsh_abbr:util_set_once "action" "import_fish"
          ;;
        "--import-git-aliases")
          _zsh_abbr:util_set_once "action" "import_git_aliases"
          ;;
        "--list")
          _zsh_abbr:util_set_once "action" "list"
          ;;
        "--list-abbreviations"|\
        "-l")
          _zsh_abbr:util_set_once "action" "list_abbreviations"
          ;;
        "--list-commands"|\
        "-L"|\
        "--show"|\
        "-s") # "show" is for backwards compatability with v2
          _zsh_abbr:util_set_once "action" "list_commands"
          ;;
        "--regular"|\
        "-r")
          _zsh_abbr:util_set_once "type" "regular"
          ;;
        "--rename"|\
        "-R")
          _zsh_abbr:util_set_once "action" "rename"
          ;;
        "--session"|\
        "-S")
          _zsh_abbr:util_set_once "scope" "session"
          ;;
        "--user"|\
        "-U")
          _zsh_abbr:util_set_once "scope" "user"
          ;;
        "--version"|\
        "-v")
          _zsh_abbr:util_set_once "action" "print_version"
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if ! (( should_exit )); then
      shift $number_opts

      if ! (( ZSH_ABBR_INITIALIZING )) && [[ $scope != 'session' ]]; then
        job=$(_zsh_abbr_job_name)
        _zsh_abbr_job_push $job $action
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

    if ! (( ZSH_ABBR_INITIALIZING )); then
      _zsh_abbr_job_pop $job
    fi
  } always {
    unfunction -m _zsh_abbr:add
    unfunction -m _zsh_abbr:clear_session
    unfunction -m _zsh_abbr:erase
    unfunction -m _zsh_abbr:expand
    unfunction -m _zsh_abbr:export_aliases
    unfunction -m _zsh_abbr:import_aliases
    unfunction -m _zsh_abbr:import_fish
    unfunction -m _zsh_abbr:import_git_aliases
    unfunction -m _zsh_abbr:list
    unfunction -m _zsh_abbr:list_commands
    unfunction -m _zsh_abbr:list_abbreviations
    unfunction -m _zsh_abbr:print_version
    unfunction -m _zsh_abbr:rename
    unfunction -m _zsh_abbr:util_bad_options
    unfunction -m _zsh_abbr:util_add
    unfunction -m _zsh_abbr:util_alias
    unfunction -m _zsh_abbr:util_error
    unfunction -m _zsh_abbr:util_list
    unfunction -m _zsh_abbr:util_list_item
    unfunction -m _zsh_abbr:util_set_once
    unfunction -m _zsh_abbr:util_sync_user
    unfunction -m _zsh_abbr:util_usage
  }
}

_zsh_abbr_bind_widgets() {
  (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_bind_widgets"

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

  echo - $expansion
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

  echo - $expansion
}

_zsh_abbr_init() {
  {
    (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_init"

    local job
    local shwordsplit_on

    job=$(_zsh_abbr_job_name)
    shwordsplit_on=0

    typeset -gA REGULAR_USER_ABBREVIATIONS
    typeset -gA REGULAR_SESSION_ABBREVIATIONS
    typeset -gA GLOBAL_USER_ABBREVIATIONS
    typeset -gA GLOBAL_SESSION_ABBREVIATIONS
    REGULAR_USER_ABBREVIATIONS=()
    REGULAR_SESSION_ABBREVIATIONS=()
    GLOBAL_USER_ABBREVIATIONS=()
    GLOBAL_SESSION_ABBREVIATIONS=()

    function _zsh_abbr_init:configure() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_init:configure"

      mkdir -p ${TMPDIR:-/tmp/}zsh-abbr

      if [ -f ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations ]; then
        rm ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      fi

      if [ -f ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations ]; then
        rm ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      fi

      touch ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations
      chmod 600 ${TMPDIR:-/tmp/}zsh-abbr/regular-user-abbreviations

      touch ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations
      chmod 600 ${TMPDIR:-/tmp/}zsh-abbr/global-user-abbreviations

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

    function _zsh_abbr_init:seed() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_init:seed"

      local arguments
      local program

      if [[ $options[shwordsplit] = on ]]; then
        shwordsplit_on=1
      fi

      # Load saved user abbreviations
      if [ -f $ZSH_ABBR_USER_PATH ]; then
        unsetopt shwordsplit

        while read -r line; do
          program="${line%% *}"
          arguments="${line#* }"

          # Only execute abbr commands
          if [[ $program == "abbr" && $program != $line ]]; then
            abbr ${(z)arguments}
          fi
        done < $ZSH_ABBR_USER_PATH

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

    ZSH_ABBR_INITIALIZING=1
    _zsh_abbr_job_push $job initialization
    _zsh_abbr_init:configure
    _zsh_abbr_init:seed
    _zsh_abbr_job_pop $job
    ZSH_ABBR_INITIALIZING=0
  } always {
    unfunction -m _zsh_abbr_init:configure
    unfunction -m _zsh_abbr_init:seed
  }
}

_zsh_abbr_job_push() {
  {
    (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_job_push"

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
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_job_push:add_job"

      if ! [ -d $job_dir ]; then
        mkdir -p $job_dir
      fi

      echo $job_description > $job_path
    }

    function _zsh_abbr_job_push:next_job_id() {
      # cannout support debug message

      ls -t $job_dir | tail -1
    }

    function _zsh_abbr_job_push:handle_timeout() {
      (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_job_push:handle_timeout"

      next_job_path=$job_dir/$next_job

      echo "abbr: A job added at $(strftime '%T %b %d %Y' ${next_job%.*}) has timed out."
      echo "The job was related to $(cat $next_job_path)."
      echo "Please report this at https://github.com/olets/zsh-abbr/issues/new"
      echo

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
  (( ZSH_ABBR_DEBUG )) && echo "_zsh_abbr_job_pop"

  local job

  job=${(q)1}

  rm ${TMPDIR:-/tmp/}zsh-abbr/jobs/$job &>/dev/null
}

_zsh_abbr_job_name() {
  # cannout support debug message

  echo "$(date +%s).$RANDOM"
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
  _zsh_abbr $*
}


# INITIALIZATION
# --------------

ZSH_ABBR_DEBUG=0
ZSH_ABBR_SOURCE_PATH=${0:A:h}
_zsh_abbr_init
if (( $ZSH_ABBR_DEFAULT_BINDINGS )) || [ $ZSH_ABBR_DEFAULT_BINDINGS = true ]; then
  _zsh_abbr_bind_widgets
fi
