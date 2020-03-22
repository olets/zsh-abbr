ZSH_ABBR_USER_PATH=$(mktemp ${0:A:h}/abbreviations.XXXXXX)
source ${0:A:h}/../zsh-abbr.zsh

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"
test_abbr="$test_abbr_abbreviation=$test_abbr_expansion"

message="abbr --add && abbr --list-commands "
abbr --add $test_abbr
if [[ $(abbr --list-commands) == "abbr $test_abbr_abbreviation=${(qqq)test_abbr_expansion}" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr --erase "
abbr --erase $test_abbr_abbreviation
if [[ $(abbr --list-commands) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr "
abbr $test_abbr
if [[ $(abbr --list-commands) == "abbr $test_abbr_abbreviation=${(qqq)test_abbr_expansion}" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation

message="abbr --clear-session "
abbr -S $test_abbr
abbr --clear-session
if [[ $(abbr --list-commands) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr --expand "
abbr $test_abbr
if [[ $(abbr --expand $test_abbr_abbreviation) == $test_abbr_expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation

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

rm $ZSH_ABBR_USER_PATH
