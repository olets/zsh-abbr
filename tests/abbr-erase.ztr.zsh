#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	{
		ZTR_TEARDOWN_FN() {
			emulate -LR zsh

			[[ $ABBR_USER_ABBREVIATIONS_FILE != $ABBR_USER_ABBREVIATIONS_FILE_SAVED ]] && \
				echo '' > $ABBR_USER_ABBREVIATIONS_FILE
		}

		# More contexts - for example --global / -g, --regular / -r, --session / -S, --user / -U, are tested in abbr-add.ztr.zsh

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		abbr erase $test_abbr_abbreviation
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation" \
			"Dependencies: add, erase"

		abbr add ${test_abbr_abbreviation}^=$test_abbr_expansion
		abbr erase ${test_abbr_abbreviation}^
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation ending in a caret" \
			"Dependencies: add, erase."

		abbr add ^$test_abbr_abbreviation=$test_abbr_expansion
		abbr erase ^$test_abbr_abbreviation
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation starting with a caret" \
			"Dependencies: add, erase."

		abbr add ${test_abbr_abbreviation}^${test_abbr_abbreviation}=$test_abbr_expansion
		abbr erase ${test_abbr_abbreviation}^${test_abbr_abbreviation}
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation with an embedded caret" \
			"Dependencies: add, erase."

		abbr add "${test_abbr_abbreviation}#"=$test_abbr_expansion
		abbr erase "${test_abbr_abbreviation}#"
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation ending in a hash" \
			"Dependencies: add, erase."

		abbr add "#$test_abbr_abbreviation"=$test_abbr_expansion
		abbr erase "#$test_abbr_abbreviation"
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation starting with a hash" \
			"Dependencies: add, erase."

		abbr add "${test_abbr_abbreviation}#${test_abbr_abbreviation}"=$test_abbr_expansion
		abbr erase "${test_abbr_abbreviation}#${test_abbr_abbreviation}"
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase an abbreviation with an embedded hash" \
			"Dependencies: add, erase."

		# TODO
		# See
		# - https://github.com/olets/zsh-abbr/issues/84
		# - https://github.com/olets/zsh-abbr/issues/118
		abbr add ${test_abbr_abbreviation}\!=$test_abbr_expansion
		abbr erase $test_abbr_abbreviation'!'
		ztr skip '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"@TODO. Can erase an abbreviation ending in an escaped exclamation point" \
			"Dependencies: add, erase. GitHub issues: #84, #118"

		# See
		# - https://github.com/olets/zsh-abbr/issues/84
		# - https://github.com/olets/zsh-abbr/issues/118
		abbr add \!$test_abbr_abbreviation=$test_abbr_expansion
		abbr erase \!$test_abbr_abbreviation
		ztr skip '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"@TODO. Can erase an abbreviation starting with an escaped exclamation point" \
			"Dependencies: add, erase. GitHub issues: #84, #118"

		# See
		# - https://github.com/olets/zsh-abbr/issues/84
		# - https://github.com/olets/zsh-abbr/issues/118
		abbr add '!'$test_abbr_abbreviation=$test_abbr_expansion
		abbr erase '!'$test_abbr_abbreviation
		ztr skip '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"@TODO. Can erase an abbreviation starting with a single-quoted exclamation point" \
			"Dependencies: add, erase. GitHub issues: #84, #118"

		# See
		# - https://github.com/olets/zsh-abbr/issues/118
		local single_quoted_abbreviation="'"
		single_quoted_abbreviation+=$test_abbr_abbreviation
		single_quoted_abbreviation+="'"
		abbr add $single_quoted_abbreviation=$test_abbr_expansion
		abbr erase $single_quoted_abbreviation
		ztr skip '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"@TODO. Can erase an abbreviation with single quotation marks" \
			"Dependencies: add, erase. GitHub issues: #118"

		# See
		# - https://github.com/olets/zsh-abbr/issues/118
		local double_quoted_abbreviation='"'
		double_quoted_abbreviation+=$test_abbr_abbreviation
		double_quoted_abbreviation+='"'
		abbr add $double_quoted_abbreviation=$test_abbr_expansion
		abbr erase $double_quoted_abbreviation
		ztr skip '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"@TODO. Can erase an abbreviation starting with double quotation marks" \
			"Dependencies: add, erase. GitHub issues: #118"

		# Manual

		abbr add $test_abbr_abbreviation=$test_abbr_expansion
		echo '' > $ABBR_USER_ABBREVIATIONS_FILE
		ztr test '[[ -z $(abbr expand $test_abbr_abbreviation) ]]' \
			"Can delete a user abbreviation from outside abbr without unexpected retention"


		# Multiword

		abbr add $test_abbr_abbreviation_multiword=$test_abbr_expansion
		abbr erase $test_abbr_abbreviation_multiword
		ztr test '(( ${#ABBR_REGULAR_USER_ABBREVIATIONS} == 0 ))' \
			"Can erase a multi-word abbreviation" \
			"Dependencies: add, erase"
	} always {
		unfunction -m ZTR_TEARDOWN_FN
	}
}

main
