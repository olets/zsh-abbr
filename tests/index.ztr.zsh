#!/usr/bin/env zsh

# Tests require ztr
# https://github.com/olets/zsh-test-runner
# Run the suite by sourcing it or by passing it to `zsh`

main() {
	local cmd

	cmd=$1

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
	rm -f $ABBR_USER_ABBREVIATIONS_FILE

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
