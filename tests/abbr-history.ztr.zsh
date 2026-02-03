#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	printf "\\n%s\\n\\n" _abbr_may_push_abbreviation_to_history

	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=0
	ztr test '! _abbr_may_push_abbreviation_to_history foo' \
		"Cannot push abbreviation to history when disnabled"

	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviation_to_history foo' \
		"Can push abbreviation to history when enabled"

	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviation_to_history " foo" off' \
		"Can push abbreviation to history if enabled and prefixed with space, if hist_ignore_space is explicitly off"

	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviation_to_history " foo"' \
		"Can push abbreviation to history if enabled and prefixed with space, if hist_ignore_space is implicitly off"

	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '! _abbr_may_push_abbreviation_to_history " foo" on' \
		"Cannot push abbreviation to history if enabled and prefixed with space, if hist_ignore_space is on"

	printf "\\n%s\\n\\n" _abbr_may_push_abbreviated_line_to_history

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=0
	ztr test '_abbr_may_push_abbreviated_line_to_history; (( $? == 1 ))' \
		"Cannot push abbreviated line to history when disabled, regardless of options"

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviated_line_to_history " foo" "bar" off on; (( $? == 2 ))' \
		"Cannot push abbreviated line to history if enabled and the expanded line is not different from the input line, but the input line is space-ignored"

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviated_line_to_history foo foo; (( $? == 3 ))' \
		"Cannot push abbreviated line to history if enabled and not space-ignored, but the expanded line is not different from the input line"

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=0
	ztr test '_abbr_may_push_abbreviated_line_to_history foo bar on' \
		"Can push abbreviated line to history if enabled, not space-ignored, the expanded line is different from the input line, and abbreviations are not pushed to history during expansion"

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviated_line_to_history foo bar on off foo; (( $? == 4 ))' \
	"Cannot push abbreviated line to history if enabled, not space-ignored, the expanded line is different from the input line, abbreviations are pushed to history during expansion, but duplicates are ignored and the input line is not different from the abbreviation"

	ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
	ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
	ztr test '_abbr_may_push_abbreviated_line_to_history foo bar off off foo' \
	"Can push abbreviated line to history if enabled, not space-ignored, the expanded line is different from the input line, abbreviations are pushed to history during expansion, and the input line is different from the abbreviation"
}

main
