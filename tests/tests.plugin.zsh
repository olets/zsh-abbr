ZSH_ABBR_USER_PATH=$(mktemp ${0:A:h}/abbreviations.XXXXXX)
source ${0:A:h}/../zsh-abbr.zsh

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"
test_abbr="$test_abbr_abbreviation=$test_abbr_expansion"

# Can add an abbreviation with the --add flag,
# and can list abbreviations
message="abbr --add && abbr --list-commands "
abbr --add $test_abbr
if [[ $(abbr --list-commands) == "abbr $test_abbr_abbreviation=${(qqq)test_abbr_expansion}" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
echo

# Can erase an abbreviation
message="abbr --erase "
abbr --erase $test_abbr_abbreviation
if [[ $(abbr --list-commands) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
echo

# Can add an abbreviation without the --add flag
message="abbr "
abbr $test_abbr
if [[ $(abbr --list-commands) == "abbr $test_abbr_abbreviation=${(qqq)test_abbr_expansion}" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation
echo

# Can clear session abbreviations
message="abbr --clear-session "
abbr -S $test_abbr
abbr --clear-session
if [[ $(abbr --list-commands) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
echo

# Can expand an abbreviation in a script
message="abbr --expand "
abbr $test_abbr
if [[ $(abbr --expand $test_abbr_abbreviation) == $test_abbr_expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation
echo

# Can rename an abbreviation
message="abbr --rename "
abbr $test_abbr
abbr --rename $test_abbr_abbreviation ${test_abbr_abbreviation}_new
if [[ $(abbr -x ${test_abbr_abbreviation}_new) == $test_abbr_expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e ${test_abbr_abbreviation}_new
echo

# Double-quoted single quotes are preserved
abbreviation=a
expansion="b'c'd"
message="abbr a=$expansion "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

# Single-quoted double quotes are preserved
abbreviation=a
expansion='b"c"d'
message="abbr a=$expansion "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

# Bare single quotes at the start of a string are swallowed
abbreviation=a
expansion='b'cd
message="abbr a='b'cd "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

# Bare single quotes in the middle of a string are swallowed
abbreviation=a
expansion=b'c'd
message="abbr a=b'c'd "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

# Bare double quotes at the start of a string are swallowed
abbreviation=a
expansion="b"cd
message="abbr a=\"b\"cd "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

# Bare double quotes in the middle of a string are swallowed
abbreviation=a
expansion=b"c"d
message="abbr a=b\"c\"d "
abbr $abbreviation=$expansion
if [[ $(abbr --expand $abbreviation) == $expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $abbreviation
echo

rm $ZSH_ABBR_USER_PATH
