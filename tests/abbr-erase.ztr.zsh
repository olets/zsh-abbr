#!/usr/bin/env zsh

main() {
	emulate -LR zsh
	
	abbr add $test_abbr_abbreviation=$test_abbr_expansion
	abbr erase $test_abbr_abbreviation
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase an abbreviation" \
		"Dependencies: add, erase"

	# Manual

	abbr add $test_abbr_abbreviation=$test_abbr_expansion
	echo '' > $ABBR_USER_ABBREVIATIONS_FILE
	ztr test '[[ -z $(abbr expand $test_abbr_abbreviation) ]]' \
		"Can delete a user abbreviation from outside abbr without unexpected retention"


	# Multiword

	abbr add $test_abbr_abbreviation_multiword=$test_abbr_expansion
	abbr erase $test_abbr_abbreviation_multiword
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase a multi-word abbreviation" \
		"Dependencies: add, erase"
}

main
