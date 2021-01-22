abbr_quiet_saved=$ABBR_QUIET
ABBR_QUIET=1
ABBR_USER_ABBREVIATIONS_FILE=${0:A:h}/abbreviations.$RANDOM
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

dependencies=
typeset -a result
typeset -i failures=0
typeset -i skips=0
typeset -i passes=0

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"

run() {
	if eval $1; then
		(( passes++ ))
		echo "$fg[green]PASS$reset_color $test_name${dependencies:+\\nDependencies: $dependencies}"
	else
		(( failures++ ))
		echo "$fg[red]FAIL$reset_color $test_name${dependencies:+\\nDependencies: $dependencies}"
	fi

	echo
}

skip() {
	(( skips++ ))
	echo "$fg[yellow]SKIP$reset_color $test_name${dependencies:+\\nDependencies: $dependencies}"
	echo
}

### ### ### All tests must be below this line ### ### ###

test_name="Can erase an abbreviation"
dependencies="add"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
abbr erase $test_abbr_abbreviation
run '[[ ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ]]'

test_name="Can add an abbreviation with the add flag"
dependencies="erase"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can add a global abbreviation with the add flag"
dependencies="erase"
abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
run '[[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can add a regular session abbreviation with the add flag"
dependencies="erase"
abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
run '[[ ${(Q)ABBR_REGULAR_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can add a global session abbreviation with the add flag"
dependencies="erase"
abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
run '[[ ${(Q)ABBR_GLOBAL_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can add an abbreviation without the add flag"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can clear session abbreviations"
dependencies=
abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
run '[[ ${#ABBR_REGULAR_SESSION_ABBREVIATIONS} == 0 ]]'

test_name="Can expand an abbreviation in a script"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
run '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

test_name="Can rename an abbreviation"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
run '! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} )) \
	&& [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[${test_abbr_abbreviation}_new]} == $test_abbr_expansion ]]'
abbr erase ${test_abbr_abbreviation}_new

test_name="Double-quoted single quotes in the expansion are preserved"
abbreviation=a
expansion="b'c'd"
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Single-quoted double quotes in the expansion are preserved"
abbreviation=a
expansion='b"c"d'
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Bare single quotes at the start of the expansion are swallowed"
abbreviation=a
expansion='b'cd
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Bare single quotes in the middle of the expansion are swallowed"
abbreviation=a
expansion=b'c'd
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Bare double quotes at the start of the expansion are swallowed"
abbreviation=a
expansion="b"cd
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Bare double quotes in the middle of the expansion are swallowed"
abbreviation=a
expansion=b"c"d
dependencies="erase"
abbr $abbreviation=$expansion
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation

test_name="Can import aliases"
abbreviation=zsh_abbr_test_alias
expansion=abc
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test_name="Can import a multi-word alias"
abbreviation=zsh_abbr_test_alias
expansion="a b"
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test_name="Can import a double-quoted alias with escaped double quotation marks"
abbreviation=zsh_abbr_test_alias
expansion="a \"b\""
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test_name="Can import a single-quoted alias with double quotation marks"
abbreviation=zsh_abbr_test_alias
expansion='a "b"'
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test_name="Can import a double-quoted alias with single quotation marks"
dependencies="erase"
abbreviation=zsh_abbr_test_alias
expansion="a 'b'"
alias $abbreviation=$expansion
abbr import-aliases
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]'
abbr erase $abbreviation
unalias $abbreviation

test_name="Can delete a user abbreviation from outside abbr without unexpected retention"
dependencies=
abbr add $test_abbr_abbreviation=$test_abbr_expansion
echo '' > $ABBR_USER_ABBREVIATIONS_FILE
run '[[ -z $(abbr expand $test_abbr_abbreviation) ]]'

test_name="Can add a user abbreviation from outside abbr without data loss"
dependencies="erase"
echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]'
abbr erase $test_abbr_abbreviation

abbr import-git-aliases --file ${0:A:h}/test-gitconfig

test_name="Can import single-word subcommand Git aliases"
dependencies="erase"
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[test-subcommand]} == "git status" ]] \
	&& [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-subcommand]} == "git status" ]]'
abbr erase test-subcommand
abbr erase gtest-subcommand

test_name="Can import multi-word subcommand Git aliases"
dependencies="erase"
run '[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[test-subcommand-multiword]} == "git checkout main" ]] \
	&& [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-subcommand-multiword]} == "git checkout main" ]]'
abbr erase test-subcommand-multiword
abbr erase gtest-subcommand-multiword

test_name="Cannot import command Git aliases"
dependencies="erase"
run '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-command]} )) \
	&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-command]} ))'

test_name="Cannot import single-line function Git aliases"
dependencies="erase"
run '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-function]} )) \
	&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-function]} ))'

test_name="Cannot import multi-line function Git aliases"
dependencies="erase"
run '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS[test-function-multiline]} )) \
	&& (( ! ${+ABBR_GLOBAL_USER_ABBREVIATIONS[gtest-function-multiline]} ))'


### ### ### All tests must be above this line ### ### ###

echo
(( skips )) && echo $fg[yellow]$skips tests skipped$reset_color && echo
(( passes || failures )) && echo $(( passes + failures )) tests run
(( passes )) && echo $fg[green]$passes tests passed$reset_color
(( failures )) && echo $fg[red]$failures tests failed$reset_color

rm $ABBR_USER_ABBREVIATIONS_FILE
ABBR_QUIET=$abbr_quiet_saved
