# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v2.1.3
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=true}"

# File abbreviations are stored in
ZSH_USER_ABBREVIATIONS_PATH="${ZSH_USER_ABBREVIATIONS_PATH="${HOME}/.config/zsh/abbreviations"}"


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action_set number_opts opt opt_add opt_clear_session opt_erase \
          opt_expand opt_git_populate opt_session opt_list opt_output_aliases \
          opt_populate opt_rename opt_show opt_user opt_print_version \
          release_date scope_set should_exit text_bold text_reset util_usage \
          version
    action_set=false
    number_opts=0
    opt_add=false
    opt_clear_session=false
    opt_erase=false
    opt_expand=false
    opt_git_populate=false
    opt_session=false
    opt_list=false
    opt_output_aliases=false
    opt_populate=false
    opt_rename=false
    opt_show=false
    opt_user=false
    opt_print_version=false
    release_date="February 26 2020"
    scope_set=false
    should_exit=false
    text_bold="\\033[1m"
    text_reset="\\033[0m"
    util_usage="
       ${text_bold}abbr${text_reset}: fish shell-like abbreviations for zsh

   ${text_bold}Synopsis${text_reset}
       ${text_bold}abbr${text_reset} --add|-a [SCOPE] ABBREVIATION EXPANSION
       ${text_bold}abbr${text_reset} --clear-session|-c [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --erase|-e [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --expand|-x ABBREVIATION
       ${text_bold}abbr${text_reset} --git-populate|-i [SCOPE]
       ${text_bold}abbr${text_reset} --list|-l
       ${text_bold}abbr${text_reset} --output-aliases|-o [SCOPE] [DESTINATION]
       ${text_bold}abbr${text_reset} --populate|-p [SCOPE]
       ${text_bold}abbr${text_reset} --rename|-r [SCOPE] OLD_ABBREVIATION NEW
       ${text_bold}abbr${text_reset} --show|-s

       ${text_bold}abbr${text_reset} --help|-h
       ${text_bold}abbr${text_reset} --version|-v

   ${text_bold}Description${text_reset}
       ${text_bold}abbr${text_reset} manages abbreviations - user-defined words
       that are replaced with longer phrases after they are entered.

       For example, a frequently-run command like git checkout can be
       abbreviated to gco. After entering gco and pressing [${text_bold}Space${text_reset}],
       the full text git checkout will appear in the command line.

       To prevent expansion, press [${text_bold}CTRL-SPACE${text_reset}] in place of [${text_bold}SPACE${text_reset}].

   ${text_bold}Options${text_reset}
       The following options are available:

       o --add ABBREVIATION EXPANSION or -a ABBREVIATION EXPANSION Adds a new
         abbreviation, causing ABBREVIATION to be expanded to EXPANSION.

       o --clear-session or -E Erases all session abbreviations.

       o --erase ABBREVIATION or -e ABBREVIATION Erases the
         abbreviation ABBREVIATION.

       o --expand ABBREVIATION or -x ABBREVIATION Returns the abbreviation
         ABBREVIATION's EXPANSION.

       o --git-populate or -i Adds abbreviations for all git aliases.
         ABBREVIATIONs are prefixed with g, EXPANSIONs are prefixed
         with git[Space].

       o --help or -h Show this documentation.

       o --list -l Lists all ABBREVIATIONs.

       o --output-aliases [-g] [DESTINATION_FILE] or -o [-g] [DESTINATION_FILE]
         Outputs a list of alias command for user abbreviations, suitable
         for pasting or piping to whereever you keep aliases. Add -g to output
         alias commands for session abbreviations. If a DESTINATION_FILE is
         provided, the commands will be appended to it.

       o --populate or -p Adds abbreviations for all aliases.

       o --rename OLD_ABBREVIATION NEW_ABBREVIATION
         or -r OLD_ABBREVIATION NEW_ABBREVIATION Renames an abbreviation,
         from OLD_ABBREVIATION to NEW_ABBREVIATION.

       o --show or -s Show all abbreviations in a manner suitable for export
         and import.

       o --version or -v Show the current version.

       In addition, when adding abbreviations, erasing, outputting aliases,
       [git] populating, or renaming use

       o --session or -S to create a session abbreviation, available only in the
         current session.

       o --user or -U to create a user abbreviation (default),
         immediately available to all sessions.

       See the 'Internals' section for more on them.

   ${text_bold}Examples${text_reset}
       ${text_bold}abbr${text_reset} -a -g gco git checkout
       ${text_bold}abbr${text_reset} --add --session gco git checkout

         Add a new abbreviation where gco will be replaced with git checkout
         session to the current shell. This abbreviation will not be
         automatically visible to other shells unless the same command is run
         in those shells.

       ${text_bold}abbr${text_reset} -- g- git checkout -

         If the EXPANSION includes a hyphen (-), the --add command\'s
         entire EXPANSION must be quoted.

       ${text_bold}abbr${text_reset} -a l less
       ${text_bold}abbr${text_reset} --add l less

         Add a new abbreviation where l will be replaced with less user so
         all shells. Note that you omit the -U since it is the default.

       ${text_bold}abbr${text_reset} -o -g
       ${text_bold}abbr${text_reset} --output-aliases -session

         Output alias declaration commands for each *session* abbreviation.
         Output lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} -o
       ${text_bold}abbr${text_reset} --output-aliases

         Output alias declaration commands for each *user* abbreviation.
         Output lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} -o ~/aliases
       ${text_bold}abbr${text_reset} --output-aliases ~/aliases

         Add alias definitions to ~/aliases

       ${text_bold}abbr${text_reset} -e -g gco
       ${text_bold}abbr${text_reset} --erase --session gco

         Erase the session gco abbreviation.

       ${text_bold}abbr${text_reset} -r -g gco gch
       ${text_bold}abbr${text_reset} --rename --session gco gch

         Rename the existing session abbreviation from gco to gch.

       ${text_bold}abbr${text_reset} -r l le
       ${text_bold}abbr${text_reset} --rename l le

        Rename the existing user abbreviation from l to le. Note that you
        can omit the -U since it is the default.

       ${text_bold}abbr${text_reset} -x gco
       \$(${text_bold}abbr${text_reset} -expand gco)

         Output the expansion for gco (in the above --add example,
         git checkout). Useful in scripting.

   ${text_bold}Internals${text_reset}
       The ABBREVIATION cannot contain IFS whitespace, comma (,), semicolon (;),
       pipe (|), or ampersand (&).

       Defining an abbreviation with session scope is slightly faster than
       user scope (which is the default).

       You can create abbreviations interactively and they will be visible to
       other zsh sessions if you use the -U flag or don't explicitly specify
       the scope. If you want it to be visible only to the current shell
       use the -g flag.

       The options add, output-aliases, erase, expand, git-populate, list,
       populate, rename, and show are mutually exclusive, as are the session
       and user scopes.

       $version $release_date"
    version="zsh-abbr version 2.1.3"

    function add() {
      if [[ $# -lt 2 ]]; then
        util_error " add: Requires at least two arguments"
        return
      fi

      util_add $* # must not be quoted
    }

    function clear_session() {
      if [ $# -gt 0 ]; then
        util_error " clear-session: Unexpected argument"
        return
      fi

      ZSH_SESSION_ABBREVIATIONS=()
    }

    function erase() {
      if [ $# -gt 1 ]; then
        util_error " erase: Expected one argument"
        return
      elif [ $# -lt 1 ]; then
        util_error " erase: Erase needs a variable name"
        return
      fi

      if $opt_session; then
        if (( ${+ZSH_SESSION_ABBREVIATIONS[$1]} )); then
          unset "ZSH_SESSION_ABBREVIATIONS[${(b)1}]"
        else
          util_error " erase: No session abbreviation named $1"
          return
        fi
      else
        source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

        if (( ${+ZSH_USER_ABBREVIATIONS[$1]} )); then
          unset "ZSH_USER_ABBREVIATIONS[${(b)1}]"
          util_sync_user
        else
          util_error " erase: No user abbreviation named $1"
          return
        fi
      fi
    }

    function expand() {
      if [ $# -ne 1 ]; then
        printf "expand requires exactly one argument\\n"
        return
      fi

      _zsh_abbr_expansion "$1"
    }

    function git_populate() {
      local git_aliases
      local abbr_git_aliases

      if [ $# -gt 0 ]; then
        util_error " git-populate: Unexpected argument"
        return
      fi

      git_aliases=("${(@f)$(git config --get-regexp '^alias\.')}")
      typeset -A abbr_git_aliases

      for i in $git_aliases; do
        key="${$(echo $i | awk '{print $1;}')##alias.}"
        value="${$(echo $i)##alias.$key }"

        util_add "g$key" "git ${value# }"
      done
    }

    function list() {
      if [ $# -gt 0 ]; then
        util_error " list: Unexpected argument"
        return
      fi

      source "${TMPDIR:-/tmp}/zsh-user-abbreviations"

      print -l ${(k)ZSH_USER_ABBREVIATIONS}
      print -l ${(k)ZSH_SESSION_ABBREVIATIONS}
    }

    function output_aliases() {
      local source
      local alias_definition

      if [ $# -gt 1 ]; then
        util_error " output-aliases: Unexpected argument"
        return
      fi

      if $opt_session; then
        source=ZSH_SESSION_ABBREVIATIONS
      else
        source=ZSH_USER_ABBREVIATIONS
      fi

      util_alias $source
    }

    function populate() {
      if [ $# -gt 0 ]; then
        util_error " populate: Unexpected argument"
        return
      fi

      for abbreviation expansion in ${(kv)aliases}; do
        util_add "$abbreviation" "${expansion# }"
      done
    }

    function print_version() {
      if [ $# -gt 0 ]; then
        util_error " version: Unexpected argument"
        return
      fi

      printf "%s\\n" "$version"
    }

    function rename() {
      local err source
      source="ZSH_SESSION_ABBREVIATIONS"

      if $opt_session; then
        source="ZSH_SESSION_ABBREVIATIONS"
      fi

      if [ $# -ne 2 ]; then
        util_error " rename: Requires exactly two arguments"
        return
      fi

      if [ $(util_exists $1) != true ]; then
        err=" rename: No $(util_type) abbreviation $1 exists."

        if [ $(util_other_exists $1) = true ]; then
          local action other_type
          action="add"
          other_type="session"

          if $opt_session; then
            action="do not use"
            other_type="user"
          fi

          err+=" A $other_type abbrevation named $1 does exist. To rename it, $action the -g/--session option."
        fi

        util_error $err
        return
      fi

      if [ $(util_exists $2) = true ]; then
        util_error " rename: A $(util_type) abbreviation $2 already exists"
      else
        util_rename_modify $1 $2
      fi
    }

    function show() {
      if [ $# -gt 0 ]; then
        util_error " show: Unexpected argument"
        return
      fi

      cat $ZSH_USER_ABBREVIATIONS_PATH

      for abbreviation expansion in ${(kv)ZSH_SESSION_ABBREVIATIONS}; do
        printf "abbr -a -g -- %s %s\\n" "$abbreviation" "$expansion"
      done
    }

    function util_add() {
      local abbreviation
      local expansion
      abbreviation="$1"
      shift
      expansion="$*"

      if [[ $abbreviation != $(_zsh_abbr_last_word $abbreviation) ]]; then
        util_error " add: ABBREVIATION ('$abbreviation') may not contain delimiting prefixes"
        return
      fi

      if [ $(util_exists $abbreviation) = true ]; then
        util_error " add: A $(util_type) abbreviation $abbreviation already exists"
        return
      fi

      if $opt_session; then
        ZSH_SESSION_ABBREVIATIONS[$abbreviation]="$expansion"
      else
        source "${TMPDIR:-/tmp}/zsh-user-abbreviations"
        ZSH_USER_ABBREVIATIONS[$abbreviation]="$expansion"
        util_sync_user
      fi
    }

    util_alias() {
      for abbreviation expansion in ${(kv)${(P)1}}; do
        alias_definition="alias -g $abbreviation='$expansion'"

        if [ $# -gt 0 ]; then
          echo "$alias_definition" >> "$1"
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

    function util_exists() {
      local abbreviation
      local exists
      exists=false

      if $opt_session; then
        abbreviation="${ZSH_SESSION_ABBREVIATIONS[(I)$1]}"
      else
        abbreviation="${ZSH_USER_ABBREVIATIONS[(I)$1]}"
      fi

      if [[ -n "$abbreviation" ]]; then
        exists=true
      fi

      echo "$exists"
    }

    function util_other_exists() {
      local abbreviation
      local exists
      exists=false

      if $opt_session; then
        abbreviation="${ZSH_USER_ABBREVIATIONS[(I)$1]}"
      else
        abbreviation="${ZSH_SESSION_ABBREVIATIONS[(I)$1]}"
      fi

      if [[ -n "$abbreviation" ]]; then
        exists=true
      fi

      echo "$exists"
    }

    function util_rename_modify {
      if $opt_session; then
        util_add "$2" "${ZSH_SESSION_ABBREVIATIONS[$1]}"
        unset "ZSH_SESSION_ABBREVIATIONS[${(b)1}]"
      else
        util_add "$2" "${ZSH_USER_ABBREVIATIONS[$1]}"
        unset "ZSH_USER_ABBREVIATIONS[${(b)1}]"
        util_sync_user
      fi
    }

    function util_sync_user() {
      local user_updated

      if [ "$ZSH_ABBR_SYNC_USER" = false ]; then
        return
      fi

      user_updated="${TMPDIR:-/tmp}/zsh-user-abbreviations"_updated

      typeset -p ZSH_USER_ABBREVIATIONS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"

      rm "$user_updated" 2> /dev/null
      touch "$user_updated"
      chmod 600 "$user_updated"

      for abbreviation expansion in ${(kv)ZSH_USER_ABBREVIATIONS}; do
        echo "abbr -a -U -- $abbreviation $expansion" >> "$user_updated"
      done

      mv "$user_updated" "$ZSH_USER_ABBREVIATIONS_PATH"
    }

    function util_type() {
      local type
      type="user"

      if $opt_session; then
        type="session"
      fi

      echo $type
    }

    function util_usage() {
      print "$util_usage\\n"
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
        "--help"|\
        "-h")
          util_usage
          should_exit=true
          ;;
        "--git-populate"|\
        "-i")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_git_populate=true
          ((number_opts++))
          ;;
        "--list"|\
        "-l")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_list=true
          ((number_opts++))
          ;;
        "--output-aliases"|\
        "-o")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_output_aliases=true
          ((number_opts++))
          ;;
        "--populate"|\
        "-p")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_populate=true
          ((number_opts++))
          ;;
        "--rename"|\
        "-r")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_rename=true
          ((number_opts++))
          ;;
        "--session"|\
        "-S")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
          opt_session=true
          ((number_opts++))
          ;;
        "--show"|\
        "-s")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_show=true
          ((number_opts++))
          ;;
        "--user"|\
        "-U")
          [ "$scope_set" = true ] && util_bad_options
          scope_set=true
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

    if ! $opt_session; then
      opt_user=true
    fi

    if $opt_add; then
       add "$@"
    elif $opt_clear_session; then
      clear_session "$@"
    elif $opt_erase; then
      erase "$@"
    elif $opt_expand; then
      expand "$@"
    elif $opt_git_populate; then
      git_populate "$@"
    elif $opt_list; then
      list "$@"
    elif $opt_output_aliases; then
      output_aliases "$@"
    elif $opt_populate; then
      populate "$@"
    elif $opt_print_version; then
      print_version "$@"
    elif $opt_rename; then
      rename "$@"

    # default if arguments are provided
    elif ! $opt_show && [ $# -gt 0 ]; then
       add "$@"
    # default if no argument is provided
    else
      show "$@"
    fi
  } always {
    unfunction -m "add"
    unfunction -m "util_bad_options"
    unfunction -m "clear_session"
    unfunction -m "erase"
    unfunction -m "expand"
    unfunction -m "git_populate"
    unfunction -m "list"
    unfunction -m "output_aliases"
    unfunction -m "populate"
    unfunction -m "print_version"
    unfunction -m "rename"
    unfunction -m "show"
    unfunction -m "util_add"
    unfunction -m "util_alias"
    unfunction -m "util_error"
    unfunction -m "util_exists"
    unfunction -m "util_other_exists"
    unfunction -m "util_rename_modify"
    unfunction -m "util_sync_user"
    unfunction -m "util_type"
    unfunction -m "util_usage"
  }
}

_zsh_abbr_bind_widgets() {
  # spacebar expands abbreviations
  zle -N _zsh_abbr_expand_space
  bindkey " " _zsh_abbr_expand_space

  # control-spacebar is a normal space
  bindkey "^ " magic-space

  # when running an incremental search,
  # spacebar behaves normally and control-space expands abbreviations
  bindkey -M isearch "^ " _zsh_abbr_expand_space
  bindkey -M isearch " " magic-space

  # enter key expands and accepts abbreviations
  zle -N _zsh_abbr_expand_accept
  bindkey "^M" _zsh_abbr_expand_accept
}

_zsh_abbr_last_word() {
  # delimited by `&&`, `|`, `;`, and whitespace
  echo ${${1//*(\&\&|[;\|[:IFSSPACE:]])}}
}

_zsh_abbr_expand_accept() {
  zle _zsh_abbr_expand_widget
  zle accept-line
}

_zsh_abbr_expand_space() {
  zle _zsh_abbr_expand_widget
  zle self-insert
}

_zsh_abbr_expansion() {
  local expansion
  expansion="${ZSH_SESSION_ABBREVIATIONS[$1]}"

  if [[ ! -n $expansion ]]; then
    source "${TMPDIR:-/tmp}/zsh-user-abbreviations"
    expansion="${ZSH_USER_ABBREVIATIONS[$1]}"
  fi

  echo "$expansion"
}

_zsh_abbr_init() {
  local line
  local shwordsplit_off
  shwordsplit_off=false

  ZSH_ABBR_SYNC_USER=false

  typeset -gA ZSH_USER_ABBREVIATIONS
  typeset -gA ZSH_SESSION_ABBREVIATIONS
  ZSH_USER_ABBREVIATIONS=()
  ZSH_SESSION_ABBREVIATIONS=()

  if [[ $options[shwordsplit] = off ]]; then
    shwordsplit_off=true
  fi

  # Scratch file
  rm "${TMPDIR:-/tmp}/zsh-user-abbreviations" 2> /dev/null
  touch "${TMPDIR:-/tmp}/zsh-user-abbreviations"
  chmod 600 "${TMPDIR:-/tmp}/zsh-user-abbreviations"

  # Load saved user abbreviations
  if [ -f "$ZSH_USER_ABBREVIATIONS_PATH" ]; then
    setopt shwordsplit
    while read -r line; do
      $line
    done < $ZSH_USER_ABBREVIATIONS_PATH
    unset ZSH_ABBR_SYNC_USER

    # reset if necessary
    if [ $shwordsplit_off = true ]; then
      unsetopt shwordsplit
    fi
  else
    mkdir -p $(dirname "$ZSH_USER_ABBREVIATIONS_PATH")
    touch "$ZSH_USER_ABBREVIATIONS_PATH"
  fi

  typeset -p ZSH_USER_ABBREVIATIONS > "${TMPDIR:-/tmp}/zsh-user-abbreviations"
}


# WIDGETS
# -------

_zsh_abbr_expand_widget() {
  local current_word
  local expansion

  current_word=$(_zsh_abbr_last_word "$LBUFFER")
  expansion=$(_zsh_abbr_expansion "$current_word")

  if [[ -n "$expansion" ]]; then
    local preceding_lbuffer
    preceding_lbuffer="${LBUFFER%%$current_word}"
    LBUFFER="$preceding_lbuffer$expansion"
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

if [ "$ZSH_ABBR_DEFAULT_BINDINGS" = true ]; then
  _zsh_abbr_bind_widgets
fi

