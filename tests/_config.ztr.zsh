#!/usr/bin/env zsh

main() {
  emulate -LR zsh

  ztr test '[[ $ABBR_EXPANSION_CURSOR_MARKER == $ABBR_LINE_CURSOR_MARKER ]]' \
    "Expansion cursor marker defaults to line cursor marker value"
}

main
