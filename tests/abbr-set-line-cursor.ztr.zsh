#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	typeset -A reply

	ABBR_SET_LINE_CURSOR=1

	_abbr_set_line_cursor $test_abbr_abbreviation$ABBR_LINE_CURSOR_MARKER$test_abbr_abbreviation_2
	ztr test '[[ $reply[cursor_was_placed] == 1 ]] \
			&& [[ $reply[loutput] == $test_abbr_abbreviation ]] \
			&& [[ $reply[routput] == $test_abbr_abbreviation_2 ]] \
			' \
		"_abbr_set_line_cursor returns correct values when cursor placement is enabled and cursor marker is present"
	abbr erase $test_abbr_abbreviation

	_abbr_set_line_cursor $test_abbr_abbreviation$test_abbr_abbreviation_2
	ztr test '[[ $reply[cursor_was_placed] == 0 ]]' \
		"_abbr_set_line_cursor returns correct values when cursor placement is enabled but cursor marker is not present"
	abbr erase $test_abbr_abbreviation

	ABBR_SET_LINE_CURSOR=0

	_abbr_set_line_cursor $test_abbr_abbreviation$ABBR_LINE_CURSOR_MARKER$test_abbr_abbreviation_2
	ztr test '[[ $reply[cursor_was_placed] == 0 ]]' \
		"_abbr_set_line_cursor returns correct values when cursor placement is disabled"
	abbr erase $test_abbr_abbreviation
}

main
