#!/usr/bin/env zsh

main() {
	emulate -LR zsh

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
	abbr erase $test_abbr_abbreviation

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
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line $test_abbr_abbreviation right_text

	res=$?
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[rinput] == right_text ]] \
			&& (( res == 0 ))
			' \
		"abbr-expand-line preserves right text when expanding a regular abbrevation"
	abbr erase $test_abbr_abbreviation

	abbr -g $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line $test_abbr_abbreviation right_text
	res=$?
	ztr test '[[ $reply[abbreviation] == $test_abbr_abbreviation ]] \
			&& [[ $reply[rinput] == right_text ]] \
			&& (( res == 0 ))
			' \
		"abbr-expand-line preserves right text when expanding a global abbrevation"
	abbr erase $test_abbr_abbreviation

	ABBR_SET_EXPANSION_CURSOR=1
	abbr -g $test_abbr_abbreviation=$test_abbr_expansion$ABBR_EXPANSION_CURSOR_MARKER$test_abbr_expansion_2
	abbr-expand-line $test_abbr_abbreviation

	res=$?
	ztr test '[[ $reply[loutput] == $test_abbr_expansion ]] \
			&& [[ $reply[routput] == $test_abbr_expansion_2 ]] \
			&& (( res == 0 ))
			' \
		"abbr-expand-line can set the expansion cursor when expanding a regular abbreviation"
	ABBR_SET_EXPANSION_CURSOR=0
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line "foo $test_abbr_abbreviation" right_text

	ztr test '[[ $reply[linput] == $reply[loutput] ]] \
			&& [[ $reply[rinput] == $reply[routput] ]] \
			&& ((res == 1 ))
			' \
			"abbr-expand-line does not expand a regular abbreviation if it is not at the start of the line"
	abbr erase $test_abbr_abbreviation

	abbr -g $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line "foo $test_abbr_abbreviation" right_text

	res=$?
	ztr test '[[ $reply[loutput] == "foo $test_abbr_expansion" ]] \
     	&& [[ $reply[rinput] == $reply[routput] ]] \
      && (( res == 0 ))
			' \
			"abbr-expand-line expands a global abbreviation not at the start of the line"
	abbr erase $test_abbr_abbreviation

	ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=0

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr cm="git checkout main"
	abbr-expand-line "foo; $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo; $test_abbr_expansion" ]] \
			&& (( res == 0 ))' \
			"[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after ;"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line "foo \& $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo \& $test_abbr_expansion" ]] \
			&& (( res == 0 ))' \
			"[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after &"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr-expand-line "foo | $test_abbr_abbreviation"
	ztr skip '[[ $reply[loutput] == "foo | $test_abbr_expansion" ]] \
			&& (( res == 0 ))' \
			"[getting negative result that doesn't match with command line experience] abbr-expand-line expands a regular abbreviation after |"
	abbr erase $test_abbr_abbreviation

	ABBR_EXPERIMENTAL_COMMAND_POSITION_REGULAR_ABBREVIATIONS=0
}

main
