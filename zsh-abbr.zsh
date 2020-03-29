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
    local action number_opts opt dry_run release_date scope \
          should_exit text_bold text_reset type version
    dry_run=0
    number_opts=0
    release_date="March 22 2020"
    should_exit=0
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    version="zsh-abbr version 3.1.2"

    function add() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "add"

      local abbreviation
      local expansion

      if [[ $# > 1 ]]; then
        util_error " add: Expected one argument, got $*"
        return
      fi

      abbreviation="${(q)1%%=*}"
      expansion="${(q)1#*=}"

      if ! [[ $abbreviation && $expansion && $abbreviation != $1 ]]; then
        util_error " add: Requires abbreviation and expansion"
        return
      fi

      util_add $abbreviation $expansion
    }

    function clear_session() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "clear_session"

      if [[ $# > 0 ]]; then
        util_error " clear-session: Unexpected argument"
        return
      fi

      ZSH_ABBR_SESSION_COMMANDS=()
      ZSH_ABBR_SESSION_GLOBALS=()
    }

    function erase() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "erase"

      local abbreviation
      local job
      local job_group
      local success

      if [[ $# > 1 ]]; then
        util_error " erase: Expected one argument"
        return
      elif [[ $# < 1 ]]; then
        util_error " erase: Erase needs a variable name"
        return
      fi

      abbreviation=$1
      job_group='erase'
      success=0

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          if (( ${+ZSH_ABBR_SESSION_GLOBALS[$abbreviation]} )); then
            unset "ZSH_ABBR_SESSION_GLOBALS[${(b)abbreviation}]"
            success=1
          fi
        elif (( ${+ZSH_ABBR_SESSION_COMMANDS[$abbreviation]} )); then
          unset "ZSH_ABBR_SESSION_COMMANDS[${(b)abbreviation}]"
          success=1
        fi
      else
        if [[ $type == 'global' ]]; then
          source "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"

          if (( ${+ZSH_ABBR_USER_GLOBALS[$abbreviation]} )); then
            unset "ZSH_ABBR_USER_GLOBALS[${(b)abbreviation}]"
            util_sync_user
            success=1
          fi
        else
          source "${TMPDIR:-/tmp/}zsh-user-abbreviations"

          if (( ${+ZSH_ABBR_USER_COMMANDS[$abbreviation]} )); then
            unset "ZSH_ABBR_USER_COMMANDS[${(b)abbreviation}]"
            util_sync_user
            success=1
          fi
        fi
      fi

      _zsh_abbr_job_pop $job $job_group

      if ! (( success )); then
        util_error " erase: No $type $scope abbreviation $abbreviation found"
      fi
    }

    function expand() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "expand"

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

    function export_aliases() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "export_aliases"

      local type_saved
      local output_path

      type_saved=$type
      output_path=$1

      if [[ $# > 1 ]]; then
        util_error " export-aliases: Unexpected argument"
        return
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type_saved != 'regular' ]]; then
          type='global'
          util_alias ZSH_ABBR_SESSION_GLOBALS $output_path
        fi

        if [[ $type_saved != 'global' ]]; then
          type='regular'
          util_alias ZSH_ABBR_SESSION_COMMANDS $output_path
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type_saved != 'regular' ]]; then
          type='global'
          util_alias ZSH_ABBR_USER_GLOBALS $output_path
        fi

        if [[ $type_saved != 'global' ]]; then
          type='regular'
          util_alias ZSH_ABBR_USER_COMMANDS $output_path
        fi
      fi
    }

    function import_aliases() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "import_aliases"

      local _alias

      if [[ $# > 0 ]]; then
        util_error " import-aliases: Unexpected argument"
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

    function import_fish() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "import_fish"

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

        util_add $abbreviation $expansion
      done < $input_file

      if ! (( dry_run )); then
        echo "Abbreviations imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function import_git_aliases() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "import_git_aliases"

      local git_aliases
      local abbr_git_aliases

      if [[ $# > 0 ]]; then
        util_error " import-git-aliases: Unexpected argument"
        return
      fi

      git_aliases=("${(@f)$(git config --get-regexp '^alias\.')}")
      typeset -A abbr_git_aliases

      for git_alias in $git_aliases; do
        key="${$(echo - $git_alias | awk '{print $1;}')##alias.}"
        value="${$(echo - $git_alias)##alias.$key }"

        util_add "g$key" "git ${value# }"
      done

      if ! (( dry_run )); then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function list() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "list"

      if [[ $# > 0 ]]; then
        util_error " list: Unexpected argument"
        return
      fi

      util_list 0
    }

    function list_commands() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "list_commands"

      if [[ $# > 0 ]]; then
        util_error " list commands: Unexpected argument"
        return
      fi

      util_list 2
    }

    function list_abbreviations() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "list_abbreviations"

      if [[ $# > 0 ]]; then
        util_error " list definitions: Unexpected argument"
        return
      fi

      util_list 1
    }

    function print_version() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "print_version"

      if [[ $# > 0 ]]; then
        util_error " version: Unexpected argument"
        return
      fi

      echo $version
    }

    function rename() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "rename"

      local err
      local expansion
      local job
      local job_group
      local new
      local old

      if [[ $# != 2 ]]; then
        util_error " rename: Requires exactly two arguments"
        return
      fi

      current_abbreviation=$1
      new_abbreviation=$2
      job_group='rename'

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          expansion=${ZSH_ABBR_SESSION_GLOBALS[$current_abbreviation]}
        else
          expansion=${ZSH_ABBR_SESSION_COMMANDS[$current_abbreviation]}
        fi
      else
        if [[ $type == 'global' ]]; then
          expansion=${ZSH_ABBR_USER_GLOBALS[$current_abbreviation]}
        else
          expansion=${ZSH_ABBR_USER_COMMANDS[$current_abbreviation]}
        fi
      fi

      if [[ -n "$expansion" ]]; then
        util_add $new_abbreviation $expansion

        if ! (( dry_run )); then
          erase $current_abbreviation
        else
          echo "abbr -e $current_abbreviation"
        fi
      else
        util_error " rename: No matching abbreviation $current_abbreviation exists"
      fi

      _zsh_abbr_job_pop $job $job_group
    }

    function util_add() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_add"

      local abbreviation
      local expansion
      local job
      local job_group
      local success

      abbreviation=$1
      expansion=$2
      job_group='util_add'
      success=0

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      if [[ ${(w)#abbreviation} > 1 ]]; then
        util_error " add: ABBREVIATION ('$abbreviation') must be only one word"
        return
      fi

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        util_error " add: ABBREVIATION ('$abbreviation') may not contain an equals sign"
      fi

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          if ! (( ${+ZSH_ABBR_SESSION_GLOBALS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr -S -g $abbreviation=${(Q)expansion}"
            else
              ZSH_ABBR_SESSION_GLOBALS[$abbreviation]=$expansion
            fi
            success=1
          fi
        elif ! (( ${+ZSH_ABBR_SESSION_COMMANDS[$abbreviation]} )); then
          if (( dry_run )); then
            echo "abbr -S $abbreviation=${(Q)expansion}"
          else
            ZSH_ABBR_SESSION_COMMANDS[$abbreviation]=$expansion
          fi
          success=1
        fi
      else
        if [[ $type == 'global' ]]; then
          source "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_GLOBALS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr -g $abbreviation=${(Q)expansion}"
            else
              ZSH_ABBR_USER_GLOBALS[$abbreviation]=$expansion
              util_sync_user
            fi
            success=1
          fi
        else
          source "${TMPDIR:-/tmp/}zsh-user-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_COMMANDS[$abbreviation]} )); then
            if (( dry_run )); then
              echo "abbr ${(Q)abbreviation}=${(Q)expansion}"
            else
              ZSH_ABBR_USER_COMMANDS[$abbreviation]=$expansion
              util_sync_user
            fi
            success=1
          fi
        fi
      fi

      _zsh_abbr_job_pop $job $job_group

      if ! (( success )); then
        util_error " add: A $type $scope abbreviation $1 already exists"
      fi
    }

    util_alias() {
      local abbreviations_set
      local output_path

      abbreviations_set=$1
      output_path=$2

      for abbreviation expansion in ${(kv)${(P)abbreviations_set}}; do
        alias_definition="alias "
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

    function util_bad_options() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_bad_options"

      util_error ": Illegal combination of options"
    }

    function util_error() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_error"

      echo "abbr$@"
      echo "For help run abbr --help"
      should_exit=1
    }

    function util_list() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_list"

      local result
      local include_expansion
      local include_cmd

      if [[ $1 > 0 ]]; then
        include_expansion=1
      fi

      if [[ $1 > 1 ]]; then
        include_cmd=1
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -g"
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr"
          done
        fi
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S -g"
          done
        fi

        if [[ $type != 'global' ]]; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S"
          done
        fi
      fi
    }

    function util_list_item() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_list_item"

      local abbreviation
      local cmd
      local expansion

      abbreviation=$1
      expansion=$2
      cmd=$3

      result=$abbreviation
      if (( $include_expansion )); then
        result+="=${(qqq)${(Q)expansion}}"
      fi

      if (( $include_cmd )); then
        result="$cmd $result"
      fi

      echo $result
    }

    function util_set_once() {
      local option value

      option=$1
      value=$2

      [[ $ZSH_ABBR_DEBUG ]] && echo "util_set_once $option $value"

      if [ ${(P)option} ]; then
        util_bad_options
        return
      fi

      eval $option=$value
      ((number_opts++))
    }

    function util_sync_user() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_sync_user"

      local job
      local job_group
      local user_updated

      if [[ -n $(ls ${TMPDIR:-/tmp/}zsh-abbr-jobs/current 2>/dev/null | grep 'init*') ]]; then
        return
      fi

      job_group='util_sync_user'

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      user_updated="${TMPDIR:-/tmp/}zsh-user-abbreviations"_updated
      rm "$user_updated" 2> /dev/null
      touch "$user_updated"
      chmod 600 "$user_updated"

      typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
        echo "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp/}zsh-user-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
        echo "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      mv "$user_updated" "$ZSH_ABBR_USER_PATH"

      _zsh_abbr_job_pop $job $job_group
    }

    function util_usage() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "util_usage"

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
          util_set_once "action" "add"
          ;;
        "--clear-session"|\
        "-c")
          util_set_once "action" "clear_session"
          ;;
        --dry-run)
          dry_run=1
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          util_set_once "action" "erase"
          ;;
        "--expand"|\
        "-x")
          util_set_once "action" "expand"
          ;;
        "--export-aliases")
          util_set_once "action" "export_aliases"
          ;;
        "--global"|\
        "-g")
          util_set_once "type" "global"
          ;;
        "--help"|\
        "-h")
          util_usage
          should_exit=1
          ;;
        "--import-aliases")
          util_set_once "action" "import_aliases"
          ;;
        "--import-fish")
          util_set_once "action" "import_fish"
          ;;
        "--import-git-aliases")
          util_set_once "action" "import_git_aliases"
          ;;
        "--list-abbreviations"|\
        "-l")
          util_set_once "action" "list_abbreviations"
          ;;
        "--list-commands"|\
        "-L"|\
        "--show"|\
        "-s") # "show" is for backwards compatability with v2
          util_set_once "action" "list_commands"
          ;;
        "--regular"|\
        "-r")
          util_set_once "type" "regular"
          ;;
        "--rename"|\
        "-R")
          util_set_once "action" "rename"
          ;;
        "--session"|\
        "-S")
          util_set_once "scope" "session"
          ;;
        "--user"|\
        "-U")
          util_set_once "scope" "user"
          ;;
        "--version"|\
        "-v")
          util_set_once "action" "print_version"
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if (( should_exit )); then
      should_exit=0
      return
    fi

    shift $number_opts

    if [ $action ]; then
      $action "$@"
    elif [[ $# > 0 ]]; then
      # default if arguments are provided
       add "$@"
    else
      # default if no argument is provided
      list_abbreviations "$@"
    fi
  } always {
    unfunction -m "add"
    unfunction -m "util_bad_options"
    unfunction -m "clear_session"
    unfunction -m "erase"
    unfunction -m "expand"
    unfunction -m "export_aliases"
    unfunction -m "import_aliases"
    unfunction -m "import_fish"
    unfunction -m "import_git_aliases"
    unfunction -m "list"
    unfunction -m "list_commands"
    unfunction -m "list_abbreviations"
    unfunction -m "print_version"
    unfunction -m "rename"
    unfunction -m "util_add"
    unfunction -m "util_alias"
    unfunction -m "util_error"
    unfunction -m "util_list"
    unfunction -m "util_list_item"
    unfunction -m "util_set_once"
    unfunction -m "util_sync_user"
    unfunction -m "util_usage"
  }
}

_zsh_abbr_bind_widgets() {
  [[ $ZSH_ABBR_DEBUG ]] && echo "bind_widgets"

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

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_COMMANDS[$abbreviation]}"

  if [ ! "$expansion" ]; then
    source "${TMPDIR:-/tmp/}zsh-user-abbreviations"
    expansion="${ZSH_ABBR_USER_COMMANDS[$abbreviation]}"
  fi

  echo - "$expansion"
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
  zle _zsh_abbr_expand_widget
  zle self-insert
}

_zsh_abbr_global_expansion() {
  # cannout support debug message

  local abbreviation
  local expansion

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_GLOBALS[$abbreviation]}"

  if [ ! "$expansion" ]; then
    source "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"
    expansion="${ZSH_ABBR_USER_GLOBALS[$abbreviation]}"
  fi

  echo - "$expansion"
}

_zsh_abbr_init() {
  {
    [[ $ZSH_ABBR_DEBUG ]] && echo "init"

    local line
    local job
    local job_group
    local session_shwordsplit_on

    job_group='init'
    session_shwordsplit_on=false

    typeset -gA ZSH_ABBR_USER_COMMANDS
    typeset -gA ZSH_ABBR_SESSION_COMMANDS
    typeset -gA ZSH_ABBR_USER_GLOBALS
    typeset -gA ZSH_ABBR_SESSION_GLOBALS
    ZSH_ABBR_USER_COMMANDS=()
    ZSH_ABBR_SESSION_COMMANDS=()
    ZSH_ABBR_USER_GLOBALS=()
    ZSH_ABBR_SESSION_GLOBALS=()

    function configure() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "configure"

      if [[ $options[shwordsplit] = on ]]; then
        session_shwordsplit_on=true
      fi

      # Scratch files
      rm "${TMPDIR:-/tmp/}zsh-user-abbreviations" 2> /dev/null
      touch "${TMPDIR:-/tmp/}zsh-user-abbreviations"
      chmod 600 "${TMPDIR:-/tmp/}zsh-user-abbreviations"

      rm "${TMPDIR:-/tmp/}zsh-user-global-abbreviations" 2> /dev/null
      touch "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"
      chmod 600 "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"
    }

    function seed() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "seed"

      # Load saved user abbreviations
      if [ -f "$ZSH_ABBR_USER_PATH" ]; then
        unsetopt shwordsplit

        source "$ZSH_ABBR_USER_PATH"

        if $session_shwordsplit_on; then
          setopt shwordsplit
        fi
      else
        mkdir -p $(dirname "$ZSH_ABBR_USER_PATH")
        touch "$ZSH_ABBR_USER_PATH"
      fi

      typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp/}zsh-user-abbreviations"
      typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp/}zsh-user-global-abbreviations"
    }

    # open job
    echo $RANDOM >/dev/null
    job=$(_zsh_abbr_job_name)
    _zsh_abbr_job_push $job $job_group

    # init
    configure
    seed

    # close job
    _zsh_abbr_job_pop $job $job_group
  } always {
    unfunction -m "configure"
    unfunction -m "seed"
  }
}

_zsh_abbr_job_push() {
  {
    [[ $ZSH_ABBR_DEBUG ]] && echo "job_push"

    local next_job
    local next_job_age
    local next_job_path
    local job
    local job_dir
    local job_group
    local job_path
    local timeout_age

    job=${(q)1}
    job_group=${(q)2}
    timeout_age=30 # seconds

    job_dir=${TMPDIR:-/tmp/}zsh-abbr-jobs/${job_group}
    job_path=$job_dir/$job

    function add_job() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "add_job"

      if ! [ -d $job_dir ]; then
        mkdir -p $job_dir
      fi

      if ! [ -d ${TMPDIR:-/tmp/}zsh-abbr-jobs/current ]; then
        mkdir ${TMPDIR:-/tmp/}zsh-abbr-jobs/current
      fi

      echo $job_group > $job_path
    }

    function get_next_job() {
      # cannout support debug message

      ls -t $job_dir | tail -1
    }

    function handle_timeout() {
      [[ $ZSH_ABBR_DEBUG ]] && echo "handle_timeout"

      next_job_path=$job_dir/$next_job

      echo "abbr: An job added at"
      echo "  $(strftime '%T %b %d %Y' ${next_job%.*})"
      echo "has timed out. The job was related to"
      echo "  $(cat $next_job_path)"
      echo "Please report this at https://github.com/olets/zsh-abbr/issues/new"
      echo

      rm $next_job_path &>/dev/null
      rm "${TMPDIR:-/tmp/}zsh-abbr-jobs/current/$job_group*" &>/dev/null
    }

    function wait_turn() {
      while [[ $(get_next_job) != $job ]]; do
        next_job=$(get_next_job)
        echo "next_job $next_job"
        echo "next_job_time ${next_job%.*}"
        next_job_age=$(( $(date +%s) - ${next_job%.*} ))

        if ((  $next_job_age > $timeout_age )); then
          handle_timeout
        fi

        sleep 0.01
      done

      cp $job_path "${TMPDIR:-/tmp/}zsh-abbr-jobs/current/$job_group-$job"
    }

    add_job
    wait_turn
  } always {
    unfunction -m "add_job"
    unfunction -m "get_next_job"
    unfunction -m "handle_timeout"
    unfunction -m "wait_turn"
  }
}

_zsh_abbr_job_pop() {
  [[ $ZSH_ABBR_DEBUG ]] && echo "job_pop"

  local currents
  local job
  local job_group

  job=${(q)1}
  job_group=$2

  typeset -a currents
  currents=(${(@f)$(ls -d ${TMPDIR:-/tmp/}zsh-abbr-jobs/current/$job_group* 2>/dev/null)})

  for current in $currents; do
    rm $current &>/dev/null
  done

  rm "${TMPDIR:-/tmp/}zsh-abbr-jobs/${job_group}/${job}" &>/dev/null
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
    expansion=$(_zsh_abbr_cmd_expansion "$word")
  fi

  if [ ! "$expansion" ]; then
    expansion=$(_zsh_abbr_global_expansion "$word")
  fi

  if [[ -n "$expansion" ]]; then
    local preceding_lbuffer
    preceding_lbuffer="${LBUFFER%%$word}"
    LBUFFER="$preceding_lbuffer${(Q)expansion}"
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

_zsh_abbr_init
ZSH_ABBR_SOURCE_PATH=${0:A:h}

if (( $ZSH_ABBR_DEFAULT_BINDINGS )) || [ $ZSH_ABBR_DEFAULT_BINDINGS = true ]; then
  _zsh_abbr_bind_widgets
fi

