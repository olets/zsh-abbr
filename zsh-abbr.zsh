# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v2.0.0
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=true}"

# The non-whitespace characters which are considered a word break for purposes
# of recognizing abbreviations.
ZSH_ABBR_DELIMITING_PREFIXES="${ZSH_ABBR_DELIMITING_PREFIXES=',;|&[:IFSSPACE:]'}"

# File abbreviations are stored in
ZSH_ABBR_UNIVERSALS_FILE="${ZSH_ABBR_UNIVERSALS_FILE="${HOME}/.config/zsh/universal-abbreviations"}"


# FUNCTIONS
# ---------

_zsh_abbr() {
  {
    local action_set=false
    local number_opts=0
    local opt_add=false
    local opt_create_aliases=false
    local opt_erase_all_globals=false
    local opt_erase=false
    local opt_expand=false
    local opt_git_populate=false
    local opt_global=false
    local opt_list=false
    local opt_rename=false
    local opt_show=false
    local opt_populate=false
    local opt_universal=false
    local opt_print_version=false
    local release_date="January 19 2020"
    local scope_set=false
    local should_exit=false
    local text_bold="\\033[1m"
    local text_reset="\\033[0m"
    local util_usage="
       ${text_bold}abbr${text_reset}: fish shell-like abbreviations for zsh

   ${text_bold}Synopsis${text_reset}
       ${text_bold}abbr${text_reset} --add|-a [SCOPE] ABBREVIATION EXPANSION
       ${text_bold}abbr${text_reset} --create-aliases|-c [SCOPE] [DESTINATION]
       ${text_bold}abbr${text_reset} --erase|-e [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --expand|-x ABBREVIATION
       ${text_bold}abbr${text_reset} --git-populate|-i [SCOPE]
       ${text_bold}abbr${text_reset} --list|-l
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

       o --create-aliases [-g] [DESTINATION_FILE] or -c [-g] [DESTINATION_FILE]
         Outputs a list of alias command for universal abbreviations, suitable
         for pasting or piping to whereever you keep aliases. Add -g to output
         alias commands for global abbreviations. If a DESTINATION_FILE is
         provided, the commands will be appended to it.

       o --erase ABBREVIATION or -e ABBREVIATION Erases the
         abbreviation ABBREVIATION.

       o --erase-all-globals or -E Erases all global abbreviations.

       o --expand ABBREVIATION or -x ABBREVIATION Returns the abbreviation
         ABBREVIATION's EXPANSION.

       o --git-populate or -i Adds abbreviations for all git aliases.
         ABBREVIATIONs are prefixed with g, EXPANSIONs are prefixed
         with git[Space].

       o --help or -h Show this documentation.

       o --list -l Lists all ABBREVIATIONs.

       o --populate or -p Adds abbreviations for all aliases.

       o --rename OLD_ABBREVIATION NEW_ABBREVIATION
         or -r OLD_ABBREVIATION NEW_ABBREVIATION Renames an abbreviation,
         from OLD_ABBREVIATION to NEW_ABBREVIATION.

       o --show or -s Show all abbreviations in a manner suitable for export
         and import.

       o --version or -v Show the current version.

       In addition, when adding abbreviations, creating aliases, erasing,
       [git] populating, or renaming use

       o --global or -g to create a global abbreviation, available only in the
         current session.

       o --universal or -U to create a universal abbreviation (default),
         immediately available to all sessions.

       See the 'Internals' section for more on them.

   ${text_bold}Examples${text_reset}
       ${text_bold}abbr${text_reset} -a -g gco git checkout
       ${text_bold}abbr${text_reset} --add --global gco git checkout

         Add a new abbreviation where gco will be replaced with git checkout
         global to the current shell. This abbreviation will not be
         automatically visible to other shells unless the same command is run
         in those shells.

       ${text_bold}abbr${text_reset} g- \'git checkout -\'

         If the EXPANSION includes a hyphen (-), the --add command\'s
         entire EXPANSION must be quoted.

       ${text_bold}abbr${text_reset} -a l less
       ${text_bold}abbr${text_reset} --add l less

         Add a new abbreviation where l will be replaced with less universal so
         all shells. Note that you omit the -U since it is the default.

       ${text_bold}abbr${text_reset} -c -g
       ${text_bold}abbr${text_reset} --create-aliases -global

         Output alias declaration commands for each *global* abbreviation.
         Output lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} -c
       ${text_bold}abbr${text_reset} --create-aliases

         Output alias declaration commands for each *universal* abbreviation.
         Output lines look like alias -g <ABBREVIATION>='<EXPANSION>'

       ${text_bold}abbr${text_reset} -c ~/aliases
       ${text_bold}abbr${text_reset} --create-aliases ~/aliases

         Add alias definitions to ~/aliases

       ${text_bold}abbr${text_reset} -e -g gco
       ${text_bold}abbr${text_reset} --erase --global gco

         Erase the global gco abbreviation.

       ${text_bold}abbr${text_reset} -r -g gco gch
       ${text_bold}abbr${text_reset} --rename --global gco gch

         Rename the existing global abbreviation from gco to gch.

       ${text_bold}abbr${text_reset} -r l le
       ${text_bold}abbr${text_reset} --rename l le

        Rename the existing universal abbreviation from l to le. Note that you
        can omit the -U since it is the default.

       ${text_bold}abbr${text_reset} -x gco
       \$(${text_bold}abbr${text_reset} -expand gco)

         Output the expansion for gco (in the above --add example,
         git checkout). Useful in scripting.

   ${text_bold}Internals${text_reset}
       The ABBREVIATION cannot contain IFS whitespace, comma (,), semicolon (;),
       pipe (|), or ampersand (&).

       Defining an abbreviation with global scope is slightly faster than
       universal scope (which is the default).

       You can create abbreviations interactively and they will be visible to
       other zsh sessions if you use the -U flag or don't explicitly specify
       the scope. If you want it to be visible only to the current shell
       use the -g flag.

       The options add, create-aliases, erase, expand, git-populate, list,
       populate, rename, and show are mutually exclusive, as are the global
       and universal scopes.

       $version $release_date"
    local version="zsh-abbr version 2.0.0"

    function add() {
      if [[ $# -lt 2 ]]; then
        util_error " add: Requires at least two arguments"
        return
      fi

      util_add $* # must not be quoted
    }

    function create_aliases() {
      local source
      local alias_definition

      if [ $# -gt 1 ]; then
        util_error " create-aliases: Unexpected argument"
        return
      fi

      if $opt_global; then
        source=ZSH_ABBR_GLOBALS
      else
        source=ZSH_ABBR_UNIVERSALS
      fi

      for abbreviation expansion in ${(kv)${(P)source}}; do
        alias_definition="alias -g $abbreviation='$expansion'"

        if [ $# -gt 0 ]; then
          echo "$alias_definition" >> "$1"
        else
          print "$alias_definition"
        fi
      done
    }

    function erase() {
      if [ $# -gt 1 ]; then
        util_error " erase: Expected one argument"
        return
      elif [ $# -lt 1 ]; then
        util_error " erase: Erase needs a variable name"
        return
      fi

      if $opt_global; then
        if (( ${+ZSH_ABBR_GLOBALS[$1]} )); then
          unset "ZSH_ABBR_GLOBALS[${(b)1}]"
        else
          util_error " erase: No global abbreviation named $1"
          return
        fi
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

        if (( ${+ZSH_ABBR_UNIVERSALS[$1]} )); then
          unset "ZSH_ABBR_UNIVERSALS[${(b)1}]"
          util_sync_universal
        else
          util_error " erase: No universal abbreviation named $1"
          return
        fi
      fi
    }

    function erase_all_globals() {
      if [ $# -gt 0 ]; then
        util_error " erase-all-globals: Unexpected argument"
        return
      fi

      ZSH_ABBR_GLOBALS=()
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

      source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

      print -l ${(k)ZSH_ABBR_UNIVERSALS}
      print -l ${(k)ZSH_ABBR_GLOBALS}
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
      local source type
      source="ZSH_ABBR_GLOBALS"
      type="universal"

      if $opt_global; then
        source="ZSH_ABBR_GLOBALS"
        type="global"
      fi

      if [ $# -ne 2 ]; then
        util_error " rename: Requires exactly two arguments"
        return
      fi

      if [ $(util_exists $1) != true ]; then
        util_error " rename: No $type abbreviation $1 exists"
        return
      fi

      if [ $(util_exists $2) = true ]; then
        util_error " rename: A $type abbreviation $2 already exists"
      else
        util_rename_modify $1 $2
      fi
    }

    function show() {
      if [ $# -gt 0 ]; then
        util_error " show: Unexpected argument"
        return
      fi

      source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

      for abbreviation expansion in ${(kv)ZSH_ABBR_UNIVERSALS}; do
        printf "abbr -a -U -- %s %s\\n" "$abbreviation" "$expansion"
      done

      for abbreviation expansion in ${(kv)ZSH_ABBR_GLOBALS}; do
        printf "abbr -a -g -- %s %s\\n" "$abbreviation" "$expansion"
      done
    }

    function util_add() {
      local abbreviation
      local expansion
      abbreviation="$1"
      shift
      expansion="$*"

      if [ $(util_exists $abbreviation) = true ]; then
        local type
        type="universal"

        if $opt_global; then
          type="global"
        fi

        util_error " add: A $type abbreviation $abbreviation already exists"
        return
      fi

      if $opt_global; then
        ZSH_ABBR_GLOBALS[$abbreviation]="$expansion"
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"
        ZSH_ABBR_UNIVERSALS[$abbreviation]="$expansion"
        util_sync_universal
      fi
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

      if $opt_global; then
        abbreviation="${ZSH_ABBR_GLOBALS[(I)$1]}"
      else
        abbreviation="${ZSH_ABBR_UNIVERSALS[(I)$1]}"
      fi

      if [[ -n "$abbreviation" ]]; then
        exists=true
      fi

      echo "$exists"
    }

    function util_rename_modify {
      if $opt_global; then
        if (( ${+ZSH_ABBR_GLOBALS[$1]} )); then
          util_add "$2" "${ZSH_ABBR_GLOBALS[$1]}"
          unset "ZSH_ABBR_GLOBALS[${(b)1}]"
        else
          util_error " rename: No global abbreviation named $1"
        fi
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

        if (( ${+ZSH_ABBR_UNIVERSALS[$1]} )); then
          util_add "$2" "${ZSH_ABBR_UNIVERSALS[$1]}"
          unset "ZSH_ABBR_UNIVERSALS[${(b)1}]"
          util_sync_universal
        else
          util_error " rename: No universal abbreviation named $1"
        fi
      fi
    }

    function util_sync_universal() {
      local abbr_universals_updated="$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"_updated

      typeset -p ZSH_ABBR_UNIVERSALS > "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

      rm "$abbr_universals_updated" 2> /dev/null
      mktemp "$abbr_universals_updated" 1> /dev/null

      for abbreviation expansion in ${(kv)ZSH_ABBR_UNIVERSALS}; do
        echo "$abbreviation $expansion" >> "$abbr_universals_updated"
      done

      mv "$abbr_universals_updated" "$ZSH_ABBR_UNIVERSALS_FILE"
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
        "--create-aliases"|\
        "-c")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_create_aliases=true
          ((number_opts++))
          ;;
        "--erase"|\
        "-e")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_erase=true
          ((number_opts++))
          ;;
        "--erase-all-globals"|\
        "-E")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_erase_all_globals=true
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
          [ "$scope_set" = true ] && util_bad_options
          opt_global=true
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
        "--show"|\
        "-s")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_show=true
          ((number_opts++))
          ;;
        "--universal"|\
        "-U")
          [ "$scope_set" = true ] && util_bad_options
          ((number_opts++))
          ;;
        "--version"|\
        "-v")
          [ "$action_set" = true ] && util_bad_options
          action_set=true
          opt_print_version=true
          ((number_opts++))
          ;;
        "-"*)
          util_error ": Unknown option '$opt'"
          ;;
      esac
    done

    if $should_exit; then
      should_exit=false
      return
    fi

    shift $number_opts

    if ! $opt_global; then
      opt_universal=true
    fi

    if $opt_add; then
       add "$@"
    elif $opt_create_aliases; then
      create_aliases "$@"
    elif $opt_erase_all_globals; then
      erase_all_globals "$@"
    elif $opt_erase; then
      erase "$@"
    elif $opt_expand; then
      expand "$@"
    elif $opt_git_populate; then
      git_populate "$@"
    elif $opt_list; then
      list "$@"
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
    unfunction -m "create_aliases"
    unfunction -m "erase"
    unfunction -m "erase-all-globals"
    unfunction -m "expand"
    unfunction -m "git_populate"
    unfunction -m "list"
    unfunction -m "populate"
    unfunction -m "print_version"
    unfunction -m "rename"
    unfunction -m "show"
    unfunction -m "util_add"
    unfunction -m "util_error"
    unfunction -m "util_exists"
    unfunction -m "util_rename_modify"
    unfunction -m "util_sync_universal"
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

_zsh_abbr_expand_accept() {
  zle _zsh_abbr_expand_widget
  zle autosuggest-clear # if using zsh-autosuggestions, clear any suggestion
  zle accept-line
}

_zsh_abbr_expand_space() {
  zle _zsh_abbr_expand_widget
  LBUFFER="$LBUFFER "
}

_zsh_abbr_expansion() {
  local expansion
  expansion="${ZSH_ABBR_GLOBALS[$1]}"

  if [[ ! -n $expansion ]]; then
    source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"
    expansion="${ZSH_ABBR_UNIVERSALS[$1]}"
  fi

  echo "$expansion"
}

_zsh_abbr_init() {
  typeset -gA ZSH_ABBR_UNIVERSALS
  typeset -gA ZSH_ABBR_GLOBALS
  ZSH_ABBR_UNIVERSALS=()
  ZSH_ABBR_GLOBALS=()

  # Load saved universal abbreviations
  if [ -f "$ZSH_ABBR_UNIVERSALS_FILE" ]; then
    while read -r abbreviation expansion; do
      ZSH_ABBR_UNIVERSALS[$abbreviation]="$expansion"
    done < "$ZSH_ABBR_UNIVERSALS_FILE"
  else
    mkdir -p $(dirname "$ZSH_ABBR_UNIVERSALS_FILE")
    touch "$ZSH_ABBR_UNIVERSALS_FILE"
  fi

  # Scratch file
  ZSH_ABBR_UNIVERSALS_SCRATCH_FILE="${TMPDIR}/abbr_universals"

  rm "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE" 2> /dev/null
  mktemp "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE" 1> /dev/null
  typeset -p ZSH_ABBR_UNIVERSALS > "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"
}


# WIDGETS
# -------

_zsh_abbr_expand_widget() {
  local current_word
  local expansion

  current_word="${LBUFFER/*[$ZSH_ABBR_DELIMITING_PREFIXES]/}"
  expansion=$(_zsh_abbr_expansion "$current_word")

  if [[ -n "$expansion" ]]; then
    local preceding_lbuffer="${LBUFFER%%$current_word}"
    LBUFFER="$preceding_lbuffer$expansion"
    _zsh_highlight # if using zsh-syntax-highlighting, update the highlighting
  fi
}

zle -N _zsh_abbr_expand_widget


# INITIALIZATION
# --------------

_zsh_abbr_init
if [ "$ZSH_ABBR_DEFAULT_BINDINGS" = true ]; then
  _zsh_abbr_bind_widgets
fi


# SHARE
# -----

abbr() {
  _zsh_abbr $*
}
