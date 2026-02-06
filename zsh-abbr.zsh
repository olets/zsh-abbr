#!/usr/bin/env zsh

# abbreviation management for zsh, inspired by fish shell and enhanced
# https://github.com/olets/zsh-abbr
# v6.5.1
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

# See ABBR_SET_LINE_CURSOR
typeset -g ABBR_LINE_CURSOR_MARKER=${ABBR_LINE_CURSOR_MARKER:-%}

# See ABBR_SET_EXPANSION_CURSOR
typeset -g ABBR_EXPANSION_CURSOR_MARKER=${ABBR_EXPANSION_CURSOR_MARKER:-$ABBR_LINE_CURSOR_MARKER}

# Behave as if `--force` was passed? (default false)
typeset -gi ABBR_FORCE=${ABBR_FORCE:-0}

# Check whether you could have used an abbreviation? (default false)
# See also ABBR_LOG_AVAILABLE_ABBREVIATION
typeset -gi ABBR_GET_AVAILABLE_ABBREVIATION=${ABBR_GET_AVAILABLE_ABBREVIATION:-0}

# Log anything found by ABBR_GET_AVAILABLE_ABBREVIATION? (default false)
typeset -gi ABBR_LOG_AVAILABLE_ABBREVIATION=${ABBR_LOG_AVAILABLE_ABBREVIATION:-0}

# If ABBR_LOG_AVAILABLE_ABBREVIATION is non-zero, should
# it log come _after_ the command output? (default false)
typeset -gi ABBR_LOG_AVAILABLE_ABBREVIATION_AFTER=${ABBR_LOG_AVAILABLE_ABBREVIATION_AFTER:-0}

# Should abbr-expand-and-accept push the unexpanded line to the shell history? (default false)
# If true, if abbr-expand-and-accept expands an abbreviation there will be two history entries:
# the first is line with the abbreviation, the second is what was run (with the expansion).
# With this caveat: if ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY is true, abbr-expand-and-accept
# will only push the line with the abbreviation to history if it's different from what abbr-expand
# pushed to history. That is, if you
# % abbr a=b
# % a[Enter]
# the history will be
# abbr a=b
# a
# b
# not
# abbr a=b
# a
# a
# b
typeset -gi ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=${ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY:-0}

# Should abbr-expand push the abbreviation to the shell history? (default false)
typeset -gi ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=${ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY:-0}

# Regular abbreviations expand when in command position, even if not at start of line
# Experimental. Currently teats all `;`, `&`, `|`, and all reduplications (e.g. `&&`, `||`) as command delimiters.
#
# 0 to disable (default)
# 1 to enable, with warning on shell startup
# 2 to enable without warning
typeset -gi ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=${ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS:-0}
if (( ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS == 1 )); then
  'builtin' 'print' "abbr: You have set ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=1. This feature is *experimental* and may have unexpected or undesired results. If it graduates from experimental, the variable name will change.\nYou can suppress this message while still enabling the feature by setting\n\n  ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=2\n"
fi

# Limitation: doesn't support changing the option interactively
typeset -g _abbr_hist_ignore_dups
_abbr_hist_ignore_dups=$options[hist_ignore_dups]

# Limitation: doesn't support changing the option interactively
typeset -g _abbr_hist_ignore_space
_abbr_hist_ignore_space=$options[hist_ignore_space]

# Behave as if `--quiet` was passed? (default false)
typeset -gi ABBR_QUIET=${ABBR_QUIET:-0}

# Behave as if `--quieter` was passed? (default false)
typeset -gi ABBR_QUIETER=${ABBR_QUIETER:-0}

# In expansions, replace the first instance of ABBR_LINE_CURSOR_MARKER with the cursor
typeset -gi ABBR_SET_LINE_CURSOR=${ABBR_SET_LINE_CURSOR:-0}

# In expansions, replace the first instance of ABBR_EXPANSION_CURSOR_MARKER with the cursor
typeset -gi ABBR_SET_EXPANSION_CURSOR=${ABBR_SET_EXPANSION_CURSOR:-0}

# Function for splitting strings into abbreviation candidates
# Default: split into words with shell grammar.
# NB in my testing on zsh 5.9 (x86_64-apple-darwin21.3.0),
#     [[ ${${(k)functions}[(Ie)ABBR_SPLIT_FN]} == 0 ]]
# can be significantly more performant than
#     (( ${${(k)functions}[(Ie)ABBR_SPLIT_FN]} == 0 ))
if [[ ${${(k)functions}[(Ie)ABBR_SPLIT_FN]} == 0 ]]; then
  function ABBR_SPLIT_FN() {
    REPLY=( ${(z)*} )
  }
fi

# The directory temp files are stored in
typeset -g _abbr_tmpdir=${${ABBR_TMPDIR:-${${TMPDIR:-/tmp}%/}/zsh-abbr}%/}/
if [[ ${(%):-%#} == '#' ]]; then
  _abbr_tmpdir=${${ABBR_TMPDIR:-${${TMPDIR:-/tmp}%/}/zsh-abbr-privileged-users}%/}/
fi

# The file abbreviations are stored in
typeset -g ABBR_USER_ABBREVIATIONS_FILE=$ABBR_USER_ABBREVIATIONS_FILE
if [[ -z $ABBR_USER_ABBREVIATIONS_FILE ]]; then
  # Legacy support for the zsh-abbr < v5.0.0 default
  ABBR_USER_ABBREVIATIONS_FILE=${XDG_CONFIG_HOME:-$HOME/.config}/zsh/abbreviations

  if [[ ! -f $ABBR_USER_ABBREVIATIONS_FILE ]]; then
    ABBR_USER_ABBREVIATIONS_FILE=${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations
  fi
fi

if [[ ${(t)ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES} == ${${(t)ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES}#array} ]]; then
  typeset -ga ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES=( 'sudo ' )
fi

if [[ ${(t)ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES} == ${${(t)ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES}#array} ]]; then
  typeset -ga ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES=( ' ' )
fi

# FUNCTIONS
# ---------

abbr() {
  emulate -LR zsh

  _abbr_debugger

  {
    local action
    local -a args
    local asterisk
    local -i dry_run
    local error_color
    local -i force
    local -i has_error
    local job_id
    local logs_silent_when_quiet
    local logs_silent_when_quieter
    local opt
    local output
    local -i quiet
    local -i quieter
    local release_date
    local REPLY
    local scope
    local -i should_exit
    local success_color
    local type
    local version
    local warn_color

    asterisk=$*
    dry_run=$ABBR_DRY_RUN
    force=$ABBR_FORCE
    quiet=$ABBR_QUIET
    quiet=$(( ABBR_QUIETER || ABBR_QUIET ))
    quieter=$ABBR_QUIETER
    release_date="February 5 2026"
    version="zsh-abbr version 6.5.1"

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
      # @DUPE (nearly) abbr, _abbr_log_available_abbreviation, _abbr_warn_deprecation
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

      if [[ -z $abbreviation || -z $expansion || $abbreviation == $1 ]]; then
        _abbr:util_error "abbr add: Requires abbreviation and expansion"
        return
      fi

      _abbr:util_add $abbreviation $expansion
    }

    _abbr:git() {
      _abbr_debugger

      local abbreviation
      local expansion
      local type_saved

      if [[ $# > 1 ]]; then
        _abbr:util_error "abbr add: Expected one argument, got $#: $*"
        return
      fi

      abbreviation=${1%%=*}
      expansion=${1#*=}
      type_saved=$type

      type='regular'
      _abbr:add ${abbreviation}="git $expansion"

      type='global'
      _abbr:add "git ${abbreviation}"="git $expansion"

      type=$type_saved
    }

    _abbr:clear_session() {
      _abbr_debugger

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr clear-session: Unexpected argument"
        return
      fi

      ABBR_REGULAR_SESSION_ABBREVIATIONS=( )
      ABBR_GLOBAL_SESSION_ABBREVIATIONS=( )
    }

    _abbr:erase() {
      _abbr_debugger

      local abbreviation
      local abbreviations_set
      local -a abbreviations_sets
      local message
      local verb_phrase

      local REPLY

      if [[ $# > 1 ]]; then
        _abbr:util_error "abbr erase: Expected one argument"
        return
      elif [[ $# < 1 ]]; then
        _abbr:util_error "abbr erase: Erase must be passed an abbreviation"
        return
      fi

      abbreviation=$1

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          if (( ${+ABBR_GLOBAL_SESSION_ABBREVIATIONS[${(qqq)${(Q)abbreviation}}]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a global session abbreviation"
            abbreviations_sets+=( ABBR_GLOBAL_SESSION_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if (( ${+ABBR_REGULAR_SESSION_ABBREVIATIONS[${(qqq)${(Q)abbreviation}}]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a regular session abbreviation"
            abbreviations_sets+=( ABBR_REGULAR_SESSION_ABBREVIATIONS )
          fi
        fi
      fi

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${_abbr_tmpdir}global-user-abbreviations
          fi

          if (( ${+ABBR_GLOBAL_USER_ABBREVIATIONS[${(qqq)${(Q)abbreviation}}]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a global user abbreviation"
            abbreviations_sets+=( ABBR_GLOBAL_USER_ABBREVIATIONS )
          fi
        fi

        if [[ $type != 'global' ]]; then
          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${_abbr_tmpdir}regular-user-abbreviations
          fi

          if (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)${(Q)abbreviation}}]} )); then
            (( ABBR_DEBUG )) && 'builtin' 'echo' "  Found a regular user abbreviation"
            abbreviations_sets+=( ABBR_REGULAR_USER_ABBREVIATIONS )
          fi
        fi
      fi

      if ! (( ${#abbreviations_sets} )); then
        _abbr:util_error "abbr erase: No${type:+ $type}${scope:+ $scope} abbreviation \`${(Q)abbreviation}\` found"
      elif (( ${#abbreviations_sets} == 1 )); then
        verb_phrase="Would erase"

        if ! (( dry_run )); then
          verb_phrase="Erased"
          unset "${abbreviations_sets}[${(qqq)${(Q)abbreviation}}]" # quotation marks required

          if [[ $abbreviations_sets =~ USER ]]; then
            _abbr:util_sync_user
          fi
        fi

        _abbr:util_set_to_typed_scope $abbreviations_sets
        _abbr:util_log_unless_quiet "$success_color$verb_phrase$reset_color $REPLY \`${(Q)abbreviation}\`"
      else
        verb_phrase="Did not erase"
        (( dry_run )) && verb_phrase="Would not erase"

        message="$error_color$verb_phrase$reset_color abbreviation \`${(Q)abbreviation}\`. Please specify one of\\n"

        for abbreviations_set in $abbreviations_sets; do
          _abbr:util_set_to_typed_scope $abbreviations_set
          message+="  $REPLY\\n"
        done

        _abbr:util_error $message
      fi
    }

    _abbr:expand() {
      _abbr_debugger

      local expansion

      if ! (( $# )); then
        _abbr:util_error "abbr expand: requires an argument"
        return
      fi

      expansion=$(_abbr:expansion $*)

      if [[ -z $expansion ]]; then
        return 1
      fi

      _abbr:util_print $expansion
    }

    _abbr:expansion() {
      _abbr_debugger

      local abbreviation
      local expansion

      if ! (( $# )); then
        _abbr:util_error "_abbr:expansion requires an argument"
        return
      fi

      abbreviation=$*

      expansion=$(_abbr_regular_expansion "$abbreviation")

      if [[ ! "$expansion" ]]; then
        expansion=$(_abbr_global_expansion "$abbreviation" 1)
      fi

      if [[ ! "$expansion" ]]; then
        _abbr_create_files
        source ${_abbr_tmpdir}global-user-abbreviations
        expansion=$(_abbr_global_expansion "$abbreviation" 0)
      fi

      'builtin' 'echo' - $expansion
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
        # this quotation mark to fix syntax highlighting "
        for alias_to_import in $aliases_to_import; do
          _abbr:util_import_alias $alias_to_import
        done
      fi

      if [[ $saved_type != 'regular' ]]; then
        type='global'

        aliases_to_import=( ${(f)"$('builtin' 'alias' -g)"} )
        # this quotation mark to fix syntax highlighting "
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
      # this quotation mark to fix syntax highlighting "

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
      local prefix
      local -a git_aliases

      while (( $# )); do
        case $1 in
          "--file")
            if [[ -z $2 ]]; then
              _abbr:util_error "abbr import-git-aliases: --file requires a file path"
              return
            fi

            config_file=$2

            shift 2
            ;;
          "--prefix")
            if [[ -z $2 ]]; then
              _abbr:util_error "abbr import-git-aliases: --prefix requires a prefix string"
              return
            fi

            prefix=$2

            shift 2
            ;;
          *)
            _abbr:util_error "abbr import-git-aliases: Unexpected argument"
            return
        esac
      done

      if [[ -n $config_file ]]; then
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

          _abbr:util_add "$prefix$key" "git $value"
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

    _abbr:profile() {
      _abbr_debugger

      local zsh_version

      if [[ $# > 0 ]]; then
        _abbr:util_error "abbr version: Unexpected argument"
        return
      fi

      zsh_version=$(zsh --version)

      _abbr:util_print $version
      _abbr:util_print $zsh_version
      _abbr:util_print "OSTYPE $OSTYPE"
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

      expansion=$(_abbr:expansion $current_abbreviation)

      if [[ -n $expansion ]]; then
        _abbr:util_add $new_abbreviation $expansion

        if (( $? )); then
          _abbr:util_error "abbr rename: ${type:+$type }${scope:+$scope }abbreviation \`${(Q)current_abbreviation}\` left untouched"
          return 1
        fi

        _abbr:erase $current_abbreviation
      else
        _abbr:util_error "abbr rename: No${type:+ $type}${scope:+ $scope} abbreviation \`${(Q)current_abbreviation}\` exists"
      fi
    }

    _abbr:util_add() {
      _abbr_debugger

      local abbreviation
      local abbreviations_set
      local cmd
      local expansion
      local existing_expansion
      local job_group
      local -a success
      local typed_scope
      local verb_phrase

      local REPLY

      abbreviation=$1
      expansion=$2
      success=0

      verb_phrase="Added"
      (( dry_run )) && verb_phrase="Would add"

      if [[ ${abbreviation%=*} != $abbreviation ]]; then
        _abbr:util_error "abbr add: ABBREVIATION (\`${(Q)abbreviation}\`) may not contain an equals sign"
         # this quotation mark to fix syntax highlighting "
        return 1
      fi

      if [[ $scope == 'session' ]]; then
        if [[ $type == 'global' ]]; then
          abbreviations_set=ABBR_GLOBAL_SESSION_ABBREVIATIONS
        else
          abbreviations_set=ABBR_REGULAR_SESSION_ABBREVIATIONS
        fi
      else
        if [[ $type == 'global' ]]; then
          abbreviations_set=ABBR_GLOBAL_USER_ABBREVIATIONS

          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${_abbr_tmpdir}global-user-abbreviations
          fi
        else
          abbreviations_set=ABBR_REGULAR_USER_ABBREVIATIONS

          if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
            source ${_abbr_tmpdir}regular-user-abbreviations
          fi
        fi
      fi

      _abbr:util_set_to_typed_scope $abbreviations_set
      typed_scope=$REPLY

      existing_expansion=${${(P)abbreviations_set}[${(qqq)${(Q)abbreviation}}]}

      if [[ -n $existing_expansion ]]; then
        if (( ! force )); then
          verb_phrase="Did not add"
          (( dry_run )) && verb_phrase="Would not add"

          _abbr:util_error "$verb_phrase the $typed_scope \`${(Q)abbreviation}\`. It already has an expansion"
          # this quotation mark to fix syntax highlighting "
          return 2
        fi

        verb_phrase="Redefined"
        (( dry_run )) && verb_phrase="Would redefine"
      fi

      _abbr:util_check_command $abbreviation || return 3

      if ! (( dry_run )); then
        eval $abbreviations_set'[${(qqq)${(Q)abbreviation}}]=${(qqq)${(Q)expansion}}'
      fi

      if [[ $scope != 'session' ]]; then
        _abbr:util_sync_user
      fi

      _abbr:util_log_unless_quiet "$success_color$verb_phrase$reset_color the $typed_scope \`${(Q)abbreviation}\`"
      # this quotation mark to fix syntax highlighting "
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
      # To add regardless, use --force

      if (( $+commands[$abbreviation] && ! $+aliases[$abbreviation] )); then
        if (( force )); then
          verb_phrase="will now expand"
          (( dry_run )) && verb_phrase="would now expand"

          _abbr:util_log_unless_quieter "\`${(Q)abbreviation}\` $verb_phrase as an abbreviation"
          # this quotation mark to fix syntax highlighting "
        else
          verb_phrase="Did not"
          (( dry_run )) && verb_phrase="Would not"

          _abbr:util_warn "$verb_phrase add the abbreviation \`${(Q)abbreviation}\` because a command with the same name exists"
          # this quotation mark to fix syntax highlighting "
          return 1
        fi
      fi
    }

    _abbr:util_list() {
      _abbr_debugger

      local abbreviation
      local abbreviation_set
      local -a abbreviations_sets
      local expansion
      local -i include_expansion
      local session_prefix
      local user_prefix
      local user_prefix_saved

      include_expansion=$1
      session_prefix=$2
      user_prefix=$3
      user_prefix_saved=$user_prefix

      # DUPE (nearly) completions/_abbr's __abbr_describe_abbreviations, zsh-abbr.zsh's _abbr:util_list

      if [[ $scope != 'session' ]]; then
        if [[ $type != 'regular' ]]; then
          abbreviations_sets+=( ABBR_GLOBAL_USER_ABBREVIATIONS )
        fi

        if [[ $type != 'global' ]]; then
          abbreviations_sets+=( ABBR_REGULAR_USER_ABBREVIATIONS )
        fi
      fi

      if [[ $scope != 'user' ]]; then
        if [[ $type != 'regular' ]]; then
          abbreviations_sets+=( ABBR_GLOBAL_SESSION_ABBREVIATIONS )
        fi

        if [[ $type != 'global' ]]; then
          abbreviations_sets+=( ABBR_REGULAR_SESSION_ABBREVIATIONS )
        fi
      fi

      for abbreviation_set in $abbreviations_sets; do
        user_prefix=$user_prefix_saved

        if [[ -n $user_prefix ]] && [[ -z ${abbreviation_set##ABBR_GLOBAL_*} ]]; then
          user_prefix+=" -g"
        fi

        for abbreviation in ${(iko)${(P)abbreviation_set}}; do
          (( include_expansion )) && expansion=${${(P)abbreviation_set}[$abbreviation]}

          _abbr:util_list_item $abbreviation $expansion $user_prefix
        done
      done

      # DUPE end
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

      local option
      local value

      option=$1
      value=$2

      if [[ "${(P)option}" ]]; then # quoted for syntax highlighting
        return 1
      fi

      eval $option=$value
    }

    _abbr:util_sync_user() {
      _abbr_debugger

      (( ABBR_LOADING_USER_ABBREVIATIONS )) && return

      local abbreviation
      local expansion
      local user_updated

      user_updated=$(mktemp ${_abbr_tmpdir}regular-user-abbreviations_updated.XXXXXX)

      typeset -p ABBR_GLOBAL_USER_ABBREVIATIONS > ${_abbr_tmpdir}global-user-abbreviations
      for abbreviation in ${(iko)ABBR_GLOBAL_USER_ABBREVIATIONS}; do
        expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[$abbreviation]}
        'builtin' 'echo' "abbr -g $abbreviation=$expansion" >> "$user_updated"
      done

      typeset -p ABBR_REGULAR_USER_ABBREVIATIONS > ${_abbr_tmpdir}regular-user-abbreviations
      for abbreviation in ${(iko)ABBR_REGULAR_USER_ABBREVIATIONS}; do
        expansion=${ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]}
        'builtin' 'echo' "abbr $abbreviation=$expansion" >> $user_updated
      done

      'command' 'mv' $user_updated $ABBR_USER_ABBREVIATIONS_FILE
    }

    _abbr:util_set_to_typed_scope() {
      _abbr_debugger

      local abbreviations_set
      abbreviations_set=$1

      REPLY=${${${${abbreviations_set:l}%s}#abbr_}//_/ }
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
          _abbr:util_set_once action add || args+=( $opt )
          shift
          ;;
        "git"|\
        "g")
          _abbr:util_set_once action git || args+=( $opt )
          shift
          ;;
        "clear-session"|\
        "c")
          _abbr:util_set_once action clear_session || args+=( $opt )
          shift
          ;;
        "--dry-run")
          dry_run=1
          shift
          ;;
        "erase"|\
        "e")
          _abbr:util_set_once action erase || args+=( $opt )
          shift
          ;;
        "expand"|\
        "x")
          _abbr:util_set_once action expand || args+=( $opt )
          shift
          ;;
        "export-aliases")
          _abbr:util_set_once action export_aliases || args+=( $opt )
          shift
          ;;
        "--force"|\
        "-f")
          force=1
          shift
          ;;
        "--global"|\
        "-g")
          _abbr:util_set_once type global || args+=( $opt )
          shift
          ;;
        "help"|\
        "--help")
          _abbr:util_usage
          should_exit=1
          shift
          ;;
        "import-aliases")
          _abbr:util_set_once action import_aliases || args+=( $opt )
          shift
          ;;
        "import-fish")
          _abbr:util_set_once action import_fish || args+=( $opt )
          shift
          ;;
        "import-git-aliases")
          _abbr:util_set_once action import_git_aliases || args+=( $opt )
          shift
          ;;
        "list")
          _abbr:util_set_once action list || args+=( $opt )
          shift
          ;;
        "list-abbreviations"|\
        "l")
          _abbr:util_set_once action list_abbreviations || args+=( $opt )
          shift
          ;;
        "list-commands"|\
        "L"|\
        "-L")
          # -L option is to match the builtin alias's `-L`
          _abbr:util_set_once action list_commands || args+=( $opt )
          shift
          ;;
        "load")
          _abbr_load_user_abbreviations
          should_exit=1
          shift
          ;;
        "profile")
          _abbr:util_set_once action profile || args+=( $opt )
          shift
          ;;
        "--quiet"|\
        "-q")
          quiet=1
          shift
          ;;
        "--quieter"|\
        "-qq")
          quiet=1
          quieter=1
          shift
          ;;
        "--regular"|\
        "-r")
          _abbr:util_set_once type regular || args+=( $opt )
          shift
          ;;
        "rename"|\
        "R")
          _abbr:util_set_once action rename || args+=( $opt )
          shift
          ;;
        "--session"|\
        "-S")
          _abbr:util_set_once scope session || args+=( $opt )
          shift
          ;;
        "--user"|\
        "-U")
          _abbr:util_set_once scope user || args+=( $opt )
          shift
          ;;
        "version"|\
        "--version"|\
        "-v")
          _abbr:util_set_once action print_version || args+=( $opt )
          shift
          ;;
        "--")
          shift
          args+=( $@ )
          break
          ;;
        *)
          args+=( $opt )
          shift
          ;;
      esac
    done

    if ! (( should_exit )); then
      if [[ -z $action ]]; then
        if (( ${#args} )); then
          action=add
        else
          action=list
        fi
      fi

      if ! (( ABBR_LOADING_USER_ABBREVIATIONS )) && [[ $scope != 'session' ]]; then
        job-queue__zsh-abbr push zsh-abbr $action
        job_id=$REPLY

        if (( ABBR_AUTOLOAD )); then
          _abbr_load_user_abbreviations
        fi
      fi

      _abbr:${action} $args
      has_error=$?
    fi

    if ! (( ABBR_LOADING_USER_ABBREVIATIONS )); then
      job-queue__zsh-abbr pop zsh-abbr $job_id
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
      [[ -n $output ]] && 'builtin' 'print' $output >&2
      return 1
    else
      if (( dry_run && ! ABBR_TESTING )); then
        output+="\\n${warn_color}Dry run. Changes not saved.$reset_color"
      fi

      [[ -n $output ]] && 'builtin' 'print' $output >&1
      return 0
    fi
  }
}

_abbr_no_color() {
  local -a shell_vars
  local -i found

  shell_vars=( ${(k)parameters} )

  found=$(( ! $shell_vars[(Ie)NO_COLOR] ))

  return $found
}

_abbr_regular_expansion() {
  {
    emulate -LR zsh

    # cannot support debug message

    local -a REPLY
    local abbreviation
    local expansion

    _abbr_regular_expansion:get_expansion() {
      {
        # cannot support debug message

        _abbr_regular_expansion:get_expansion:get_prefixed_expansion() {
          # cannot support debug message

          local abbreviation
          local abbreviation_sans_prefix
          local prefix_match
          local prefix_pattern
          local -a prefixes
          local -i use_globbing

          abbreviation=$1
          use_globbing=$2

          # setopt extended_glob

          prefixes=( $ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES )

          (( use_globbing )) && prefixes=( $ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES )

          while [[ ! $expansion ]] && (( #prefixes )); do
            prefix_pattern=$prefixes[1]
            shift prefixes

            abbreviation_sans_prefix="${abbreviation#$prefix_pattern}"

            if (( use_globbing )); then
              # Trim $prefix_pattern, _as a glob_ (`$~globparam` vs `$stringparam`)_, from $abbreviation
              abbreviation_sans_prefix=${abbreviation#$~prefix_pattern}
            fi

            prefix_match=${abbreviation%$abbreviation_sans_prefix}

            # $abbreviation_sans_prefix is now the full $abbreviation if $abbreviation doesn't start with a prefix,
            # or a $abbreviation with the prefix trimmed if $abbreviation does start with a prefix

            if (( session )); then
              expansion=$ABBR_REGULAR_SESSION_ABBREVIATIONS[${(qqq)abbreviation_sans_prefix}]
            else
              expansion=$ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation_sans_prefix}]
            fi

            if [[ -n $prefix_match ]]; then
              if [[ ! $expansion ]]; then
                expansion=$(_abbr_regular_expansion:get_expansion:get_prefixed_expansion $abbreviation_sans_prefix 1)
              fi

              if [[ ! $expansion ]]; then
                expansion=$(_abbr_regular_expansion:get_expansion:get_prefixed_expansion $abbreviation_sans_prefix 0)
              fi
            fi

            if [[ ! $expansion ]]; then
              continue
            fi

            # Re-prepend anything trimmed off during the prefix check
            expansion="${(qqq)prefix_match}$expansion"
            # this quotation mark to fix syntax highlighting "
          done

          'builtin' 'echo' - $expansion
        }

        # this quotation mark to fix syntax highlighting "

        local abbreviation
        local expansion
        local -i session

        abbreviation=$1
        session=$2

        if (( session )); then
          expansion=$ABBR_REGULAR_SESSION_ABBREVIATIONS[${(qqq)abbreviation}] # this bracket to fix syntax highlighting }
        else
          expansion=$ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}] # this bracket to fix syntax highlighting }
        fi

        if [[ ! $expansion ]]; then
          expansion=$(_abbr_regular_expansion:get_expansion:get_prefixed_expansion $abbreviation 1)
        fi

        if [[ ! $expansion ]]; then
          expansion=$(_abbr_regular_expansion:get_expansion:get_prefixed_expansion $abbreviation 0)
        fi

        'builtin' 'echo' - $expansion
      } always {
        unfunction -m _abbr_regular_expansion:get_expansion:get_prefixed_expansion
      }
    }

    abbreviation=$1

    # DUPE _abbr_global_expansion, _abbr_regular_expansion
    # do not expand empty string or all-whitespace string
    ABBR_SPLIT_FN $abbreviation
    [[ -n $REPLY ]] || return

    expansion=$(_abbr_regular_expansion:get_expansion $abbreviation 1)

    if [[ ! $expansion ]]; then
      _abbr_create_files
      source ${_abbr_tmpdir}regular-user-abbreviations
      expansion=$(_abbr_regular_expansion:get_expansion $abbreviation 0)
    fi

    'builtin' 'echo' - ${(Q)expansion}
  } always {
    unfunction -m _abbr_regular_expansion:get_expansion
  }
}

_abbr_create_files() {
  emulate -LR zsh

  # cannot support debug message

  [[ -d $_abbr_tmpdir ]] || mkdir -p $_abbr_tmpdir

  [[ -f ${_abbr_tmpdir}regular-user-abbreviations ]] || touch ${_abbr_tmpdir}regular-user-abbreviations

  [[ -f ${_abbr_tmpdir}global-user-abbreviations ]] || touch ${_abbr_tmpdir}global-user-abbreviations
}

_abbr_debugger() {
  emulate -LR zsh

  # user abbreviations are loaded on every git subcommand, making noise
  (( ABBR_LOADING_USER_ABBREVIATIONS && ! ABBR_INITIALIZING )) && return

  (( ABBR_DEBUG )) && 'builtin' 'echo' - $funcstack[2]
}

# abbr-expand-line
# - changes values in the `reply` associative array,
# **which must exist in the calling scope**
# - returns truthy if an abbreviation is expanded, and falsy (non-zero) otherwise
#
# At a minimum, `reply` will have entries with keys
#
# - `expansion_cursor_set` (0)
# - `linput` (the left-of-the-cursor text before any expansion, passed to the function as its first argument)
# - `loutput` (the left-of-the-cursor text after any expansion)
#
# Optionally, `reply` can have entries with keys
# - `rinput` (the right-of-the-cursor text, passed to the function as its second argument)
# - `routput` (the right-of-the-cursor text after any expansion)
#
# If an abbreviation is expanded, `reply` will also have entries with keys
# - `abbrevation` (the expanded abbreviation)
# - `expansion` (the expanded abbreviation's expansion)
# - `type` (the expanded abbreviation's type)
#
# If the cursor is placed during expansion (requires that
# ABBR_SET_EXPANSION_CURSOR be greater than zero), `reply[routput]` may be
# different from `reply[rinput]`
abbr-expand-line() {
  emulate -LR zsh

  {
    _abbr_debugger

    abbr-expand-line:expand_abbreviation() {
      emulate -LR zsh

      _abbr_debugger

      local -a REPLY # will be set by ABBR_SPLIT_FN
      local abbreviation
      local -a cmds
      local expansion
      local -i i
      local -i j
      local -i k
      local -i res
      local -a subcmds
      local type
      local -a words

      # Check for regular expansion
      # Supports <=v6.3.x "from the start of the line" sense of regular
      # (match against entire linput) and (roughly) "command-position"
      # sense (matching against righ-most command in linput).

      cmds=( $reply[linput] )

      if (( ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS )); then
        # Treat all `;`, `&`, `|`, and all reduplications (e.g. `&&`, `||`) as command delimiters
        subcmds=( ${(s.;.)reply[linput]//[&|]/;} )

        if (( ${#subcmds} > 1 )); then
          cmds+=( ${subcmds[-1]} )
        fi
      fi

      while [[ -z $expansion ]] && (( k < ${#cmds} )); do
        abbreviation=${cmds[-1]}
        expansion=$(_abbr_regular_expansion "$abbreviation")
        (( k++ ))
      done

      if [[ -n $expansion ]]; then
        reply+=(
          [abbreviation]=$abbreviation
          [expansion]=$expansion
          [loutput]=${reply[linput]%%$abbreviation}$expansion
          [type]=regular
        )

        return
      fi

      ABBR_SPLIT_FN $reply[linput]
      words=( $REPLY )

      # Check for global session expansion

      # first check the full linput, then trim words off the front
      while [[ -z $expansion ]] && (( i < ${#words} )); do
        abbreviation=${words:$i}
        expansion=$(_abbr_global_expansion "$abbreviation" 1)
        (( i++ ))
      done

      if [[ -z $expansion ]]; then
        # Check for global user expansion

        i=0

        _abbr_create_files
        source ${_abbr_tmpdir}global-user-abbreviations

        # first check the full linput, then trim words off the front
        while [[ -z $expansion ]] && (( i < ${#words} )); do
          abbreviation=${words:$i}
          expansion=$(_abbr_global_expansion "$abbreviation" 0)
          (( i++ ))
        done
      fi

      [[ -z $expansion ]] && return 1

      reply+=(
        [abbreviation]=$abbreviation
        [expansion]=$expansion
        [loutput]=${reply[linput]%%$abbreviation}$expansion
        [type]=global
      )
    }

    abbr-expand-line:set_expansion_cursor() {
      emulate -LR zsh

      _abbr_debugger

      # if expansion doesn't contain expansion cursor marker, no cursor placement to be done
      [[ $reply[expansion] != ${reply[expansion]/$ABBR_EXPANSION_CURSOR_MARKER} ]] || return 1

      reply+=(
        [expansion_cursor_set]=1
        [loutput]=${reply[linput]%%$reply[abbreviation]}${reply[expansion]%%$ABBR_EXPANSION_CURSOR_MARKER*}
        [routput]=${reply[expansion]#*$ABBR_EXPANSION_CURSOR_MARKER}$reply[rinput]
      )
    }

    reply=(
      [expansion_cursor_set]=0
      [linput]=$1
      [loutput]=$1
    )

    [[ -n $2 ]] && reply+=( [rinput]=$2 [routput]=$2 )

    abbr-expand-line:expand_abbreviation
    res=$?

    (( ! res )) \
      && (( ABBR_SET_EXPANSION_CURSOR )) \
        && abbr-expand-line:set_expansion_cursor

    return $res
  } always {
    unfunction -m abbr-expand-line:set_expansion_cursor
  }
}

_abbr_global_expansion() {
  emulate -LR zsh

  # cannot support debug message

  # `_abbr_global_expansion … 0` must always be preceded by creating and sourcing files
  # search this file for examples

  local -a REPLY
  local abbreviation
  local expansion
  local -i session

  abbreviation=$1
  session=$2

  # DUPE _abbr_global_expansion, _abbr_regular_expansion
  # do not expand empty string or all-whitespace string
  ABBR_SPLIT_FN $abbreviation
  [[ -n $REPLY ]] || return

  if (( session )); then
    expansion=${ABBR_GLOBAL_SESSION_ABBREVIATIONS[${(qqq)abbreviation}]}
  else
    expansion=${ABBR_GLOBAL_USER_ABBREVIATIONS[${(qqq)abbreviation}]}
  fi

  'builtin' 'echo' - ${(Q)expansion} #  this bracket for syntax highlighting }
}

_abbr_load_user_abbreviations() {
  emulate -LR zsh

  # these characters for syntax highlighting ' $

  {
    _abbr_debugger

    function _abbr_load_user_abbreviations:setup() {
      _abbr_debugger

      ABBR_REGULAR_USER_ABBREVIATIONS=( )
      ABBR_GLOBAL_USER_ABBREVIATIONS=( )

      _abbr_create_files
    }

    function _abbr_load_user_abbreviations:load() {
      _abbr_debugger

      local cmd
      local -a cmds
      local -i shwordsplit_on
      local -a words

      typeset -gi ABBR_LOADING_USER_ABBREVIATIONS

      shwordsplit_on=0

      if [[ $options[shwordsplit] = on ]]; then
        shwordsplit_on=1
      fi

      # Load saved user abbreviations
      if [[ -f $ABBR_USER_ABBREVIATIONS_FILE ]]; then
        unsetopt shwordsplit

        cmds=( ${(f)"$(<$ABBR_USER_ABBREVIATIONS_FILE)"} ) # this backtick for syntax highlighting `

        for cmd in $cmds; do
          words=( ${(z)cmd} ) # this bracket for syntax highlighting }

          # Only execute abbr commands
          if (( ${#words} > 1 )) && [[ ${words[1]} == abbr ]]; then
            abbr ${words:1}
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

      typeset -p ABBR_REGULAR_USER_ABBREVIATIONS > ${_abbr_tmpdir}regular-user-abbreviations
      typeset -p ABBR_GLOBAL_USER_ABBREVIATIONS > ${_abbr_tmpdir}global-user-abbreviations
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

_abbr_get_available_abbreviation() {
  {
    _abbr_get_available_abbreviation:regular() {
      {
        # cannot support debug message

        _abbr_get_available_abbreviation:regular:prefixed() {
          # cannot support debug message

          local expansion
          local expansion_sans_prefix
          local prefix_match
          local prefix_pattern
          local -a prefixes
          local -i use_globbing

          expansion=$1
          use_globbing=$2

          prefixes=( $ABBR_REGULAR_ABBREVIATION_SCALAR_PREFIXES )

          (( use_globbing )) && prefixes=( $ABBR_REGULAR_ABBREVIATION_GLOB_PREFIXES )

          while [[ ! $ABBR_UNUSED_ABBREVIATION ]] && (( #prefixes )); do
            prefix_pattern=$prefixes[1]
            shift prefixes

            expansion_sans_prefix="${expansion#$prefix_pattern}"

            if (( use_globbing )); then
              # Trim $prefix_pattern, _as a glob_ (`$~globparam` vs `$stringparam`)_, from $expansion
              expansion_sans_prefix=${expansion#$~prefix_pattern}
            fi

            prefix_match=${expansion%$expansion_sans_prefix}

            # $expansion_sans_prefix is now the full $expansion if $expansion doesn't start with a prefix,
            # or a $expansion with the prefix trimmed if $expansion does start with a prefix

            if (( session )); then
              ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_REGULAR_SESSION_ABBREVIATIONS[(re)${(qqq)expansion_sans_prefix}]}}
            else
              ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_REGULAR_USER_ABBREVIATIONS[(re)${(qqq)expansion_sans_prefix}]}}
            fi

            if [[ -n $prefix_match ]]; then
              ABBR_UNUSED_ABBREVIATION_PREFIX+=$prefix_match

              if [[ ! $ABBR_UNUSED_ABBREVIATION ]]; then
                _abbr_get_available_abbreviation:regular:prefixed $expansion_sans_prefix 1
              fi

              if [[ ! $ABBR_UNUSED_ABBREVIATION ]]; then
                _abbr_get_available_abbreviation:regular:prefixed $expansion_sans_prefix 0
              fi
            fi
          done
        }

        local expansion
        local -i session

        expansion=$1
        session=$2

        if (( session )); then
          ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_REGULAR_SESSION_ABBREVIATIONS[(re)${(qqq)expansion}]}}
        else
          ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_REGULAR_USER_ABBREVIATIONS[(re)${(qqq)expansion}]}}
        fi

        if [[ -z $ABBR_UNUSED_ABBREVIATION ]]; then
          ABBR_UNUSED_ABBREVIATION_PREFIX=
          _abbr_get_available_abbreviation:regular:prefixed $expansion 1
        fi

        if [[ -z $ABBR_UNUSED_ABBREVIATION ]]; then
          ABBR_UNUSED_ABBREVIATION_PREFIX=
          _abbr_get_available_abbreviation:regular:prefixed $expansion 0
        fi

        if [[ -n $ABBR_UNUSED_ABBREVIATION ]]; then
          return
        fi

        ABBR_UNUSED_ABBREVIATION_PREFIX=
      } always {
        unfunction -m _abbr_get_available_abbreviation:regular:prefixed
      }
    }

    local expansion
    local -i i
    local -a REPLY
    local -a words

    expansion=$LBUFFER

    # Look for regular session abbreviation
    _abbr_get_available_abbreviation:regular $expansion 1

    if [[ -n $ABBR_UNUSED_ABBREVIATION ]]; then
      ABBR_UNUSED_ABBREVIATION_EXPANSION=$expansion
      ABBR_UNUSED_ABBREVIATION_SCOPE=session
      ABBR_UNUSED_ABBREVIATION_TYPE=regular
      return
    fi

    # Look for regular user abbreviation
    _abbr_get_available_abbreviation:regular $expansion 0

    if [[ -n $ABBR_UNUSED_ABBREVIATION ]]; then
      ABBR_UNUSED_ABBREVIATION_EXPANSION=$expansion
      ABBR_UNUSED_ABBREVIATION_SCOPE=user
      ABBR_UNUSED_ABBREVIATION_TYPE=regular
      return
    fi

    ABBR_SPLIT_FN $LBUFFER
    words=( $REPLY )

    # Look for global session abbreviation

    while [[ -z $ABBR_UNUSED_ABBREVIATION ]] && (( i < ${#words} )); do
      expansion=${words:$i}
      ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_GLOBAL_SESSION_ABBREVIATIONS[(re)${(qqq)expansion}]}}
      (( i++ ))
    done

    if [[ -n $ABBR_UNUSED_ABBREVIATION ]]; then
      ABBR_UNUSED_ABBREVIATION_EXPANSION=$expansion
      ABBR_UNUSED_ABBREVIATION_SCOPE=session
      ABBR_UNUSED_ABBREVIATION_TYPE=global
      return
    fi

    # Look for global user abbreviation

    i=0
    while [[ -z $ABBR_UNUSED_ABBREVIATION ]] && (( i < ${#words} )); do
      expansion=${words:$i}
      ABBR_UNUSED_ABBREVIATION=${(Q)${(k)ABBR_GLOBAL_USER_ABBREVIATIONS[(re)${(qqq)expansion}]}}
      (( i++ ))
    done

    if [[ -n $ABBR_UNUSED_ABBREVIATION ]]; then
      ABBR_UNUSED_ABBREVIATION_EXPANSION=$expansion
      ABBR_UNUSED_ABBREVIATION_SCOPE=user
      ABBR_UNUSED_ABBREVIATION_TYPE=global
    fi
  } always {
    unfunction -m _abbr_get_available_abbreviation:regular
  }
}

_abbr_log_available_abbreviation() {
  [[ -z $ABBR_UNUSED_ABBREVIATION || -z $ABBR_UNUSED_ABBREVIATION_EXPANSION ]] && \
    return

  local message

  # @DUPE (nearly) abbr, _abbr_log_available_abbreviation, _abbr_warn_deprecation
  local warn_color
  if ! _abbr_no_color; then
    warn_color="$fg[yellow]"
  fi

  message="abbr: \`$ABBR_UNUSED_ABBREVIATION\`${ABBR_UNUSED_ABBREVIATION_PREFIX:+, prefixed with \`$ABBR_UNUSED_ABBREVIATION_PREFIX\`,} is your $ABBR_UNUSED_ABBREVIATION_TYPE $ABBR_UNUSED_ABBREVIATION_SCOPE abbreviation for \`$ABBR_UNUSED_ABBREVIATION_EXPANSION\`" # this backtick for syntax highlighting `

  if ! _abbr_no_color; then
    message="$warn_color$message$reset_color"
  fi

  'builtin' 'print' $message
}

abbr-set-line-cursor() {
  emulate -LR zsh

  _abbr_debugger

  local str

  str=$1

  reply=( )

  # setting the line cursor must be enabled
  (( ABBR_SET_LINE_CURSOR )) || return 1

  # str must contain ABBR_LINE_CURSOR_MARKER
  [[ $str != ${str/$ABBR_LINE_CURSOR_MARKER} ]] || return 1

  reply+=(
    [loutput]=${str%%$ABBR_LINE_CURSOR_MARKER*} # set loutput to str up to and not including the first instance of ABBR_LINE_CURSOR_MARKER
    [routput]=${str#*$ABBR_LINE_CURSOR_MARKER} # set routput to str starting after the first instance of ABBR_LINE_CURSOR_MARKER
  )
}

_abbr_may_push_abbreviation_to_history() {
  emulate -LR zsh

  _abbr_debugger

  local hist_ignore_space
  local line

  line=$1
  hist_ignore_space=${2:-off}

  (( ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY )) || return 1

  [[ $hist_ignore_space == on ]] && [[ ${line[1]} == ' ' ]] \
    && return 2

  return 0
}

_abbr_may_push_abbreviated_line_to_history() {
  emulate -LR zsh

  _abbr_debugger

  local abbreviation
  local expanded_line
  local input_line
  local hist_ignore_dups
  local hist_ignore_space

  input_line=$1
  expanded_line=${2:-$input_line}
  hist_ignore_dups=${3:-off}
  hist_ignore_space=${4:-off}
  abbreviation=${5:-""}

  (( ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY )) || return 1

  # DUPE _abbr_may_push_abbreviation_to_history, _abbr_may_push_abbreviated_line_to_history
  # May not push to history if the original buffer starts with a space
  if [[ $hist_ignore_space == on ]] && [[ $input_line[1] == ' ' ]]; then
    return 2
  fi

  # May not push to history if the entry would be duplicated by accept-line's
  if [[ $expanded_line == $input_line ]]; then
    return 3
  fi

  # No risk of duplicative history entry if expansion did not push the abbreviation to history
  (( ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY )) || return 0

  # expansion pushed the abbreviation to history

  [[ $hist_ignore_dups == off ]] && return 0

  # hist_ignore_dups

  if [[ $input_line == $abbreviation ]]; then
    return 4
  fi

  return 0
}

# WIDGETS
# -------

abbr-expand() {
  emulate -LR zsh

  local -A reply # will be set by abbr-expand-line

  # DUPE abbr-expand, abbr-expand-and-accept, abbr-expand-and-insert
  # abbr-expand-line sets `reply`
  abbr-expand-line "$LBUFFER" "$RBUFFER" && {
    _abbr_may_push_abbreviation_to_history $_abbr_hist_ignore_space $BUFFER \
      && print -s $reply[abbreviation]
  }

  LBUFFER=$reply[loutput]
  RBUFFER=$reply[routput]
}

abbr-expand-and-accept() {
  emulate -LR zsh

  # do not support debug message

  local buffer
  local -A reply # will be set by abbr-expand-line

  ABBR_UNUSED_ABBREVIATION=
  ABBR_UNUSED_ABBREVIATION_EXPANSION=
  ABBR_UNUSED_ABBREVIATION_PREFIX=
  ABBR_UNUSED_ABBREVIATION_SCOPE=
  ABBR_UNUSED_ABBREVIATION_TYPE=

  # TODO this seems strange
  # Why was this escape hatch desirable three years ago?
  # Can just append a `;`. But dropping this would be a breaking change
  local trailing_space
  trailing_space=${LBUFFER##*[^[:IFSSPACE:]]}
  if [[ -n $trailing_space ]]; then
    _abbr_accept-line
    return
  fi

  buffer=$BUFFER

  # DUPE abbr-expand, abbr-expand-and-accept, abbr-expand-and-insert
  # abbr-expand-line sets `reply`
  abbr-expand-line "$LBUFFER" "$RBUFFER" && {
    _abbr_may_push_abbreviation_to_history $_abbr_hist_ignore_space $BUFFER \
      && print -s $reply[abbreviation]
  } || {
    # END DUPE this part unique to abbr-expand-and-accept
    # No expansion found. See if one was available
    (( ABBR_GET_AVAILABLE_ABBREVIATION )) \
      && _abbr_get_available_abbreviation
  }


  LBUFFER=$reply[loutput]
  RBUFFER=$reply[routput]

  _abbr_may_push_abbreviated_line_to_history \
    && print -s $buffer

  _abbr_accept-line
}

abbr-expand-and-insert() {
  emulate -LR zsh

  local -A reply # will be set by abbr-expand-line

  # DUPE abbr-expand, abbr-expand-and-accept, abbr-expand-and-insert
  # abbr-expand-line sets `reply`
  abbr-expand-line "$LBUFFER" "$RBUFFER" && {
    _abbr_may_push_abbreviation_to_history $_abbr_hist_ignore_space $BUFFER \
      && print -s $reply[abbreviation]
  }

  LBUFFER=$reply[loutput]
  RBUFFER=$reply[routput]

  # stop if cursor was placed during expansion
  (( $reply[expansion_cursor_set] )) && return # this apostrophe for syntax highlighting '

  reply=()
  abbr-set-line-cursor $BUFFER # sets `reply`

  # do not insert the bound trigger if the cursor is set
  (( $? )) && {
    zle self-insert
    return # this apostrophe for syntax highlighting '
  }

  LBUFFER=$reply[loutput]
  RBUFFER=$reply[routput]
}

# DEPRECATION
# -----------

_abbr_warn_deprecation() {
  emulate -LR zsh

  _abbr_debugger

  local callstack
  local deprecated
  local message
  local replacement

  # @DUPE (nearly) abbr, _abbr_log_available_abbreviation, _abbr_warn_deprecation
  local warn_color
  if ! _abbr_no_color; then
    warn_color="$fg[yellow]"
  fi

  deprecated=$1
  replacement=$2
  callstack=$3

  message="$deprecated is deprecated.${replacement:+ Please use $replacement instead.}"

  if [[ -n $callstack ]]; then
    message+="\\n${warn_color}Called by \`$callstack\`$reset_color"
  fi

  'builtin' 'print' $message
}

# INITIALIZATION
# --------------

_abbr_init() {
  emulate -LR zsh

  local job_id

  {
    local log_available_abbreviation_hook
    local REPLY

    log_available_abbreviation_hook=preexec
    (( ABBR_LOG_AVAILABLE_ABBREVIATION_AFTER )) && log_available_abbreviation_hook=precmd

    typeset -g ABBR_UNUSED_ABBREVIATION
    typeset -g ABBR_UNUSED_ABBREVIATION_EXPANSION
    typeset -g ABBR_UNUSED_ABBREVIATION_PREFIX
    typeset -g ABBR_UNUSED_ABBREVIATION_SCOPE
    typeset -g ABBR_UNUSED_ABBREVIATION_TYPE
    typeset -gA ABBR_GLOBAL_SESSION_ABBREVIATIONS
    typeset -gA ABBR_GLOBAL_USER_ABBREVIATIONS
    typeset -gi ABBR_INITIALIZING
    typeset -gA ABBR_REGULAR_SESSION_ABBREVIATIONS
    typeset -gA ABBR_REGULAR_USER_ABBREVIATIONS

    ABBR_INITIALIZING=1
    ABBR_REGULAR_SESSION_ABBREVIATIONS=( )
    ABBR_GLOBAL_SESSION_ABBREVIATIONS=( )

    _abbr_init:dependencies() {
      emulate -LR zsh

      _abbr_debugger

      # if installed with Homebrew, will not have .gitmodules
      if [[ -f ${ABBR_SOURCE_PATH}/.gitmodules && ! -f ${ABBR_SOURCE_PATH}/zsh-job-queue/zsh-job-queue.zsh ]]; then
        'builtin' 'print' abbr: Finishing installing dependencies
        'command' 'git' submodule update --init --recursive &>/dev/null
      fi

      if ! [[ -f ${ABBR_SOURCE_PATH}/zsh-job-queue/zsh-job-queue.zsh ]]; then
        'builtin' 'print' abbr: There was a problem finishing installing dependencies
        return 1
      fi

      source ${ABBR_SOURCE_PATH}/zsh-job-queue/zsh-job-queue.zsh __zsh-abbr
    }

    _abbr_init:add_widgets() {
      emulate -LR zsh

      _abbr_debugger

      # _abbr_accept-line is called by abbr-expand-and-accept
      # h/t https://github.com/ohmyzsh/ohmyzsh/pull/9466/commits/11c1f96155055719e42c3bac7d10c6ef4168a04f
      if (( ! ${+functions[_abbr_accept-line]} )); then
        case "$widgets[accept-line]" in
          # If the accept-line widget was already redefined before zsh-abbr's initialization,
          # use the user-defined accept-line widget
          user:*)
            zle -N _abbr_accept-line_user_defined "${widgets[accept-line]#user:}"
            _abbr_accept-line() {
              zle _abbr_accept-line_user_defined -- "$@"
            }
            ;;
          # Otherwise use the standard widget
          builtin)
            _abbr_accept-line() {
              zle .accept-line
            }
            ;;
        esac
      fi

      zle -N abbr-expand
      zle -N abbr-expand-and-accept
      zle -N abbr-expand-and-insert
    }

    _abbr_init:bind_widgets() {
      emulate -LR zsh

      _abbr_debugger

      # enter expands abbreviations and runs the command
      zle -N accept-line abbr-expand-and-accept

      # spacebar expands abbreviations
      bindkey " " abbr-expand-and-insert

      # control-spacebar is a normal space
      bindkey "^ " magic-space

      # when running an incremental search,
      # spacebar behaves normally and control-space expands abbreviations
      bindkey -M isearch "^ " abbr-expand-and-insert
      bindkey -M isearch " " magic-space
    }

    _abbr_init:deprecations() {
      {
        emulate -LR zsh

        _abbr_debugger

        local -A deprecated_widgets

        deprecated_widgets=( )

        # START Deprecation notices for values that could not be meaningfully set after initialization
        # Example form:
        # (( ${+DEPRECATED_VAL} )) && _abbr_warn_deprecation DEPRECATED_VAL VAL
        # VAL=$DEPRECATED_VAL

        # END Deprecation notices for values that could not be meaningfully set after initialization

        # START Deprecation notices for functions
        # Example form:
        # deprecated_fn() {
        #   _abbr_warn_deprecation deprecated_fn fn
        #   fn
        # }

        # END Deprecation notices for functions

        # Deprecation notices for zle widgets
        _abbr_init:deprecations:widgets() {

          # cannot support debug message

          local bindkey_declaration
          local bindkey_declarations
          local replacement
          local deprecated

          bindkey_declarations=$(bindkey)

          # deprecated_widgets is defined in _abbr_init:deprecations
          for deprecated replacement in ${(kv)deprecated_widgets}; do
            bindkey_declaration=$('builtin' 'echo' $bindkey_declarations | grep $deprecated)

            zle -N $deprecated

            if [[ -n $bindkey_declaration ]]; then
              _abbr_warn_deprecation $deprecated $replacement "bindkey $bindkey_declaration"
            fi
          done
        }

        (( ${#deprecated_widgets} )) && {
          _abbr_init:deprecations:widgets
        }
      } always {
        unfunction -m _abbr_init:deprecations:widgets
      }
    }

    if ! _abbr_no_color; then
      'builtin' 'autoload' -U colors && colors
    fi

    _abbr_debugger

    _abbr_init:dependencies || return

    job-queue__zsh-abbr push zsh-abbr initialization
    job_id=$REPLY

    (( ABBR_LOG_AVAILABLE_ABBREVIATION && ABBR_GET_AVAILABLE_ABBREVIATION )) && {
      'builtin' 'autoload' -Uz add-zsh-hook
      'add-zsh-hook' $log_available_abbreviation_hook _abbr_log_available_abbreviation
    }

    _abbr_load_user_abbreviations
    _abbr_init:add_widgets
    _abbr_init:deprecations
    (( ABBR_DEFAULT_BINDINGS )) && _abbr_init:bind_widgets

    job-queue__zsh-abbr pop zsh-abbr $job_id
    unset ABBR_INITIALIZING
  } always {
    unfunction -m _abbr_init:add_widgets
    unfunction -m _abbr_init:bind_widgets
    unfunction -m _abbr_init:dependencies
    unfunction -m _abbr_init:deprecations
  }
}

# _abbr_init should remain the last function defined in this file

typeset -g ABBR_SOURCE_PATH
ABBR_SOURCE_PATH=${0:A:h}
_abbr_init

# user-reaching
#
# abbr-expand-line
# abbr-expand
# abbr-expand-and-accept
# abbr-expand-and-insert
# abbr-set-line-cursor

# can't unset
# _abbr_hist_ignore_dups
# _abbr_hist_ignore_space
# _abbr_may_push_abbreviated_line_to_history
# _abbr_may_push_abbreviation_to_history
# _abbr_tmpdir

# can't unfunction
# _abbr_accept-line
# _abbr_create_files
# _abbr_debugger
# _abbr_get_available_abbreviation
# _abbr_global_expansion
# _abbr_load_user_abbreviations
# _abbr_log_available_abbreviation
# _abbr_no_color
# _abbr_regular_expansion

unfunction -m _abbr
unfunction -m _abbr_init
unfunction -m _abbr_warn_deprecation
unfunction -m _abbr:add
unfunction -m _abbr:clear_session
unfunction -m _abbr:erase
unfunction -m _abbr:expand
unfunction -m _abbr:expansion
unfunction -m _abbr:export_aliases
unfunction -m _abbr:git
unfunction -m _abbr:import_aliases
unfunction -m _abbr:import_fish
unfunction -m _abbr:import_git_aliases
unfunction -m _abbr:list
unfunction -m _abbr:list_abbreviations
unfunction -m _abbr:list_commands
unfunction -m _abbr:print_version
unfunction -m _abbr:profile
unfunction -m _abbr:rename
unfunction -m _abbr:util_add
unfunction -m _abbr:util_alias
unfunction -m _abbr:util_bad_options
unfunction -m _abbr:util_check_command
unfunction -m _abbr:util_error
unfunction -m _abbr:util_import_alias
unfunction -m _abbr:util_list
unfunction -m _abbr:util_list_item
unfunction -m _abbr:util_log_unless_quiet
unfunction -m _abbr:util_log_unless_quieter
unfunction -m _abbr:util_print
unfunction -m _abbr:util_set_once
unfunction -m _abbr:util_set_to_typed_scope
unfunction -m _abbr:util_sync_user
unfunction -m _abbr:util_usage
unfunction -m _abbr:util_warn
