#!/usr/bin/env zsh

main() {
	abbr add $test_abbr_abbreviation=$test_abbr_expansion
	ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
		"Can expand an abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation

	abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
	ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
		"Can expand a global abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation

	abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
	ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
		"Can expand a session abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation

	abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
	ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
		"Can expand a global session abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation

	abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
	ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
		"Can expand a two-word abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation_multiword

	abbr "a b c"=$test_abbr_expansion
	ztr test '[[ $(abbr expand "a b c") == $test_abbr_expansion ]]' \
		"Can expand a three-word abbreviation in a script" \
		"Dependencies: erase"
	abbr erase $test_abbr_abbreviation_multiword
}

main
