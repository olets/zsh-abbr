#!/usr/bin/env zsh

main() {
	abbr import-git-aliases --file $test_dir/test-gitconfig

	ztr test '[[ $(abbr expand test-subcommand) == "git status" ]]' \
		"Can import regular user single-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand

	ztr test '[[ $(abbr expand test-subcommand-multiword) == "git checkout main" ]]' \
		"Can import regular user multi-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand-multi-word

	ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS["test-command"]} ))' \
		"Cannot import command Git aliases"

	ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS["test-function"]} ))' \
		"Cannot import single-line function Git aliases"

	ztr test '(( ! ${+ABBR_REGULAR_USER_ABBREVIATIONS["test-function-multiline"]} ))' \
		"Cannot import multi-line function Git aliases"

	abbr import-git-aliases -g --file $test_dir/test-gitconfig

	ztr test '(( ${+ABBR_GLOBAL_USER_ABBREVIATIONS["test-subcommand"]} ))' \
		"Can import global single-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand
	abbr erase test-subcommand-multi-word

	abbr import-git-aliases -S --file $test_dir/test-gitconfig

	ztr test '(( ${+ABBR_REGULAR_SESSION_ABBREVIATIONS["test-subcommand"]} ))' \
		"Can import regular session single-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand
	abbr erase test-subcommand-multi-word

	abbr import-git-aliases -S -g --file $test_dir/test-gitconfig

	ztr test '(( ${+ABBR_GLOBAL_SESSION_ABBREVIATIONS["test-subcommand"]} ))' \
		"Can import global session single-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand
	abbr erase test-subcommand-multi-word

	abbr import-git-aliases --file $test_dir/test-gitconfig --prefix "git "

	ztr test '[[ $(abbr expand "git test-subcommand") == "git status" ]]' \
		"Can import prefixed regular user single-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand

	ztr test '[[ $(abbr expand "git test-subcommand-multiword") == "git checkout main" ]]' \
		"Can import prefixed regular user multi-word subcommand Git aliases" \
		"Dependencies: erase, expand"
	abbr erase test-subcommand-multiword

	abbr git $test_abbr_abbreviation=$test_abbr_expansion
	ztr test '[[ $(abbr expand "git $test_abbr_abbreviation") == "git $test_abbr_expansion" ]]' \
		"git adds a regular user abbreviation, prefixing the expansion with 'git '" \
		"Dependencies: erase, expand"
	ztr test '[[ $(abbr expand $test_abbr_abbreviation) == "git $test_abbr_expansion" ]]' \
		"git adds a regular user abbreviation, prefixing the abbreviation with 'g' and prefixing the expansion with 'git '" \
		"Dependencies: erase, expand"
	abbr erase $test_abbr_abbreviation
	abbr erase -g "git $test_abbr_abbreviation"
}

main
