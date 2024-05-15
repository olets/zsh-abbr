#!/usr/bin/env zsh

main() {
	emulate -LR zsh
	
	abbr add $test_abbr_abbreviation=$test_abbr_expansion
	abbr erase $test_abbr_abbreviation
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase an abbreviation" \
		"Dependencies: add, erase"
		
	# TODO
	# See
	# - https://github.com/olets/zsh-abbr/issues/118
	abbr add ${test_abbr_abbreviation}^=$test_abbr_expansion
	abbr erase ${test_abbr_abbreviation}^
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase an abbreviation ending in a caret" \
		"Dependencies: add, erase. Issues: 118"
	
	# TODO
	# See
	# - https://github.com/olets/zsh-abbr/issues/118
	abbr add ^$test_abbr_abbreviation=$test_abbr_expansion
	abbr erase ^$test_abbr_abbreviation
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase an abbreviation starting with a caret" \
		"Dependencies: add, erase. Issues: 118"
	
	# TODO
	# See
	# - https://github.com/olets/zsh-abbr/issues/118
	abbr add ${test_abbr_abbreviation}^${test_abbr_abbreviation}=$test_abbr_expansion
	abbr erase ${test_abbr_abbreviation}^${test_abbr_abbreviation}
	ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
		"Can erase an abbreviation with an embedded caret" \
		"Dependencies: add, erase. Issues: 118"

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
