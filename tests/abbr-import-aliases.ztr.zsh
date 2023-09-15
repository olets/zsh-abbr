#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	{
		ZTR_TEARDOWN_FN() {
			emulate -LR zsh
			
			local ztr_teardown_args
			ztr_teardown_args="$1"

			for k in ${(k)$(abbr list-abbreviations)}; do
				abbr erase $k
			done
			
			if [[ -n $ztr_teardown_args ]]; then
				unalias $ztr_teardown_args
			fi

			unset ZTR_TEARDOWN_ARGS
		}

		abbreviation=zsh_abbr_test_alias
		ZTR_TEARDOWN_ARGS=$abbreviation
		expansion=abc
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import aliases" \
			"Dependencies: erase"

		# Multiword

		abbreviation=zsh_abbr_test_alias
		ZTR_TEARDOWN_ARGS=$abbreviation
		expansion="a b"
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a multi-word alias" \
			"Dependencies: erase"

		# Quotes

		abbreviation=zsh_abbr_test_alias
		ZTR_TEARDOWN_ARGS=$abbreviation
		expansion="a \"b\""
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a double-quoted alias with escaped double quotation marks" \
			"Dependencies: erase"

		abbreviation=zsh_abbr_test_alias
		ZTR_TEARDOWN_ARGS=$abbreviation
		expansion='a "b"'
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a single-quoted alias with double quotation marks" \
			"Dependencies: erase"

		abbreviation=zsh_abbr_test_alias
		ZTR_TEARDOWN_ARGS=$abbreviation
		expansion="a 'b'"
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a double-quoted alias with single quotation marks" \
			"Dependencies: erase"
	} always {
		unfunction -m ZTR_TEARDOWN_FN
	}
}

main
