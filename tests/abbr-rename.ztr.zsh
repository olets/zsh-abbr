#!/usr/bin/env zsh

abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation $test_abbr_abbreviation_2
ztr test '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} )) \
		&& [[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_2}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can rename a single-word abbreviation to another single word" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_2

abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation $test_abbr_abbreviation_multiword
ztr test '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} )) \
		&& [[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can rename an single-word abbreviation to multiple words" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
abbr rename $test_abbr_abbreviation_multiword $test_abbr_abbreviation
ztr test '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} )) \
		&& [[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can rename an multi-word abbreviation to a single word" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
abbr rename $test_abbr_abbreviation_multiword $test_abbr_abbreviation_multiword_2
ztr test '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} )) \
		&& [[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword_2}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can rename an multi-word abbreviation to different words" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword_2
