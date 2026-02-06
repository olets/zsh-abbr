#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  {
    ZTR_TEARDOWN_FN() {
      emulate -LR zsh

      abbr erase $test_abbr_abbreviation
    }

    local -A reply
    local -i res

    abbr-expand-line foo
    res=$?
    ztr test '[[ -z $reply[abbreviation] ]] \
    && [[ $reply[expansion_cursor_set] == 0 ]] \
    && [[ -z $reply[expansion] ]] \
    && [[ $reply[linput] == foo ]] \
    && [[ $reply[loutput] == foo ]] \
    && [[ -z $reply[rinput] ]] \
    && [[ -z $reply[routput] ]] \
    && [[ -z $reply[type] ]] \
    && (( res == 1 ))
    ' \
    "abbr-expand-line with no abbreviation, no expansion cursor: falsy, output text matches input text, no expansion data"

    abbr-expand-line "$ABBR_EXPANSION_CURSOR_MARKER foo"
    res=$?
    ztr test '[[ -z $reply[abbreviation] ]] \
    && [[ $reply[expansion_cursor_set] == 0 ]] \
    && [[ -z $reply[expansion] ]] \
    && [[ $reply[linput] == "$ABBR_EXPANSION_CURSOR_MARKER foo" ]] \
    && [[ $reply[loutput] == "$ABBR_EXPANSION_CURSOR_MARKER foo" ]] \
    && [[ -z $reply[rinput] ]] \
    && [[ -z $reply[routput] ]] \
    && [[ -z $reply[type] ]] \
    && (( res == 1 ))
    ' \
    "abbr-expand-line with no abbreviation, expansion cursor: falsy, output text matches input text, no expansion data"

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line $test_abbr_abbreviation
    res=$?
    ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
    && [[ $reply[expansion_cursor_set] == 0 ]] \
    && [[ $reply[expansion] == $test_abbr_expansion ]] \
    && [[ $reply[linput] == $test_abbr_abbreviation ]] \
    && [[ $reply[loutput] == $test_abbr_expansion ]] \
    && [[ -z $reply[rinput] ]] \
    && [[ -z $reply[routput] ]] \
    && [[ $reply[type] == regular ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line returns correct values when expanding a line containing only a regular abbreviation"

    abbr -g $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line $test_abbr_abbreviation
    res=$?
    ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
    && [[ $reply[expansion_cursor_set] == 0 ]] \
    && [[ $reply[expansion] == $test_abbr_expansion ]] \
    && [[ $reply[linput] == $test_abbr_abbreviation ]] \
    && [[ $reply[loutput] == $test_abbr_expansion ]] \
    && [[ -z $reply[rinput] ]] \
    && [[ -z $reply[routput] ]] \
    && [[ $reply[type] == global ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line returns correct values when expanding a line containing only a global abbreviation"

    ztr test 'abbr-expand-line "" "abc"; \
      [[ -z $reply[loutput] ]] && [[ $reply[routput] == "abc" ]]' \
      "abbr-expand-line supports empty LBUFFER"

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line $test_abbr_abbreviation right_text
    res=$?
    ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
    && [[ $reply[rinput] == right_text ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line preserves right text when expanding a regular abbrevation"

    abbr -g $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line $test_abbr_abbreviation right_text
    res=$?
    ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
    && [[ $reply[rinput] == right_text ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line preserves right text when expanding a global abbrevation"

    ABBR_SET_EXPANSION_CURSOR=1
    abbr $test_abbr_abbreviation=$test_abbr_expansion$ABBR_EXPANSION_CURSOR_MARKER$test_abbr_expansion_2
    abbr-expand-line $test_abbr_abbreviation
    res=$?
    ztr test '[[ $reply[loutput] == $test_abbr_expansion ]] \
    && [[ $reply[routput] == $test_abbr_expansion_2 ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line can set the expansion cursor when expanding a regular abbreviation"
    ABBR_SET_EXPANSION_CURSOR=0

    ABBR_SET_EXPANSION_CURSOR=1
    abbr -g $test_abbr_abbreviation=$test_abbr_expansion$ABBR_EXPANSION_CURSOR_MARKER$test_abbr_expansion_2
    abbr-expand-line $test_abbr_abbreviation
    res=$?
    ztr test '[[ $reply[loutput] == $test_abbr_expansion ]] \
    && [[ $reply[routput] == $test_abbr_expansion_2 ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line can set the expansion cursor when expanding a global abbreviation"
    ABBR_SET_EXPANSION_CURSOR=0

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line "foo $test_abbr_abbreviation" right_text

    ztr test '[[ $reply[linput] == $reply[loutput] ]] \
    && [[ $reply[rinput] == $reply[routput] ]] \
    && ((res == 1 ))
    ' \
    "abbr-expand-line does not expand a regular abbreviation if it is not at the start of the line"

    abbr -g $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line "foo $test_abbr_abbreviation" right_text
    res=$?
    ztr test '[[ $reply[loutput] == "foo $test_abbr_expansion" ]] \
   && [[ $reply[rinput] == $reply[routput] ]] \
    && (( res == 0 ))
    ' \
    "abbr-expand-line expands a global abbreviation not at the start of the line"

    ## BEGIN ~DUPE abbr-expand.ztr.zsh

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand an abbreviation on the command line" \
    "Dependencies: erase"

    abbr -g add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a global abbreviation on the command line with the flag before the command" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion -g
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a global abbreviation on the command line with the flag after the command args" \
    "Dependencies: erase"

    abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a global abbreviation on the command line with the flag between the command and its args" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a session abbreviation on the command line" \
    "Dependencies: erase"

    abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a global session abbreviation on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_one_word$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_one_word$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with one word, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_one_word$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_one_word$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with one word, on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_multi_word$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_multi_word$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with multiple words, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_multi_word$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_multi_word$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with multiple words, on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_double_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_double_quotes$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with a prefix containing single-quoted double quotes, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_double_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_double_quotes$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with a prefix containing single-quoted double quotes, on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_single_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_single_quotes$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with a prefix containing double-quoted single quotes, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_single_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_single_quotes$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with a prefix containing double-quoted single quotes, on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_glob_1_match_1$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_glob_1_match_1$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with a glob, on the command line — 1/n" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_glob_1_match_2$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_glob_1_match_2$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with a glob, on the command line — 2/n" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; ! abbr-expand-line "$prefix_glob_1_mismatch$test_abbr_abbreviation"' \
    "Cannot expand an abbreviation prefixed with a mismatching glob, on the command line" \
    "Dependencies: erase"

    abbr add $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_multi_word$prefix_double_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_multi_word$prefix_double_quotes$test_abbr_expansion" ]]' \
    "Can expand an abbreviation, prefixed with a linear combination of scalar prefixes, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_glob_1_match_1$prefix_glob_2_match$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_glob_1_match_1$prefix_glob_2_match$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with a linear combination of glob prefixes, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_double_quotes$prefix_glob_2_match$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_double_quotes$prefix_glob_2_match$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with a scalar prefix followed by a glob prefix, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_glob_2_match$prefix_double_quotes$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_glob_2_match$prefix_double_quotes$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with a glob prefix followed by a scalar prefix, on the command line" \
    "Dependencies: erase"

    abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "$prefix_glob_1_match_1$prefix_glob_2_match$prefix_double_quotes$prefix_multi_word$test_abbr_abbreviation"; [[ $reply[loutput] == "$prefix_glob_1_match_1$prefix_glob_2_match$prefix_double_quotes$prefix_multi_word$test_abbr_expansion" ]]' \
    "Can expand a session abbreviation, prefixed with mixed glob and scalar prefixes, on the command line" \
    "Dependencies: erase"

    abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line $test_abbr_abbreviation_multiword; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a two-word abbreviation on the command line" \
    "Dependencies: erase"
    abbr erase $test_abbr_abbreviation_multiword

    abbr "a b c"=$test_abbr_expansion
    ztr test 'typeset -A reply; abbr-expand-line "a b c"; [[ $reply[loutput] == $test_abbr_expansion ]]' \
    "Can expand a three-word abbreviation on the command line" \
    "Dependencies: erase"
    abbr erase "a b c"

    ## END ~DUPE abbr-expand.ztr.zsh

    ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=1

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line "foo; $test_abbr_abbreviation"
    ztr skip '[[ $reply[loutput] == "foo; $test_abbr_expansion" ]] \
    && (( res == 0 ))' \
    "[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after ;"

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line "foo \& $test_abbr_abbreviation"
    ztr skip '[[ $reply[loutput] == "foo \& $test_abbr_expansion" ]] \
    && (( res == 0 ))' \
    "[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after &"

    abbr $test_abbr_abbreviation=$test_abbr_expansion
    abbr-expand-line "foo | $test_abbr_abbreviation"
    ztr skip '[[ $reply[loutput] == "foo | $test_abbr_expansion" ]] \
    && (( res == 0 ))' \
    "[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after |"

    ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=0

    ztr skip '@TODO' 'Can customize split function'
  } always {
  unfunction -m ZTR_TEARDOWN_FN
  }
}


main
