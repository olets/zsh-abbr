# ROADMAP

Key:

- [x] checked is completed
- [ ] unchecked is to-do

---

## ASAP

- [ ] Identify someone who contributors can contact if olets violates the code of conduct (note: not looking for volunteers)
- [ ] Update code of conduct with their information

## 3.x

- [ ] stronger tests?
- [ ] log message about what change was made
  - [ ] include --quiet option
- [ ] erase should not require correct scope and type flags.
  - If only one abbreviation match found, delete it regardless of flags
  - If multiple matches found, either
    - list them and hint what flags to use
    - or provide an interactive list (numbered? or a native zsh menu selection?)

Chrome

- [ ] Completion
- [ ] highlighting

More idiomatic zsh

- [x] don't use quotation marks when not needed
- [x] rework variable values to support using (( ${+var} )) instead of [[ -n "$var" ]]
- [x] no `if [[ $var == true ]]` where just  `if $var` would work
- [x] any other places to tighten up boolean checks
- [ ] maybe use zparseopts?
- [ ] split abbr into its own file, and autoload it
