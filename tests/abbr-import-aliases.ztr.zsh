#!/usr/bin/env zsh

abbreviation=zsh_abbr_test_alias
expansion=abc
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Can import aliases" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source $abbr_dir/zsh-abbr.zsh

# Multiword

abbreviation=zsh_abbr_test_alias
expansion="a b"
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Can import a multi-word alias" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source $abbr_dir/zsh-abbr.zsh

# Quotes

abbreviation=zsh_abbr_test_alias
expansion="a \"b\""
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Can import a double-quoted alias with escaped double quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source $abbr_dir/zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion='a "b"'
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Can import a single-quoted alias with double quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source $abbr_dir/zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion="a 'b'"
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
	"Can import a double-quoted alias with single quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
