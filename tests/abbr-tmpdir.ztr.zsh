#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  abbr $test_abbr_abbreviation=$test_abbr_expansion
  abbr rename $test_abbr_abbreviation $test_abbr_abbreviation_2
  ztr test '[[ $_abbr_tmpdir != $test_tmpdir ]] \
      && [[ ${_abbr_tmpdir%/} == $test_tmpdir ]]' \
    "Tmpdir does not have to end in a slash"

  ztr skip '@TODO' 'Distinct tmpdirs for privileged and unprivileged users'
}

main
