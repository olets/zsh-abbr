#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  local -A reply
  local -i res

  ABBR_SET_LINE_CURSOR=1

  abbr-set-line-cursor $test_abbr_abbreviation$ABBR_LINE_CURSOR_MARKER$test_abbr_abbreviation_2
  ztr test '[[ $reply[loutput] == $test_abbr_abbreviation ]] \
      && [[ $reply[routput] == $test_abbr_abbreviation_2 ]] \
      ' \
    "abbr-set-line-cursor returns correct values when cursor placement is enabled and cursor marker is present"
  abbr erase $test_abbr_abbreviation

  abbr-set-line-cursor $test_abbr_abbreviation$test_abbr_abbreviation_2
  res=$?
  ztr test '(( res ))' \
    "abbr-set-line-cursor returns correct values when cursor placement is enabled but cursor marker is not present"
  abbr erase $test_abbr_abbreviation

  ABBR_SET_LINE_CURSOR=0

  abbr-set-line-cursor $test_abbr_abbreviation$ABBR_LINE_CURSOR_MARKER$test_abbr_abbreviation_2
  res=$?
  ztr test '(( res ))' \
    "abbr-set-line-cursor returns correct values when cursor placement is disabled"
  abbr erase $test_abbr_abbreviation
}

main
