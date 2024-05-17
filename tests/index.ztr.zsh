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
	emulate -LR zsh
	
	local \
		abbr_dir \
		abbr_tmpdir_saved \
		abbr_user_abbreviations_file_saved \
		cmd \
		prefix_double_quotes \
		prefix_glob \
		prefix_glob_match_1 \
		prefix_glob_match_2 \
		prefix_glob_mismatch \
		prefix_multi_word \
		prefix_one_word \
		prefix_single_quotes \
		test_abbr_abbreviation \
		test_abbr_abbreviation_2 \
		test_abbr_abbreviation_multiword \
		test_abbr_abbreviation_multiword_2 \
		test_abbr_expansion \
		test_abbr_expansion_2 \
		test_dir \
		test_prefix \
		test_tmpdir

	local -a abbr_prefixes_saved
	
	local -i abbr_quiet_saved

	ztr_path=${ztr_path:-$ZTR_PATH}

	if [[ -z $ztr_path ]]; then
		printf "You must provide \$ztr_path\n"
		return 1
	fi

	cmd=$1

	abbr_dir=${0:A:h}
	if [[ $abbr_dir =~ "/tests" ]]; then
		abbr_dir+=/..
	fi

	prefix_double_quotes='prefix with "double quotes"'
	prefix_glob="%ABBR_PREFIX_GLOB%?*globprefix"
	prefix_multi_word="multi-word prefix"
	prefix_one_word=one_word_prefix
	prefix_single_quotes="prefix with 'single quotes'"

	prefix_glob_match_1='.globprefix'
	prefix_glob_match_2='..globprefix'
	prefix_glob_mismatch='globprefix'

	test_dir=$abbr_dir/tests

	if [[ ${(%):-%#} == '#' ]]; then
		test_tmpdir=${${TMPDIR:-/tmp}%/}/zsh-abbr-privileged-users-tests
	else
		test_tmpdir=${${TMPDIR:-/tmp}%/}/zsh-abbr-tests
	fi

	# Save user configuration
	abbr_prefixes_saved=( $ABBR_REGULAR_ABBREVIATION_PREFIXES )
	abbr_quiet_saved=$ABBR_QUIET
	abbr_tmpdir_saved=$ABBR_TMPDIR
	abbr_user_abbreviations_file_saved=$ABBR_USER_ABBREVIATIONS_FILE

	# Configure
	typeset -a ABBR_REGULAR_ABBREVIATION_PREFIXES
	ABBR_REGULAR_ABBREVIATION_PREFIXES+=$prefix_double_quotes
	ABBR_REGULAR_ABBREVIATION_PREFIXES+=$prefix_glob
	ABBR_REGULAR_ABBREVIATION_PREFIXES+=$prefix_multi_word
	ABBR_REGULAR_ABBREVIATION_PREFIXES+=$prefix_one_word
	ABBR_REGULAR_ABBREVIATION_PREFIXES+=$prefix_single_quotes
	ABBR_QUIET=1
	ABBR_USER_ABBREVIATIONS_FILE=$test_dir/abbreviations.$RANDOM.tmp
	ABBR_TMPDIR=$test_tmpdir

	# Set up data
	touch $ABBR_USER_ABBREVIATIONS_FILE
	test_abbr_abbreviation="zsh_abbr_test"
	test_abbr_abbreviation_2="zsh_abbr_test_2"
	test_abbr_abbreviation_multiword="zsh_abbr_test second_word"
	test_abbr_abbreviation_multiword_2="zsh_abbr_test other_second_word"
	test_abbr_expansion="zsh abbr test"
	test_abbr_expansion_2="zsh abbr test 2"

	# Source dependencies
	. $abbr_dir/zsh-abbr.zsh
	. $ztr_path

	# Clear zsh-test-runner summary
	ztr clear-summary

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

	# Reset
	ABBR_REGULAR_ABBREVIATION_PREFIXES=( $abbr_prefixes_saved )
	ABBR_QUIET=$abbr_quiet_saved
	ABBR_TMPDIR=$abbr_tmpdir_saved
	ABBR_USER_ABBREVIATIONS_FILE=$abbr_user_abbreviations_file_saved
	if $(command -v _abbr_load_user_abbreviations); then
		_abbr_load_user_abbreviations
	fi

	# Print test suite results
	echo
	ztr summary
}

main $@
