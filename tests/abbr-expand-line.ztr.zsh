#!/usr/bin/env zsh

main() {
	emulate -LR zsh
	typeset -A reply

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line $test_abbr_abbreviation
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[cursor_was_placed] == 0 ]] \
			&& [[ $reply[expansion] == $test_abbr_expansion ]] \
			&& [[ $reply[linput] == $test_abbr_abbreviation ]] \
			&& [[ $reply[loutput] == $test_abbr_expansion ]] \
			&& [[ -z $reply[rinput] ]] \
			&& [[ -z $reply[routput] ]] \
			&& [[ $reply[type] == regular ]] \
			' \
			"_abbr_expand_line returns correct values when expanding a line containing only a regular abbreviation"
	abbr erase $test_abbr_abbreviation

	abbr -g $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line $test_abbr_abbreviation
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[cursor_was_placed] == 0 ]] \
			&& [[ $reply[expansion] == $test_abbr_expansion ]] \
			&& [[ $reply[linput] == $test_abbr_abbreviation ]] \
			&& [[ $reply[loutput] == $test_abbr_expansion ]] \
			&& [[ -z $reply[rinput] ]] \
			&& [[ -z $reply[routput] ]] \
			&& [[ $reply[type] == global ]] \
			' \
		"_abbr_expand_line returns correct values when expanding a line containing only a global abbreviation"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line $test_abbr_abbreviation right_text
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[rinput] == right_text ]]
			' \
		"_abbr_expand_line preserves right text when expanding a regular abbrevation"
	abbr erase $test_abbr_abbreviation

	abbr -g $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line $test_abbr_abbreviation right_text
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[rinput] == right_text ]]
			' \
		"_abbr_expand_line preserves right text when expanding a global abbrevation"
	abbr erase $test_abbr_abbreviation

	ABBR_SET_EXPANSION_CURSOR=1
	abbr -g $test_abbr_abbreviation=$test_abbr_expansion$ABBR_EXPANSION_CURSOR_MARKER$test_abbr_expansion_2
	_abbr_expand_line $test_abbr_abbreviation
	ztr test '[[ $reply[loutput] == $test_abbr_expansion ]] \
			&& [[ $reply[routput] == $test_abbr_expansion_2 ]]
			' \
		"_abbr_expand_line can set the expansion cursor when expanding a regular abbreviation"
	ABBR_SET_EXPANSION_CURSOR=0
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line "foo $test_abbr_abbreviation" right_text
	ztr test '[[ $reply[linput] == $reply[loutput] ]] \
			&& [[ $reply[rinput] == $reply[routput] ]] \
			' \
			"_abbr_expand_line does not expand a regular abbreviation if it is not at the start of the line"
	abbr erase $test_abbr_abbreviation

	abbr -g $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line "foo $test_abbr_abbreviation" right_text
	ztr test '[[ $reply[loutput] == "foo $test_abbr_expansion" ]] \
     	&& [[ $reply[rinput] == $reply[routput] ]] \
			' \
			"_abbr_expand_line expands a global abbreviation not at the start of the line"
	abbr erase $test_abbr_abbreviation

	ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=0

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr cm="git checkout main"
	_abbr_expand_line "foo; $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo; $test_abbr_expansion" ]]' \
			"[getting false negative result] _abbr_expand_line expands a regular abbreviation after ;"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line "foo & $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo & $test_abbr_expansion" ]]' \
			"[getting false negative result] _abbr_expand_line expands a regular abbreviation after &"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	_abbr_expand_line "foo | $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo | $test_abbr_expansion" ]]' \
			"[getting false negative result] _abbr_expand_line expands a regular abbreviation after |"
	abbr erase $test_abbr_abbreviation

	ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=0
}

main
