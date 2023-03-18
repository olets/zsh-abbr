#!/usr/bin/env zsh

abbr add $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add an abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_SESSION_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a regular session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

# Manual

echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a user abbreviation from outside abbr without data loss" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

# Implicit

abbr $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add an abbreviation without the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a multi-word abbreviation without the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

# Global

abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${ABBR_GLOBAL_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a global abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${ABBR_GLOBAL_SESSION_ABBREVIATIONS[${(qqq)test_abbr_abbreviation}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a global session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

# Multiword

abbr add $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a multi-word abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

abbr add -S $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ ${ABBR_REGULAR_SESSION_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a multi-word regular session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

# Multiword global

abbr add -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ ${ABBR_GLOBAL_USER_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a multi-word global abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

abbr add -S -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ ${ABBR_GLOBAL_SESSION_ABBREVIATIONS[${(qqq)test_abbr_abbreviation_multiword}]} == ${(qqq)test_abbr_expansion} ]]' \
	"Can add a multi-word global session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation_multiword

# Quotes

abbreviation=a
expansion='b'cd
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Bare single quotes at the start of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion=b'c'd
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Bare single quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion='b"c"d'
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Single-quoted double quotes in the expansion are preserved" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion="b"cd
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Bare double quotes at the start of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion=b"c"d
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Bare double quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion="b'c'd"
abbr $abbreviation=$expansion
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Double-quoted single quotes in the expansion are preserved" \
	"Dependencies: erase"
abbr erase $abbreviation
