#!/usr/bin/env zsh

# Tests require ztr
# https://github.com/olets/zsh-test-runner

# Run the test suite by
# sourcing this file
#
# ```
# . <path to this file>
# ```
#
# or by running it in a subshell with ZTR_PATH passed in as ztr_path
#
# ```
# ztr_path=$ZTR_PATH zsh <path to this file>
# ```

main() {
	local cmd

	cmd=$1
	
	ztr_path=${ztr_path:-$ZTR_PATH}

	if [[ -z $ztr_path ]]; then
		printf "You must provide \$ztr_path\n"
		return 1
	fi
	
	. $ztr_path

	# Save user configuration
	local abbr_quiet_saved=$ABBR_QUIET
	local abbr_user_abbreviations_file_saved=$ABBR_USER_ABBREVIATIONS_FILE

	local abbr_dir=${0:A:h}
	local test_dir=$abbr_dir/tests

	# Configure
	ABBR_QUIET=1
	ABBR_USER_ABBREVIATIONS_FILE=$test_dir/abbreviations.$RANDOM.tmp

	# Set up data
	touch $ABBR_USER_ABBREVIATIONS_FILE
	local test_abbr_abbreviation="zsh_abbr_test"
	local test_abbr_abbreviation_2="zsh_abbr_test_2"
	local test_abbr_abbreviation_multiword="zsh_abbr_test second_word"
	local test_abbr_abbreviation_multiword_2="zsh_abbr_test other_second_word"
	local test_abbr_expansion="zsh abbr test"
	local test_abbr_expansion_2="zsh abbr test 2"

	. $abbr_dir/zsh-abbr.zsh
	. $ZTR_PATH
	ztr clear

	# Run tests
	if [[ -n $cmd ]]; then
		. $test_dir/abbr-$cmd.ztr.zsh
	else
		for f ($test_dir/abbr-*.ztr.zsh(N.)); do
			printf "\nFile: %s\n\n" $f
			. $f
		done
	fi

	# Remove artifacts
	# TODO not deleting
	'builtin' 'command' rm -f $ABBR_USER_ABBREVIATIONS_FILE

	if $('builtin' 'command' -v abbr); then
		abbr load
	fi

	# Reset
	ABBR_QUIET=$abbr_quiet_saved
	ABBR_USER_ABBREVIATIONS_FILE=$abbr_user_abbreviations_file_saved

	echo
	ztr summary
}

main $@
