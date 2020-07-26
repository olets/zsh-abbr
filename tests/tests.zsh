abbr_quiet_saved=$ABBR_QUIET
ABBR_QUIET=1
ABBR_USER_ABBREVIATIONS_FILE=${0:A:h}/abbreviations.$RANDOM
touch $ABBR_USER_ABBREVIATIONS_FILE
source ${0:A:h}/../zsh-abbr.zsh
pass=0

typeset -a result

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"

# Can add an abbreviation with the add flag
message="abbr add"
abbr add $test_abbr_abbreviation=$test_abbr_expansion
if [[ ${(Q)ABBR_REGULAR_USER_ABBREVIATIONS[$test_abbr_abbreviation]} == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can erase an abbreviation
message="abbr add and erase "
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

# Can add an abbreviation without the add flag
message="abbr "
abbr $test_abbr_abbreviation=$test_abbr_expansion
result=( ${(f)"$(abbr list-commands)"} )
if [[ $result[1] == "abbr $test_abbr_abbreviation=${(qqq)test_abbr_expansion}" ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# Can clear session abbreviations
message="abbr clear-session "
abbr -S $test_abbr_abbreviation=$test_abbr_expansion
abbr clear-session
result=( ${(f)"$(abbr list-commands)"} )
if [[ ${#result} == 0 ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can expand an abbreviation in a script
message="abbr expand "
abbr $test_abbr_abbreviation=$test_abbr_expansion
result=( ${(f)"$(abbr expand $test_abbr_abbreviation)"} )
if [[ $result[1] == $test_abbr_expansion ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
abbr erase $test_abbr_abbreviation
echo

# # Can rename an abbreviation
message="abbr rename "
abbr $test_abbr_abbreviation=$test_abbr_expansion
abbr rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
result=( ${(f)"$(abbr expand ${test_abbr_abbreviation}_new)"} )
if [[ $result[1] == $test_abbr_expansion ]]; then
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
message="abbr a=$expansion "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="abbr a=$expansion "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="abbr a='b'cd "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="abbr a=b'c'd "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="abbr a=\"b\"cd "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="abbr a=b\"c\"d "
abbr $abbreviation=$expansion
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="importing a single-word alias "
alias $abbreviation=$expansion
abbr import-aliases
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="importing a multi-word alias "
alias $abbreviation=$expansion
abbr import-aliases
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="importing a double-quoted multi-word alias with escape double quotes "
alias $abbreviation=$expansion
abbr import-aliases
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="importing a single-quoted multi-word alias with double quotes "
alias $abbreviation=$expansion
abbr import-aliases
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
message="importing a double-quoted multi-word alias with single quotes "
alias $abbreviation=$expansion
abbr import-aliases
result=( ${(f)"$(abbr expand $abbreviation)"} )
if [[ $result[1] == $expansion ]]; then
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
result=( ${(f)"$(abbr expand $test_abbr_abbreviation)"} )
if [[ ${#result} == 0 ]]; then
	message="$fg[green]PASS$reset_color $message"
else
	echo $result[1]
	message="$fg[red]FAIL$reset_color $message"
	pass=1
fi
echo $message
echo

# Can add a user abbreviation from outside abbr without data loss
message="abbreviation added externally can be expanded"
echo "abbr add $test_abbr_abbreviation='$test_abbr_expansion'" > $ABBR_USER_ABBREVIATIONS_FILE
result=( ${(f)"$(abbr expand $test_abbr_abbreviation)"} )
if [[ $result[1] == $test_abbr_expansion ]]; then
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
