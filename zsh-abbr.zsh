# fish shell-like abbreviation management for zsh.
# https://github.com/olets/zsh-abbr
# v1.2.0
# Copyright (c) 2019-2020 Henry Bley-Vroman


# CONFIGURATION
# -------------

# File abbreviations are stored in
ZSH_ABBR_UNIVERSALS_PATH="${ZSH_ABBR_UNIVERSALS_PATH="${HOME}/.config/zsh-abbr/universal"}"
# Whether to add default bindings (expand on SPACE, expand and accept on ENTER,
# add CTRL for normal SPACE/ENTER; in incremental search mode expand on CTRL+SPACE)
ZSH_ABBR_DEFAULT_BINDINGS="${ZSH_ABBR_DEFAULT_BINDINGS=true}"

# INITIALIZE
# ----------

typeset -gA ZSH_ABBR_UNIVERSALS
typeset -gA ZSH_ABBR_GLOBALS
ZSH_ABBR_UNIVERSALS=()
ZSH_ABBR_GLOBALS=()

# Load saved universal abbreviations
if [ -f "$ZSH_ABBR_UNIVERSALS_PATH" ]; then
  while read -r abbreviation expansion; do
    ZSH_ABBR_UNIVERSALS[$abbreviation]="$expansion"
  done < "$ZSH_ABBR_UNIVERSALS_PATH"
else
  mkdir -p $(dirname "$ZSH_ABBR_UNIVERSALS_PATH")
  touch "$ZSH_ABBR_UNIVERSALS_PATH"
fi

# Scratch file
ZSH_ABBR_UNIVERSALS_SCRATCH_FILE="${TMPDIR}/abbr_universals"

rm "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE" 2> /dev/null
mktemp "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE" 1> /dev/null
typeset -p ZSH_ABBR_UNIVERSALS > "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

# Bind
if [ "$ZSH_ABBR_DEFAULT_BINDINGS" = true ]; then
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
fi


# INTERNAL FUNCTIONS
# ------------------

function _zsh_abbr_expand_accept() {
  zle _zsh_abbr_expand_widget
  zle autosuggest-clear # if using zsh-autosuggestions, clear any suggestion
  zle accept-line
}

function _zsh_abbr_expand_space() {
  zle _zsh_abbr_expand_widget
  LBUFFER="$LBUFFER "
}

function _zsh_abbr_expansion() {
  local expansion
  expansion="${ZSH_ABBR_GLOBALS[$1]}"

  if [[ ! -n $expansion ]]; then
    source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"
    expansion="${ZSH_ABBR_UNIVERSALS[$1]}"
  fi

  echo "$expansion"
}


# WIDGETS
# -------

function _zsh_abbr_expand_widget() {
  local current_word
  local expansion

  current_word="${LBUFFER/*[ ,;|&]/}"
  expansion=$(_zsh_abbr_expansion "$current_word")

  if [[ -n "$expansion" ]]; then
    local preceding_lbuffer="${LBUFFER%%$current_word}"
    LBUFFER="$preceding_lbuffer$expansion"
    _zsh_highlight # if using zsh-syntax-highlighting, update the highlighting
  fi
}

zle -N _zsh_abbr_expand_widget


# SHARED FUNCTIONS
# ----------------

function abbr() {
  {
    local text_bold="\\033[1m"
    local text_reset="\\033[0m"

    local abbr_action_set=false
    local abbr_number_opts=0
    local abbr_opt_add=false
    local abbr_opt_create_aliases=false
    local abbr_opt_erase=false
    local abbr_opt_expand=false
    local abbr_opt_git_populate=false
    local abbr_opt_global=false
    local abbr_opt_list=false
    local abbr_opt_rename=false
    local abbr_opt_show=false
    local abbr_opt_populate=false
    local abbr_opt_universal=false
    local abbr_scope_set=false
    local abbr_should_exit=false
    local abbr_usage="
       ${text_bold}abbr${text_reset}: fish shell-like abbreviations for zsh

   ${text_bold}Synopsis${text_reset}
       ${text_bold}abbr${text_reset} --add|-a [SCOPE] ABBREVIATION EXPANSION
       ${text_bold}abbr${text_reset} --create-aliases|-c [SCOPE] [DESTINATION_FILE]
       ${text_bold}abbr${text_reset} --erase|-e [SCOPE] ABBREVIATION
       ${text_bold}abbr${text_reset} --expand|-x ABBREVIATION
       ${text_bold}abbr${text_reset} --git-populate|-i [SCOPE]
       ${text_bold}abbr${text_reset} --rename|-r [SCOPE] OLD_WORD NEW_WORD
       ${text_bold}abbr${text_reset} --show|-s
       ${text_bold}abbr${text_reset} --list|-l
       ${text_bold}abbr${text_reset} --populate|-p [SCOPE]
       ${text_bold}abbr${text_reset} --help|-h

   ${text_bold}Description${text_reset}
       ${text_bold}abbr${text_reset} manages abbreviations - user-defined words that are
       replaced with longer phrases after they are entered.

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

       o --expand ABBREVIATION or -x ABBREVIATION Returns the abbreviation
         ABBREVIATION's EXPANSION.

       o --git-populate or -i Adds abbreviations for all git aliases. WORDs are
         prefixed with g, EXPANSIONs are prefixed with git[Space].

       o --list -l Lists all abbreviated words.

       o --populate or -p Adds abbreviations for all aliases.

       o --rename OLD_WORD NEW_WORD or -r OLD_WORD NEW_WORD Renames an
         abbreviation, from OLD_WORD to NEW_WORD.

       o --show or -s Show all abbreviations in a manner suitable for export
         and import.

       In addition, when adding abbreviations use

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

       ${text_bold}abbr${text_reset} -x gco
       \$(${text_bold}abbr${text_reset} -x gco)

         Output the expansion for gco (in the above --add example,
         git checkout). Useful in scripting.

       ${text_bold}abbr${text_reset} -r -g gco gch
       ${text_bold}abbr${text_reset} --rename --global gco gch

         Rename the existing global abbreviation from gco to gch.

       ${text_bold}abbr${text_reset} -r l le
       ${text_bold}abbr${text_reset} --rename l le

        Rename the existing universal abbreviation from l to le. Note that you
        can omit the -U since it is the default.

   ${text_bold}Internals${text_reset}
       The ABBREVIATION cannot contain a space but all other characters are legal.

       Defining an abbreviation with global scope is slightly faster than
       universal scope (which is the default).

       You can create abbreviations interactively and they will be visible to
       other zsh sessions if you use the -U flag or don't explicitly specify
       the scope. If you want it to be visible only to the current shell
       use the -g flag.

       The options -a -c -e -r -s -l -p and -i are mutually exclusive,
       as are the scope options -g and -U.

       The function abbr_expand is available to return an abbreviation's
       expansion. The result is the global expansion if one exists, otherwise
       the universal expansion if one exists.

       Version 1.2.0 January 12 2020"

    function abbr_add() {
      if [[ $# -lt 2 ]]; then
        abbr_error " add: Requires at least two arguments"
        return
      fi

      abbr_util_add $* # must not be quoted
    }

    function abbr_bad_options() {
      abbr_error ": Illegal combination of options"
    }

    function abbr_create_aliases() {
      local source
      local alias_definition

      if [ $# -gt 1 ]; then
        abbr_error " create-aliases: Unexpected argument"
        return
      fi

      if $abbr_opt_global; then
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

    function abbr_erase() {
      if [ $# -gt 1 ]; then
        abbr_error " erase: Expected one argument"
        return
      elif [ $# -lt 1 ]; then
        abbr_error " erase: Erase needs a variable name"
        return
      fi

      if $abbr_opt_global; then
        if (( ${+ZSH_ABBR_GLOBALS[$1]} )); then
          unset "ZSH_ABBR_GLOBALS[${(b)1}]"
        else
          abbr_error " erase: No global abbreviation named $1"
          return
        fi
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

        if (( ${+ZSH_ABBR_UNIVERSALS[$1]} )); then
          unset "ZSH_ABBR_UNIVERSALS[${(b)1}]"
          abbr_sync_universal
        else
          abbr_error " erase: No universal abbreviation named $1"
          return
        fi
      fi
    }

    function abbr_error() {
      printf "abbr%s\\nFor help run abbr --help\\n" "$@"
      abbr_should_exit=true
    }

    function abbr_expand() {
      if [ $# -ne 1 ]; then
        printf "abbr_expand requires exactly one argument\\n"
        return
      fi

      _zsh_abbr_expansion "$1"
    }

    function abbr_git_populate() {
      local git_aliases
      local abbr_git_aliases

      if [ $# -gt 0 ]; then
        abbr_error " git-populate: Unexpected argument"
        return
      fi

      git_aliases=("${(@f)$(git config --get-regexp '^alias\.')}")
      typeset -A abbr_git_aliases

      for i in $git_aliases; do
        key="${$(echo $i | awk '{print $1;}')##alias.}"
        value="${$(echo $i)##alias.$key }"

        abbr_util_add "g$key" "git ${value# }"
      done
    }

    function abbr_list() {
      if [ $# -gt 0 ]; then
        abbr_error " list: Unexpected argument"
        return
      fi

      source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

      print -l ${(k)ZSH_ABBR_UNIVERSALS}
      print -l ${(k)ZSH_ABBR_GLOBALS}
    }

    function abbr_populate() {
      if [ $# -gt 0 ]; then
        abbr_error " populate: Unexpected argument"
        return
      fi

      for abbreviation expansion in ${(kv)aliases}; do
        abbr_util_add "$abbreviation" "${expansion# }"
      done
    }

    function abbr_rename() {
      local source type
      source="ZSH_ABBR_GLOBALS"
      type="universal"

      if $abbr_opt_global; then
        source="ZSH_ABBR_GLOBALS"
        type="global"
      fi

      if [ $# -ne 2 ]; then
        abbr_error " rename: Requires exactly two arguments"
        return
      fi

      if [ $(abbr_util_exists $1) != true ]; then
        abbr_error " rename: No $type abbreviation $1 exists"
        return
      fi

      if [ $(abbr_util_exists $2) = true ]; then
        abbr_error " rename: A $type abbreviation $2 already exists"
      else
        abbr_rename_modify $1 $2
      fi
    }

    function abbr_rename_modify {
      if $abbr_opt_global; then
        if (( ${+ZSH_ABBR_GLOBALS[$1]} )); then
          abbr_util_add "$2" "${ZSH_ABBR_GLOBALS[$1]}"
          unset "ZSH_ABBR_GLOBALS[${(b)1}]"
        else
          abbr_error " rename: No global abbreviation named $1"
        fi
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

        if (( ${+ZSH_ABBR_UNIVERSALS[$1]} )); then
          abbr_util_add "$2" "${ZSH_ABBR_UNIVERSALS[$1]}"
          unset "ZSH_ABBR_UNIVERSALS[${(b)1}]"
          abbr_sync_universal
        else
          abbr_error " rename: No universal abbreviation named $1"
        fi
      fi
    }

    function abbr_show() {
      if [ $# -gt 0 ]; then
        abbr_error " show: Unexpected argument"
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

    function abbr_sync_universal() {
      local abbr_universals_updated="$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"_updated

      typeset -p ZSH_ABBR_UNIVERSALS > "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"

      rm "$abbr_universals_updated" 2> /dev/null
      mktemp "$abbr_universals_updated" 1> /dev/null

      for abbreviation expansion in ${(kv)ZSH_ABBR_UNIVERSALS}; do
        echo "$abbreviation $expansion" >> "$abbr_universals_updated"
      done

      mv "$abbr_universals_updated" "$ZSH_ABBR_UNIVERSALS_PATH"
    }

    function abbr_usage() {
      print "$abbr_usage\\n"
    }

    function abbr_util_add() {
      local abbreviation
      local expansion
      abbreviation="$1"
      shift
      expansion="$*"

      if [ $(abbr_util_exists $abbreviation) = true ]; then
        local type
        type="universal"

        if $abbr_opt_global; then
          type="global"
        fi

        abbr_error " add: A $type abbreviation $abbreviation already exists"
        return
      fi

      if $abbr_opt_global; then
        ZSH_ABBR_GLOBALS[$abbreviation]="$expansion"
      else
        source "$ZSH_ABBR_UNIVERSALS_SCRATCH_FILE"
        ZSH_ABBR_UNIVERSALS[$abbreviation]="$expansion"
        abbr_sync_universal
      fi
    }

    function abbr_util_exists() {
      local abbreviation
      local exists
      exists=false

      if $abbr_opt_global; then
        abbreviation="${ZSH_ABBR_GLOBALS[(I)$1]}"
      else
        abbreviation="${ZSH_ABBR_UNIVERSALS[(I)$1]}"
      fi

      if [[ -n "$abbreviation" ]]; then
        exists=true
      fi

      echo "$exists"
    }

    for opt in "$@"; do
      if $abbr_should_exit; then
        abbr_should_exit=false
        return
      fi

      case "$opt" in
        "--add"|\
        "-a")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_add=true
          ((abbr_number_opts++))
          ;;
        "--create-aliases"|\
        "-c")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_create_aliases=true
          ((abbr_number_opts++))
          ;;
        "--erase"|\
        "-e")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_erase=true
          ((abbr_number_opts++))
          ;;
        "--expand"|\
        "-x")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_expand=true
          ((abbr_number_opts++))
          ;;
        "--global"|\
        "-g")
          [ "$abbr_scope_set" = true ] && abbr_bad_options
          abbr_opt_global=true
          ((abbr_number_opts++))
          ;;
        "--help"|\
        "-h")
          abbr_usage
          abbr_should_exit=true
          ;;
        "--git-populate"|\
        "-i")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_git_populate=true
          ((abbr_number_opts++))
          ;;
        "--list"|\
        "-l")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_list=true
          ((abbr_number_opts++))
          ;;
        "--populate"|\
        "-p")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_populate=true
          ((abbr_number_opts++))
          ;;
        "--rename"|\
        "-r")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_rename=true
          ((abbr_number_opts++))
          ;;
        "--show"|\
        "-s")
          [ "$abbr_action_set" = true ] && abbr_bad_options
          abbr_action_set=true
          abbr_opt_show=true
          ((abbr_number_opts++))
          ;;
        "--universal"|\
        "-U")
          [ "$abbr_scope_set" = true ] && abbr_bad_options
          ((abbr_number_opts++))
          ;;
        "-"*)
          abbr_error ": Unknown option '$opt'"
          ;;
      esac
    done

    if $abbr_should_exit; then
      abbr_should_exit=false
      return
    fi

    shift $abbr_number_opts

    if ! $abbr_opt_global; then
      abbr_opt_universal=true
    fi

    if $abbr_opt_add; then
       abbr_add "$@"
    elif $abbr_opt_create_aliases; then
      abbr_create_aliases "$@"
    elif $abbr_opt_erase; then
      abbr_erase "$@"
    elif $abbr_opt_expand; then
      abbr_expand "$@"
    elif $abbr_opt_git_populate; then
      abbr_git_populate "$@"
    elif $abbr_opt_list; then
      abbr_list "$@"
    elif $abbr_opt_populate; then
      abbr_populate "$@"
    elif $abbr_opt_rename; then
      abbr_rename "$@"

    # default if arguments are provided
    elif ! $abbr_opt_show && [ $# -gt 0 ]; then
       abbr_add "$@"
    # default if no argument is provided
    else
      abbr_show "$@"
    fi
  } always {
    unfunction -m "abbr_add"
    unfunction -m "abbr_create_aliases"
    unfunction -m "abbr_erase"
    unfunction -m "abbr_error"
    unfunction -m "abbr_expand"
    unfunction -m "abbr_git_populate"
    unfunction -m "abbr_check_options"
    unfunction -m "abbr_list"
    unfunction -m "abbr_rename"
    unfunction -m "abbr_rename_modify"
    unfunction -m "abbr_show"
    unfunction -m "abbr_sync_universal"
    unfunction -m "abbr_usage"
    unfunction -m "abbr_util_add"
    unfunction -m "abbr_util_exists"
  }
}
