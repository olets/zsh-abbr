abbr_quiet_saved=$ABBR_QUIET
ABBR_QUIET=1
ABBR_USER_ABBREVIATIONS_FILE=${0:A:h}/abbreviations.$RANDOM
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh
pass=0

typeset -a result

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"

# Can erase an abbreviation
message="abbr erase (dependency: add)"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
abbr erase $test_abbr_abbreviation
if [[ ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can add an abbreviation with the add flag
message="abbr add (dependency: erase)"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can add a global abbreviation with the add flag
message="abbr add -g (dependency: erase)"
abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_GLOBAL_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can add a regular session abbreviation with the add flag
message="abbr add -S (dependency: erase)"
abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can add a global session abbreviation with the add flag
message="abbr add -S -g (dependency: erase)"
abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_GLOBAL_SESSION_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can add an abbreviation without the add flag
message="abbr (dependency: erase)"
abbr $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can clear session abbreviations
message="abbr clear-session (add session dependency)"
abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
if [[ ${#ABBR_REGULAR_SESSION_ABBREVIATIONS} == 0 ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can expand an abbreviation in a script
message="abbr expand (dependency: erase)"
abbr $test_abbr_abbreviation=$test_abbr_expansion
if [[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# # Can rename an abbreviation
message="abbr rename (dependency: erase)"
abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
if ! (( ${+ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} )) && \
	[[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[${test_abbr_abbreviation}_new]} == $test_abbr_expansion ]]; then

	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase ${test_abbr_abbreviation}_new
echo

# Double-quoted single quotes are preserved
abbreviation=a
expansion="b'c'd"
message="abbr a=$expansion (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Single-quoted double quotes are preserved
abbreviation=a
expansion='b"c"d'
message="abbr a=$expansion (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Bare single quotes at the start of a string are swallowed
abbreviation=a
expansion='b'cd
message="abbr a='b'cd (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Bare single quotes in the middle of a string are swallowed
abbreviation=a
expansion=b'c'd
message="abbr a=b'c'd (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Bare double quotes at the start of a string are swallowed
abbreviation=a
expansion="b"cd
message="abbr a=\"b\"cd (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Bare double quotes in the middle of a string are swallowed
abbreviation=a
expansion=b"c"d
message="abbr a=b\"c\"d (dependency: erase)"
abbr $abbreviation=$expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo

# Can import aliases
abbreviation=zsh_abbr_test_alias
expansion=abc
message="importing a single-word alias (dependency: erase)"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

# Can import a multi-word alias
abbreviation=zsh_abbr_test_alias
expansion="a b"
message="importing a multi-word alias (dependency: erase)"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

# Can import a double-quoted alias with escaped double quotation marks
abbreviation=zsh_abbr_test_alias
expansion="a \"b\""
message="importing a double-quoted multi-word alias dependency: escape double quotes (has erase)"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

# Can import a single-quoted alias with double quotation marks
abbreviation=zsh_abbr_test_alias
expansion='a "b"'
message="importing a single-quoted multi-word alias dependency: double quotes (has erase)"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation
rm $ABBR_USER_ABBREVIATIONS_FILE
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh

# Can import a double-quoted alias with single quotation marks
abbreviation=zsh_abbr_test_alias
expansion="a 'b'"
message="importing a double-quoted multi-word alias dependency: single quotes (has erase)"
alias $abbreviation=$expansion
abbr import-aliases
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$abbreviation]} == $expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $abbreviation
echo
unalias $abbreviation

# Can delete a user abbreviation from outside abbr without unexpected retention
message="abbreviation deleted externally cannot be expanded"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
echo '' > $ABBR_USER_ABBREVIATIONS_FILE
if [[ -z $(abbr expand $test_abbr_abbreviation) ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	echo $result[1]
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can add a user abbreviation from outside abbr without data loss
message="abbreviation added externally can be expanded (dependency: erase)"
echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

rm $ABBR_USER_ABBREVIATIONS_FILE
if (( pass )); then
	echo >&1
	# exit 0
else
	echo >&2
	# exit 1
fi

ABBR_QUIET=$abbr_quiet_saved
