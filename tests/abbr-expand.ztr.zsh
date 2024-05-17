#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	{
		ZTR_TEARDOWN_FN() {
			emulate -LR zsh
			
			abbr erase $test_abbr_abbreviation
		}

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can expand an abbreviation in a script" \
			"Dependencies: erase"

		abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can expand a global abbreviation in a script" \
			"Dependencies: erase"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can expand a session abbreviation in a script" \
			"Dependencies: erase"

		abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can expand a global session abbreviation in a script" \
			"Dependencies: erase"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_one_word$test_abbr_abbreviation") == "$prefix_one_word$test_abbr_expansion" ]]' \
			"Can expand an abbreviation, prefixed with one word, in a script" \
			"Dependencies: erase"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_one_word$test_abbr_abbreviation") == "$prefix_one_word$test_abbr_expansion" ]]' \
			"Can expand a session abbreviation, prefixed with one word, in a script" \
			"Dependencies: erase"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_multi_word$test_abbr_abbreviation") == "$prefix_multi_word$test_abbr_expansion" ]]' \
			"Can expand an abbreviation, prefixed with multiple words, in a script" \
			"Dependencies: erase"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_multi_word$test_abbr_abbreviation") == "$prefix_multi_word$test_abbr_expansion" ]]' \
			"Can expand a session abbreviation, prefixed with multiple words, in a script" \
			"Dependencies: erase"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_double_quotes$test_abbr_abbreviation") == "$prefix_double_quotes$test_abbr_expansion" ]]' \
			"Can expand an abbreviation, prefixed with a prefix containing single-quoted double quotes, in a script" \
			"Dependencies: erase"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_double_quotes$test_abbr_abbreviation") == "$prefix_double_quotes$test_abbr_expansion" ]]' \
			"Can expand a session abbreviation, prefixed with a prefix containing single-quoted double quotes, in a script" \
			"Dependencies: erase"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_single_quotes$test_abbr_abbreviation") == "$prefix_single_quotes$test_abbr_expansion" ]]' \
			"Can expand an abbreviation, prefixed with a prefix containing double-quoted single quotes, in a script" \
			"Dependencies: erase"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand "$prefix_single_quotes$test_abbr_abbreviation") == "$prefix_single_quotes$test_abbr_expansion" ]]' \
			"Can expand a session abbreviation, prefixed with a prefix containing double-quoted single quotes, in a script" \
			"Dependencies: erase"

		abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can expand a two-word abbreviation in a script" \
			"Dependencies: erase"
		abbr erase $test_abbr_abbreviation_multiword

		abbr "a b c"=$test_abbr_expansion
		ztr test '[[ $(abbr expand "a b c") == $test_abbr_expansion ]]' \
			"Can expand a three-word abbreviation in a script" \
			"Dependencies: erase"
		abbr erase "a b c"
	} always {
		unfunction -m ZTR_TEARDOWN_FN
	}
}

main
