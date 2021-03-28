
# Tests require ztr
# https://github.com/olets/zsh-test-runner
# Run the suite by sourcing it or by passing it to `zsh`

abbr_quiet_saved=$ABBR_QUIET
ABBR_QUIET=1
ABBR_USER_ABBREVIATIONS_FILE=${0:A:h}/abbreviations.$RANDOM
touch $ABBR_USER_ABBREVIATIONS_FILE

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"

source ${0:A:h}/../zsh-abbr.zsh
source $ZTR_PATH

### ### ### All tests must be below this line ### ### ###

abbr add $test_abbr_abbreviation=$test_abbr_expansion
abbr erase $test_abbr_abbreviation
echo ${#ABBR_REGULAR_USER_ABBREVIATIONS}
ztr test '[[ ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ]]' \
	"Can erase an abbreviation" \
	"Dependencies: add"

abbr add $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add an abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add a global abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${(Q)ABBR_REGULAR_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add a regular session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${(Q)ABBR_GLOBAL_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add a global session abbreviation with the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add an abbreviation without the add flag" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
ztr test '[[ ${#ABBR_REGULAR_SESSION_ABBREVIATIONS} == 0 ]]' \
	"Can clear session abbreviations"

abbr $test_abbr_abbreviation=$test_abbr_expansion
ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
	"Can expand an abbreviation in a script" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
ztr test '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} )) \
		&& [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[${test_abbr_abbreviation}_new]} == $test_abbr_expansion ]]' \
	"Can rename an abbreviation" \
	"Dependencies: erase"
abbr erase ${test_abbr_abbreviation}_new

abbreviation=a
expansion="b'c'd"
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Double-quoted single quotes in the expansion are preserved" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion='b"c"d'
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Single-quoted double quotes in the expansion are preserved" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion='b'cd
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Bare single quotes at the start of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion=b'c'd
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Bare single quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion="b"cd
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Bare double quotes at the start of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=a
expansion=b"c"d
abbr $abbreviation=$expansion
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Bare double quotes in the middle of the expansion are swallowed" \
	"Dependencies: erase"
abbr erase $abbreviation

abbreviation=zsh_abbr_test_alias
expansion=abc
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Can import aliases" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion="a b"
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Can import a multi-word alias" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion="a \"b\""
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Can import a double-quoted alias with escaped double quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion='a "b"'
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Can import a single-quoted alias with double quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

abbreviation=zsh_abbr_test_alias
expansion="a 'b'"
alias $abbreviation=$expansion
abbr import-aliases
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]' \
	"Can import a double-quoted alias with single quotation marks" \
	"Dependencies: erase"
abbr erase $abbreviation
unalias $abbreviation

abbr add $test_abbr_abbreviation=$test_abbr_expansion
echo '' > $ABBR_USER_ABBREVIATIONS_FILE
ztr test '[[ -z $(abbr expand $test_abbr_abbreviation) ]]' \
	"Can delete a user abbreviation from outside abbr without unexpected retention"

echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]' \
	"Can add a user abbreviation from outside abbr without data loss" \
	"Dependencies: erase"
abbr erase $test_abbr_abbreviation

abbr import-git-aliases --file ${0:A:h}/test-gitconfig

ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[test-subcommand]} == "git status" ]] \
		&& [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-subcommand]} == "git status" ]]' \
	"Can import single-word subcommand Git aliases" \
	"Dependencies: erase"
abbr erase test-subcommand
abbr erase gtest-subcommand

ztr test '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[test-subcommand-multiword]} == "git checkout main" ]] \
		&& [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-subcommand-multiword]} == "git checkout main" ]]' \
	"Can import multi-word subcommand Git aliases" \
	"Dependencies: erase"
abbr erase test-subcommand-multiword
abbr erase gtest-subcommand-multiword

ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-command]} )) \
		&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-command]} ))' \
	"Cannot import command Git aliases" \
	"Dependencies: erase"

ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-function]} )) \
		&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-function]} ))' \
	"Cannot import single-line function Git aliases" \
	"Dependencies: erase"

ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-function-multiline]} )) \
		&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-function-multiline]} ))' \
	"Cannot import multi-line function Git aliases" \
	"Dependencies: erase"


### ### ### All tests must be above this line ### ### ###

rm $ABBR_USER_ABBREVIATIONS_FILE
ABBR_QUIET=$abbr_quiet_saved

echo
ztr summary
