#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	{
		ZTR_TEARDOWN_FN() {
			emulate -LR zsh

			abbr erase $test_abbr_abbreviation
		}

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add an abbreviation with the add subcommand" \
			"Dependencies: erase, expand"

		abbr -S add $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a regular session abbreviation with the add subcommand, with the flag before the command" \
			"Dependencies: erase, expand"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion -S
		ztr test '[[ $(abbr -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a regular session abbreviation with the add subcommand, with the flag after the command args" \
			"Dependencies: erase, expand"

		abbr add -S $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a regular session abbreviation with the add subcommand, with the flag between the command and its args" \
			"Dependencies: erase, expand"

		# Manual

		echo "abbr \"$test_abbr_abbreviation\"=\"$test_abbr_expansion\"" > $ABBR_USER_ABBREVIATIONS_FILE
		abbr load
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a user abbreviation from outside abbr without data loss" \
			"Dependencies: erase, expand"

		# Implicit

		abbr $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add an abbreviation without the add subcommand" \
			"Dependencies: erase, expand"

		abbr $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can add a multi-word abbreviation without the add subcommand" \
			"Dependencies: erase, expand"
		abbr erase $test_abbr_abbreviation_multiword

		# Global

		abbr add -g $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr -g expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a global abbreviation with the add subcommand" \
			"Dependencies: erase, expand"

		abbr add -S -g $test_abbr_abbreviation=$test_abbr_expansion
		ztr test '[[ $(abbr -g -S expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Can add a global session abbreviation with the add subcommand" \
			"Dependencies: erase, expand"

		# Multiword

		abbr add $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can add a multi-word abbreviation with the add subcommand" \
			"Dependencies: erase, expand"
		abbr erase $test_abbr_abbreviation_multiword

		abbr add -S $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr -S expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can add a multi-word regular session abbreviation with the add subcommand" \
			"Dependencies: erase, expand"
		abbr erase $test_abbr_abbreviation_multiword

		# Multiword global

		abbr add -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr -g expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can add a multi-word global abbreviation with the add subcommand" \
			"Dependencies: erase, expand"
		abbr erase $test_abbr_abbreviation_multiword

		abbr add -S -g $test_abbr_abbreviation_multiword=$test_abbr_expansion
		ztr test '[[ $(abbr -g -S expand $test_abbr_abbreviation_multiword) == $test_abbr_expansion ]]' \
			"Can add a multi-word global session abbreviation with the add subcommand" \
			"Dependencies: erase, expand"
		abbr erase $test_abbr_abbreviation_multiword

		# Quotes

		expansion='b'cd
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Bare single quotes at the start of the expansion are swallowed" \
			"Dependencies: erase, expand"

		expansion=b'c'd
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Bare single quotes in the middle of the expansion are swallowed" \
			"Dependencies: erase, expand"

		expansion='b"c"d'
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Single-quoted double quotes in the expansion are preserved" \
			"Dependencies: erase, expand"

		expansion="b"cd
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Bare double quotes at the start of the expansion are swallowed" \
			"Dependencies: erase, expand"

		expansion=b"c"d
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Bare double quotes in the middle of the expansion are swallowed" \
			"Dependencies: erase, expand"

		expansion="b'c'd"
		abbr $test_abbr_abbreviation=$expansion
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $expansion ]]' \
			"Double-quoted single quotes in the expansion are preserved" \
			"Dependencies: erase, expand"

		# Force

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		abbr add $test_abbr_abbreviation=$test_abbr_expansion_2
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion ]]' \
			"Cannot change an abbreviation's expansion" \
			"Dependencies: erase, expand"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		abbr add --force $test_abbr_abbreviation=$test_abbr_expansion_2
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion_2 ]]' \
			"Cannot change an abbreviation's expansion with --force" \
			"Dependencies: erase, expand"

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		abbr add -f $test_abbr_abbreviation=$test_abbr_expansion_2
		ztr test '[[ $(abbr expand $test_abbr_abbreviation) == $test_abbr_expansion_2 ]]' \
			"Cannot change an abbreviation's expansion with -f" \
			"Dependencies: erase, expand"
	} always {
		unfunction -m ZTR_TEARDOWN_FN
	}
}

main
