#!/usr/bin/env zsh

main() {
	emulate -LR zsh
	typeset -A reply

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line $test_abbr_abbreviation
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[cursor_was_placed] == 0 ]] \
			&& [[ $reply[expand_entire_buffer] == 1 ]] \
			&& [[ $reply[expansion] == $test_abbr_expansion ]] \
			&& [[ $reply[linput] == $test_abbr_abbreviation ]] \
			&& [[ $reply[loutput] == $test_abbr_expansion ]] \
			&& [[ -z $reply[rinput] ]] \
			&& [[ -z $reply[routput] ]] \
			&& [[ $reply[type] == regular ]] \
			' \
		"_abbr_expand_line returns correct values for regular abbreviation with no rinput"
	abbr erase $test_abbr_abbreviation
}

main
