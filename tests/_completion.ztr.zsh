#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  ztr test '(( $+functions[_abbr] ))' \
    "Sourcing the plugin does not remove the shipped _abbr completion function (issue #210)"
}

main
