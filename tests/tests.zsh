abbr_quiet_saved=$ABBR_QUIET
ABBR_QUIET=1
ABBR_USER_ABBREVIATIONS_FILE=${0:A:h}/abbreviations.$RANDOM
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh
dependencies=

typeset -a result

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"

test="Can erase an abbreviation"
dependencies="add"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
abbr erase $test_abbr_abbreviation
if [[ ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
echo

test="Can add an abbreviation with the add flag"
dependencies="erase"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can add a global abbreviation with the add flag"
dependencies="erase"
abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can add a regular session abbreviation with the add flag"
dependencies="erase"
abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can add a global session abbreviation with the add flag"
dependencies="erase"
abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_GLOBAL_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can add an abbreviation without the add flag"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can clear session abbreviations"
dependencies=
abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
if [[ ${#ABBR_REGULAR_SESSION_ABBREVIATIONS} == 0 ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
echo

test="Can expand an abbreviation in a script"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
if [[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

test="Can rename an abbreviation"
dependencies="erase"
abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
if ! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} )) && \
	[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[${test_abbr_abbreviation}_new]} == $test_abbr_expansion ]]; then

	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase ${test_abbr_abbreviation}_new
echo

test="Double-quoted single quotes are preserved"
abbreviation=a
expansion="b'c'd"
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Single-quoted double quotes are preserved"
abbreviation=a
expansion='b"c"d'
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Bare single quotes at the start of a string are swallowed"
abbreviation=a
expansion='b'cd
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Bare single quotes in the middle of a string are swallowed"
abbreviation=a
expansion=b'c'd
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Bare double quotes at the start of a string are swallowed"
abbreviation=a
expansion="b"cd
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Bare double quotes in the middle of a string are swallowed"
abbreviation=a
expansion=b"c"d
dependencies="erase"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo

test="Can import aliases"
abbreviation=zsh_abbr_test_alias
expansion=abc
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test="Can import a multi-word alias"
abbreviation=zsh_abbr_test_alias
expansion="a b"
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test="Can import a double-quoted alias with escaped double quotation marks"
abbreviation=zsh_abbr_test_alias
expansion="a \"b\""
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test="Can import a single-quoted alias with double quotation marks"
abbreviation=zsh_abbr_test_alias
expansion='a "b"'
dependencies="erase"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

test="Can import a double-quoted alias with single quotation marks"
dependencies="erase"
abbreviation=zsh_abbr_test_alias
expansion="a 'b'"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation

test="Can delete a user abbreviation from outside abbr without unexpected retention"
dependencies=
abbr add $test_abbr_abbreviation=$test_abbr_expansion
echo '' > $ABBR_USER_ABBREVIATIONS_FILE
if [[ -z $(abbr expand $test_abbr_abbreviation) ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	echo $result[1]
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
echo

test="Can add a user abbreviation from outside abbr without data loss"
dependencies="erase"
echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
else
	message="$fg[red]FAIL$reset_color $test${dependencies:+\\nDependencies: $dependencies}"
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

rm $ABBR_USER_ABBREVIATIONS_FILE
ABBR_QUIET=$abbr_quiet_saved
