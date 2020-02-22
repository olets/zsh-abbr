# ROADMAP

- [x] checked is completed
- [ ] unchecked is to-do

## 3.0.0

Zsh `abbr`, not the zsh port of fish `abbr`

1. Like zsh `alias`, distinguish between command (aka "regular") abbreviations and global abbreviations
1. Like zsh `alias`, define abbreviations with `x="yz"` rather than `x yz` like fish `abbr`

### Breaking changes

- [x] instead of fish `abbr`'s global/universal terminology use less jargony session/user
	- [x] update scope flags
	- [x] adjust other flags as necessary to not collide
	- [x] update variable names
	- [x] update file names
- [x] abbreviations are by default command abbreviations not global abbreviations

### Features

- [x] support command/global abbreviations
  - [x] in `--add`
  - [x] in `--erase`
  - [x] in `--rename`
- [ ] in user file, no `-a -U --`
- [ ] `add` syntax is `abbreviation='word'`/`abbreviation="word"`
	- [ ] confirm that quotes can be included by escaping them (`abbreviation="the \"full\" \'word\'"`)
- [ ] support importing from fish / migrating from <3.x

### Other

- [x] tighten up initialization

## 3.1.0

Look like zsh's `alias` not fish's `abbr`

- [ ] same flags as zsh's `alias`:
	- [ ] `-L` list in the form of commands
	- [ ] `-g` list/define global aliases
	- [ ] support `-L -g` and maybe `-L -r`
	- [ ] maybe? `-r` list/define regular aliases
	- [ ] don't do this one: `-m` list aliases that match a pattern
	- [ ] don't do this one: `-s` list/define suffix aliases


## 3.x

Chrome

- [ ] Completion
- [ ] highlighting

More idiomatic zsh

- [ ] don't use quotation marks when not needed
- [ ] use (( ${+var} )) instead of [[ -n "$var" ]]
- [ ] no `if [[ $var == true ]]` where just  `if $var` would work
- [ ] any other places to tighten up boolean checks
