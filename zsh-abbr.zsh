# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v3.1.2
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=true}"

# File abbreviations are stored in
ZSH_ABBR_USER_PATH="${ZSH_ABBR_USER_PATH="${HOME}/.config/zsh/abbreviations"}"


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action_set number_opts opt opt_add opt_clear_session opt_dry_run \
          opt_erase opt_expand opt_export_aliases opt_import_git_aliases \
          opt_import_aliases opt_import_fish opt_list opt_list_commands \
          opt_print_version opt_rename opt_scope_session opt_scope_user \
          opt_type_global opt_type_regular type_set release_date scope_set \
          should_exit text_bold text_reset version
    action_set=false
    number_opts=0
    opt_add=false
    opt_clear_session=false
    opt_dry_run=false
    opt_erase=false
    opt_expand=false
    opt_export_aliases=false
    opt_type_global=false
    opt_import_aliases=false
    opt_import_fish=false
    opt_import_git_aliases=false
    opt_list=false
    opt_list_commands=false
    opt_type_regular=false
    opt_rename=false
    opt_scope_session=false
    opt_scope_user=false
    opt_print_version=false
    type_set=false
    release_date="March 22 2020"
    scope_set=false
    should_exit=false
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    version="zsh-abbr version 3.1.2"

    function add() {
      local abbreviation
      local expansion

      if [[ $# -gt 1 ]]; then
        util_error " add: Expected one argument, got $*"
        return
      fi

      abbreviation="${(q)1%%=*}"
      expansion="${(q)1#*=}"

      if [[ -z $abbreviation || -z $expansion || $abbreviation == $1 ]]; then
        util_error " add: Requires abbreviation and expansion"
        return
      fi

      util_add $abbreviation $expansion
    }

    function clear_session() {
      if [ $# -gt 0 ]; then
        util_error " clear-session: Unexpected argument"
        return
      fi

      ZSH_ABBR_SESSION_COMMANDS=()
      ZSH_ABBR_SESSION_GLOBALS=()
    }

    function erase() {
      local abbreviation
      local job
      local job_group
      local success

      if [ $# -gt 1 ]; then
        util_error " erase: Expected one argument"
        return
      elif [ $# -lt 1 ]; then
        util_error " erase: Erase needs a variable name"
        return
      fi

      abbreviation=$1
      job_group='erase'
      success=false

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      if $opt_scope_session; then
        if $opt_type_global; then
          if (( ${+ZSH_ABBR_SESSION_GLOBALS[$abbreviation]} )); then
            unset "ZSH_ABBR_SESSION_GLOBALS[${(b)abbreviation}]"
            success=true
          fi
        elif (( ${+ZSH_ABBR_SESSION_COMMANDS[$abbreviation]} )); then
          unset "ZSH_ABBR_SESSION_COMMANDS[${(b)abbreviation}]"
          success=true
        fi
      else
        if $opt_type_global; then
          source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

          if (( ${+ZSH_ABBR_USER_GLOBALS[$abbreviation]} )); then
            unset "ZSH_ABBR_USER_GLOBALS[${(b)abbreviation}]"
            util_sync_user
            success=true
          fi
        else
          source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

          if (( ${+ZSH_ABBR_USER_COMMANDS[$abbreviation]} )); then
            unset "ZSH_ABBR_USER_COMMANDS[${(b)abbreviation}]"
            util_sync_user
            success=true
          fi
        fi
      fi

      _zsh_abbr_job_pop $job $job_group

      if ! $success; then
        util_error " erase: No matching abbreviation $abbreviation exists"
      fi
    }

    function expand() {
      local abbreviation
      local expansion

      abbreviation=$1

      if [ $# -ne 1 ]; then
        printf "expand requires exactly one argument\\n"
        return
      fi

      expansion=$(_zsh_abbr_cmd_expansion "$abbreviation")

      if [[ ! -n "$expansion" ]]; then
        expansion=$(_zsh_abbr_global_expansion "$abbreviation")
      fi

      echo - "${(Q)expansion}"
    }

    function export_aliases() {
      local global_only
      local output_path

      global_only=$opt_type_global
      output_path=$1

      if [ $# -gt 1 ]; then
        util_error " export-aliases: Unexpected argument"
        return
      fi

      if ! $opt_scope_user; then
        if ! $opt_type_regular; then
          opt_type_global=true
          util_alias ZSH_ABBR_SESSION_GLOBALS $output_path
        fi

        if ! $global_only; then
          opt_type_global=false
          util_alias ZSH_ABBR_SESSION_COMMANDS $output_path
        fi
      fi

      if ! $opt_scope_session; then
        if ! $opt_type_regular; then
          opt_type_global=true
          util_alias ZSH_ABBR_USER_GLOBALS $output_path
        fi

        if ! $global_only; then
          opt_type_global=false
          util_alias ZSH_ABBR_USER_COMMANDS $output_path
        fi
      fi
    }

    function import_aliases() {
      local _alias

      if [ $# -gt 0 ]; then
        util_error " import-aliases: Unexpected argument"
        return
      fi

      while read -r _alias; do
        add $_alias
      done < <(alias -r)

      opt_type_global=true

      while read -r _alias; do
        add $_alias
      done < <(alias -g)

      if ! $opt_dry_run; then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function import_fish() {
      local abbreviation
      local expansion
      local input_file

      if [ $# -ne 1 ]; then
        printf "expand requires exactly one argument\\n"
        return
      fi

      input_file=$1

      while read -r line; do
        def=${line#* -- }
        abbreviation=${def%% *}
        expansion=${def#* }

        util_add $abbreviation $expansion
      done < $input_file

      if ! $opt_dry_run; then
        echo "Abbreviations imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function import_git_aliases() {
      local git_aliases
      local abbr_git_aliases

      if [ $# -gt 0 ]; then
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

      if ! $opt_dry_run; then
        echo "Aliases imported. It is recommended that you look over \$ZSH_ABBR_USER_PATH to confirm there are no quotation mark-related problems\\n"
      fi
    }

    function list() {
      if [ $# -gt 0 ]; then
        util_error " list: Unexpected argument"
        return
      fi

      util_list 0
    }

    function list_commands() {
      if [ $# -gt 0 ]; then
        util_error " list commands: Unexpected argument"
        return
      fi

      util_list 2
    }

    function list_definitions() {
      if [ $# -gt 0 ]; then
        util_error " list definitions: Unexpected argument"
        return
      fi

      util_list 1
    }

    function print_version() {
      if [ $# -gt 0 ]; then
        util_error " version: Unexpected argument"
        return
      fi

      printf "%s\\n" "$version"
    }

    function rename() {
      local err
      local expansion
      local job
      local job_group
      local new
      local old

      if [ $# -ne 2 ]; then
        util_error " rename: Requires exactly two arguments"
        return
      fi

      current_abbreviation=$1
      new_abbreviation=$2
      job_group='rename'

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      if $opt_scope_session; then
        if $opt_type_global; then
          expansion=${ZSH_ABBR_SESSION_GLOBALS[$current_abbreviation]}
        else
          expansion=${ZSH_ABBR_SESSION_COMMANDS[$current_abbreviation]}
        fi
      else
        if $opt_type_global; then
          expansion=${ZSH_ABBR_USER_GLOBALS[$current_abbreviation]}
        else
          expansion=${ZSH_ABBR_USER_COMMANDS[$current_abbreviation]}
        fi
      fi

      if [[ -n "$expansion" ]]; then
        util_add $new_abbreviation $expansion

        if ! $opt_dry_run; then
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
      local abbreviation
      local expansion
      local job
      local job_group
      local success

      abbreviation=$1
      expansion=$2
      job_group='util_add'
      success=false

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

      if $opt_scope_session; then
        if $opt_type_global; then
          if ! (( ${+ZSH_ABBR_SESSION_GLOBALS[$abbreviation]} )); then
            if $opt_dry_run; then
              echo "abbr -S -g $abbreviation=${(Q)expansion}"
            else
              ZSH_ABBR_SESSION_GLOBALS[$abbreviation]=$expansion
            fi
            success=true
          fi
        elif ! (( ${+ZSH_ABBR_SESSION_COMMANDS[$abbreviation]} )); then
          if $opt_dry_run; then
            echo "abbr -S $abbreviation=${(Q)expansion}"
          else
            ZSH_ABBR_SESSION_COMMANDS[$abbreviation]=$expansion
          fi
          success=true
        fi
      else
        if $opt_type_global; then
          source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_GLOBALS[$abbreviation]} )); then
            if $opt_dry_run; then
              echo "abbr -g $abbreviation=${(Q)expansion}"
            else
              ZSH_ABBR_USER_GLOBALS[$abbreviation]=$expansion
              util_sync_user
            fi
            success=true
          fi
        else
          source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

          if ! (( ${+ZSH_ABBR_USER_COMMANDS[$abbreviation]} )); then
            if $opt_dry_run; then
              echo "abbr ${(Q)abbreviation}=${(Q)expansion}"
            else
              ZSH_ABBR_USER_COMMANDS[$abbreviation]=$expansion
              util_sync_user
            fi
            success=true
          fi
        fi
      fi

      _zsh_abbr_job_pop $job $job_group

      if ! $success; then
        util_error " add: A matching abbreviation $1 already exists"
      fi
    }

    util_alias() {
      local abbreviations_set
      local output_path

      abbreviations_set=$1
      output_path=$2

      for abbreviation expansion in ${(kv)${(P)abbreviations_set}}; do
        alias_definition="alias "
        if [[ $opt_type_global == true ]]; then
          alias_definition+="-g "
        fi
        alias_definition+="$abbreviation='$expansion'"

        if [[ -n $output_path ]]; then
          echo "$alias_definition" >> "$output_path"
        else
          print "$alias_definition"
        fi
      done
    }

    function util_bad_options() {
      util_error ": Illegal combination of options"
    }

    function util_error() {
      printf "abbr%s\\nFor help run abbr --help\\n" "$@"
      should_exit=true
    }

    function util_list() {
      local result
      local include_expansion
      local include_cmd

      if [[ $1 > 0 ]]; then
        include_expansion=1
      fi

      if [[ $1 > 1 ]]; then
        include_cmd=1
      fi

      if ! $opt_scope_session; then
        if ! $opt_type_regular; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -g"
          done
        fi

        if ! $opt_type_global; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr"
          done
        fi
      fi

      if ! $opt_scope_user; then
        if ! $opt_type_regular; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_GLOBALS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S -g"
          done
        fi

        if ! $opt_type_global; then
          for abbreviation expansion in ${(kv)ZSH_ABBR_SESSION_COMMANDS}; do
            util_list_item "$abbreviation" "$expansion" "abbr -S"
          done
        fi
      fi
    }

    function util_list_item() {
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

    function util_sync_user() {
      local job
      local job_group
      local user_updated

      if [[ -n "$ZSH_ABBR_NO_SYNC_USER" ]]; then
        return
      fi

      job_group='util_sync_user'

      echo $RANDOM >/dev/null
      job=$(_zsh_abbr_job_name)
      _zsh_abbr_job_push $job $job_group

      user_updated="${TMPDIR:-/tmp}/zsh-user-abbreviations"_updated
      rm "$user_updated" 2> /dev/null
      touch "$user_updated"
      chmod 600 "$user_updated"

      typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_GLOBALS}; do
        echo "abbr -g ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"
      for abbreviation expansion in ${(kv)ZSH_ABBR_USER_COMMANDS}; do
        echo "abbr ${abbreviation}=${(qqq)${(Q)expansion}}" >> "$user_updated"
      done

      mv "$user_updated" "$ZSH_ABBR_USER_PATH"

      _zsh_abbr_job_pop $job $job_group
    }

    function util_type() {
      local type
      type="user"

      if $opt_scope_session; then
        type="session"
      fi

      echo $type
    }

    function util_usage() {
      man abbr 2>/dev/null || cat ${ZSH_ABBR_SOURCE_PATH}/man/abbr.txt | less -F
    }

    for opt in "$@"; do
      if $should_exit; then
        should_exit=false
        return
      fi

      case "$opt" in
        "--add"|\
        "-a")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_add=true
          ((number_opts++))
          ;;
        "--clear-session"|\
        "-c")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_clear_session=true
          ((number_opts++))
          ;;
        --dry-run)
          opt_dry_run=true
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_erase=true
          ((number_opts++))
          ;;
        "--expand"|\
        "-x")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_expand=true
          ((number_opts++))
          ;;
        "--global"|\
        "-g")
          [ "$type_set" = true ] && util_bad_options
          type_set=true
          opt_type_global=true
          ((number_opts++))
          ;;
        "--import-fish")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_fish=true
          ((number_opts++))
          ;;
        "--help"|\
        "-h")
          util_usage
          should_exit=true
          ;;
        "--import-git-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_git_aliases=true
          ((number_opts++))
          ;;
        "--export-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_export_aliases=true
          ((number_opts++))
          ;;
        "--import-aliases")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_import_aliases=true
          ((number_opts++))
          ;;
        "--list-abbreviations"|\
        "-l")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_list=true
          ((number_opts++))
          ;;
        "--list-commands"|\
        "-L"|\
        "--show"|\
        "-s") # "show" is for backwards compatability with v2
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_list_commands=true
          ((number_opts++))
          ;;
        "--regular"|\
        "-r")
          [ "$type_set" = true ] && util_bad_options
          type_set=true
          opt_type_regular=true
          ((number_opts++))
          ;;
        "--rename"|\
        "-R")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_rename=true
          ((number_opts++))
          ;;
        "--session"|\
        "-S")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
          opt_scope_session=true
          ((number_opts++))
          ;;
        "--user"|\
        "-U")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
          opt_scope_user=true
          ((number_opts++))
          ;;
        "--version"|\
        "-v")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_print_version=true
          ((number_opts++))
          ;;
        "--")
          ((number_opts++))
          break
          ;;
      esac
    done

    if $should_exit; then
      should_exit=false
      return
    fi

    shift $number_opts

    if $opt_add; then
       add "$@"
    elif $opt_clear_session; then
      clear_session "$@"
    elif $opt_erase; then
      erase "$@"
    elif $opt_expand; then
      expand "$@"
    elif $opt_export_aliases; then
      export_aliases "$@"
    elif $opt_import_aliases; then
      import_aliases "$@"
    elif $opt_import_fish; then
      import_fish "$@"
    elif $opt_import_git_aliases; then
      import_git_aliases "$@"
    elif $opt_list; then
      list "$@"
    elif $opt_list_commands; then
      list_commands "$@"
    elif $opt_print_version; then
      print_version "$@"
    elif $opt_rename; then
      rename "$@"

    # default if arguments are provided
    elif ! $opt_list_commands && [ $# -gt 0 ]; then
       add "$@"
    # default if no argument is provided
    else
      list_definitions "$@"
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
    unfunction -m "list_definitions"
    unfunction -m "print_version"
    unfunction -m "rename"
    unfunction -m "util_add"
    unfunction -m "util_alias"
    unfunction -m "util_error"
    unfunction -m "util_list"
    unfunction -m "util_list_item"
    unfunction -m "util_sync_user"
    unfunction -m "util_type"
    unfunction -m "util_usage"
  }
}

_zsh_abbr_bind_widgets() {
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
  local abbreviation
  local expansion

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_COMMANDS[$abbreviation]}"

  if [[ ! -n "$expansion" ]]; then
    source "${TMPDIR:-/tmp}/zsh-user-abbreviations"
    expansion="${ZSH_ABBR_USER_COMMANDS[$abbreviation]}"
  fi

  echo - "$expansion"
}

_zsh_abbr_expand_and_accept() {
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
  local abbreviation
  local expansion

  abbreviation="$1"
  expansion="${ZSH_ABBR_SESSION_GLOBALS[$abbreviation]}"

  if [[ ! -n "$expansion" ]]; then
    source "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
    expansion="${ZSH_ABBR_USER_GLOBALS[$abbreviation]}"
  fi

  echo - "$expansion"
}

_zsh_abbr_init() {
  {
    local line
    local job
    local job_group
    local session_shwordsplit_on

    job_group='init'
    session_shwordsplit_on=false
    ZSH_ABBR_NO_SYNC_USER=true

    typeset -gA ZSH_ABBR_USER_COMMANDS
    typeset -gA ZSH_ABBR_SESSION_COMMANDS
    typeset -gA ZSH_ABBR_USER_GLOBALS
    typeset -gA ZSH_ABBR_SESSION_GLOBALS
    ZSH_ABBR_USER_COMMANDS=()
    ZSH_ABBR_SESSION_COMMANDS=()
    ZSH_ABBR_USER_GLOBALS=()
    ZSH_ABBR_SESSION_GLOBALS=()

    function configure() {
      if [[ $options[shwordsplit] = on ]]; then
        session_shwordsplit_on=true
      fi

      # Scratch files
      rm "${TMPDIR:-/tmp}/zsh-user-abbreviations" 2> /dev/null
      touch "${TMPDIR:-/tmp}/zsh-user-abbreviations"
      chmod 600 "${TMPDIR:-/tmp}/zsh-user-abbreviations"

      rm "${TMPDIR:-/tmp}/zsh-user-global-abbreviations" 2> /dev/null
      touch "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
      chmod 600 "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
    }

    function seed() {
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

      unset ZSH_ABBR_NO_SYNC_USER

      typeset -p ZSH_ABBR_USER_COMMANDS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"
      typeset -p ZSH_ABBR_USER_GLOBALS > "${TMPDIR:-/tmp}/zsh-user-global-abbreviations"
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

    job_dir=${TMPDIR:-/tmp}/zsh-abbr-jobs/${job_group}
    job_path=$job_dir/$job

    function add_job() {
      if ! [ -d $job_dir ]; then
        mkdir -p $job_dir
      fi

      if ! [ -d ${TMPDIR:-/tmp}/zsh-abbr-jobs/current ]; then
        mkdir ${TMPDIR:-/tmp}/zsh-abbr-jobs/current
      fi

      echo $job_group > $job_path
    }

    function get_next_job() {
      ls -t $job_dir | tail -1
    }

    function handle_timeout() {
      next_job_path=$job_dir/$next_job

      echo "abbr: An job added at"
      echo "  $(strftime '%A, %d %b %Y' ${next_job%.*})"
      echo "has timed out. The job was related to"
      echo "  $(cat $next_job_path)"
      echo "Please report this at https://github.com/olets/zsh-abbr/issues/new"
      echo

      rm $next_job_path &>/dev/null
      rm "${TMPDIR:-/tmp}/zsh-abbr-jobs/current/$job_group*" &>/dev/null
    }

    function wait_turn() {
      while [[ $(get_next_job) != $job ]]; do
        next_job=$(get_next_job)
        next_job_age=$(( $(date +%s) - ${next_job%.*} ))

        if ((  $next_job_age > $timeout_age )); then
          handle_timeout
        fi

        sleep 0.01
      done

      cp $job_path "${TMPDIR:-/tmp}/zsh-abbr-jobs/current/$job_group-$job"
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
  local currents
  local job
  local job_group

  job=${(q)1}
  job_group=$2

  typeset -a currents
  currents=(${(@f)$(ls -d ${TMPDIR:-/tmp}/zsh-abbr-jobs/current/$job_group* 2>/dev/null)})

  for current in $currents; do
    rm $current &>/dev/null
  done

  rm "${TMPDIR:-/tmp}/zsh-abbr-jobs/${job_group}/${job}" &>/dev/null
}

_zsh_abbr_job_name() {
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

  if ! [[ -n "$expansion" ]]; then
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

if [ "$ZSH_ABBR_DEFAULT_BINDINGS" = true ]; then
  _zsh_abbr_bind_widgets
fi

