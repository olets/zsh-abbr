#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  ztr test '(( $+functions[_abbr] ))' \
    "Completions function is available"
}

main
