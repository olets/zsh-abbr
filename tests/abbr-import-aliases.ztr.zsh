#!/usr/bin/env zsh

main() {
	{
		_reset() {
			local abbreviation
			abbreviation="$1"

			for k in ${(k)$(abbr list-abbreviations)}; do
				abbr erase $k
			done
			
			unalias $abbreviation
		}

		abbreviation=zsh_abbr_test_alias
		expansion=abc
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import aliases" \
			"Dependencies: erase"
		_reset $abbreviation
		
		# Multiword

		abbreviation=zsh_abbr_test_alias
		expansion="a b"
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a multi-word alias" \
			"Dependencies: erase"
		_reset $abbreviation
		
		# Quotes

		abbreviation=zsh_abbr_test_alias
		expansion="a \"b\""
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a double-quoted alias with escaped double quotation marks" \
			"Dependencies: erase"
		_reset $abbreviation

		abbreviation=zsh_abbr_test_alias
		expansion='a "b"'
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a single-quoted alias with double quotation marks" \
			"Dependencies: erase"
		_reset $abbreviation
		

		abbreviation=zsh_abbr_test_alias
		expansion="a 'b'"
		alias $abbreviation=$expansion
		abbr import-aliases
		ztr test '[[ ${ABBR_REGULAR_USER_ABBREVIATIONS[${(qqq)abbreviation}]} == ${(qqq)expansion} ]]' \
			"Can import a double-quoted alias with single quotation marks" \
			"Dependencies: erase"
		_reset $abbreviation
	} always {
		unfunction -m reset
	}
}

main