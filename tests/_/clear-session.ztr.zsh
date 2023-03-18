#!/usr/bin/env zsh

abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
ztr test '[[ ${#ABBR_REGULAR_SESSION_ABBREVIATIONS} == 0 ]]' \
	"Can clear session abbreviations"
