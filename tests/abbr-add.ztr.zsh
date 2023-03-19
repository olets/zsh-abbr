#!/usr/bin/env zsh

abbr add $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add an abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add a regular session abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

# Manual

echo "abbr \"$test_abbr_abbreviation\"=\"$test_abbr_expansion\"" > $ABBR_USER_ABBREVIATIONS_FILE
abbr load
ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add a user abbreviation from outside abbr without data loss" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

# Implicit

abbr $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add an abbreviation without the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
	"Can add a multi-word abbreviation without the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation_multiword

# Global

abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr -g expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add a global abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr -g -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can add a global session abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation

# Multiword

abbr add $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
	"Can add a multi-word abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation_multiword

abbr add -S $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ $(abbr -S expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
	"Can add a multi-word regular session abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation_multiword

# Multiword global

abbr add -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ $(abbr -g expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
	"Can add a multi-word global abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation_multiword

abbr add -S -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
ztr test '[[ $(abbr -g -S expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
	"Can add a multi-word global session abbreviation with the add subcommand" \
	"Dependencies: erase, expand"
abbr erase $test_abbr_abbreviation_multiword

# Quotes

abbreviation=a
expansion='b'cd
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Bare single quotes at the start of the expansion are swallowed" \
	"Dependencies: erase, expand"
abbr erase $abbreviation

abbreviation=a
expansion=b'c'd
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Bare single quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase, expand"
abbr erase $abbreviation

abbreviation=a
expansion='b"c"d'
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Single-quoted double quotes in the expansion are preserved" \
	"Dependencies: erase, expand"
abbr erase $abbreviation

abbreviation=a
expansion="b"cd
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Bare double quotes at the start of the expansion are swallowed" \
	"Dependencies: erase, expand"
abbr erase $abbreviation

abbreviation=a
expansion=b"c"d
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Bare double quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase, expand"
abbr erase $abbreviation

abbreviation=a
expansion="b'c'd"
abbr $abbreviation=$expansion
ztr test '[[ $(abbr expand $abbreviation) == $expansion ]]' \
	"Double-quoted single quotes in the expansion are preserved" \
	"Dependencies: erase, expand"
abbr erase $abbreviation
