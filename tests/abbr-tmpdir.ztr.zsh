#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	abbr $test_abbr_abbreviation=$test_abbr_expansion
	abbr rename $test_abbr_abbreviation $test_abbr_abbreviation_2
	ztr test '[[ $_abbr_tmpdir != $ABBR_TEST_TMPDIR ]] \
			&& [[ ${_abbr_tmpdir%/} == $ABBR_TEST_TMPDIR ]]' \
		"Tmpdir does not have to end in a slash"

	ztr skip '@TODO' 'Distinct tmpdirs for privileged and unprivileged users'
}

main
