#!/usr/bin/env zsh

main() {
	emulate -LR zsh

	ztr skip '@TODO' 'When ABBR_PUSH_HISTORY == 1, abbreviations are included in history'
}

main
