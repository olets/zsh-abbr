# ROADMAP

Key:

- [x] checked is completed
- [ ] unchecked is to-do

---

## ASAP

- [ ] Identify someone who contributors can contact if olets violates the code of conduct (note: not looking for volunteers)
- [ ] Update code of conduct with their information

## 3.1.0

Look like zsh's `alias` not fish's `abbr`

- [ ] same flags as zsh's `alias`:
	- [x] `-L` list in the form of commands
	- [ ] `-g` list/define global aliases
	- [ ] support `-L -g` and maybe `-L -r`
	- [ ] maybe? `-r` list/define regular aliases
	- [ ] don't do this one: `-m` list aliases that match a pattern
	- [ ] don't do this one: `-s` list/define suffix aliases


## 3.x

- [ ] stronger tests?

Github

- [ ] move contribution documentation to a CONTRIBUTING.md

Chrome

- [ ] Completion
- [ ] highlighting

More idiomatic zsh

- [ ] don't use quotation marks when not needed
- [ ] rework variable values to support using (( ${+var} )) instead of [[ -n "$var" ]]
- [ ] no `if [[ $var == true ]]` where just  `if $var` would work
- [ ] any other places to tighten up boolean checks
