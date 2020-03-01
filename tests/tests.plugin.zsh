ZSH_ABBR_USER_PATH=$(mktemp ${0:A:h}/abbreviations.XXXXXX)
source ${0:A:h}/../zsh-abbr.zsh

test_abbr_abbreviation="zsh_abbr_test"
test_abbr_expansion="zsh abbr test"
test_abbr="zsh_abbr_test=\"$test_abbr_expansion\""

message="abbr --add && abbr -s "
abbr --add $test_abbr
if [[ $(abbr -s) == "abbr $test_abbr" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr --show "
if [[ $(abbr -s) == $(abbr --show) ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr -e "
abbr -e $test_abbr_abbreviation
if [[ $(abbr -s) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr -a "
abbr -a $test_abbr
if [[ $(abbr -s) == "abbr $test_abbr" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr --erase "
abbr -e $test_abbr_abbreviation
if [[ $(abbr -s) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr "
abbr $test_abbr
if [[ $(abbr -s) == "abbr $test_abbr" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation

message="abbr -c "
abbr -S $test_abbr
abbr -c
if [[ $(abbr -s) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr --clear-session "
abbr -S $test_abbr
abbr --clear-session
if [[ $(abbr -s) == "" ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message

message="abbr -x "
abbr $test_abbr
if [[ $(abbr -x $test_abbr_abbreviation) == $test_abbr_expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e $test_abbr_abbreviation

message="abbr -r "
abbr $test_abbr
abbr -r $test_abbr_abbreviation ${test_abbr_abbreviation}_new
if [[ $(abbr -x ${test_abbr_abbreviation}_new) == $test_abbr_expansion ]]; then
	message+="passed"
else
	message+="failed"
fi
echo $message
abbr -e ${test_abbr_abbreviation}_new

rm $ZSH_ABBR_USER_PATH
