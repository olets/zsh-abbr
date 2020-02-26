# [v2.1.3](https://github.com/olets/zsh-abbr/compare/v2.1.2...v2.1.3) (2020-02-26)

### Features

* **expansion:** refresh and style autosuggestions after space ([73fc250](https://github.com/olets/zsh-abbr/commit/73fc2505042b4142c14ca20e958d4043f1cd7572))



# [v2.1.2](https://github.com/olets/zsh-abbr/compare/v2.1.1...v2.1.2) (2020-02-24)

### Bug Fixes

* **expansion:** only clear autosuggestions if they are supported [[#6](https://github.com/olets/zsh-abbr/issues/6)] ([21e35b6](https://github.com/olets/zsh-abbr/commit/21e35b66c49b77e7ea72a909ebd60f06b99350b3))

### Features

* **expansion:** highlighting call is not necessary... ([5d1fde0](https://github.com/olets/zsh-abbr/commit/5d1fde0287337d8a5502dae249a309d58a0e00d9))

# [v2.1.1](https://github.com/olets/zsh-abbr/compare/v2.1.0...v2.1.1) (2020-02-22)

### Bug Fixes

* **scratch file:** Linux compatibility (#3 by @ifreund) ([0e647cd](https://github.com/olets/zsh-abbr/commit/0e647cdf2d07c55b14fb98a6b3a39911c9bdb49d))

### Features

* **code of conduct:** add Contributor Covenant ([87333c5](https://github.com/olets/zsh-abbr/commit/87333c55d1246ea8075d4980cee8fb4ffbb48d11))
* **contributing:** add guidelines ([33b5fcd](https://github.com/olets/zsh-abbr/commit/33b5fcd07c137fae1a2608aa2d980cbc8f185b22))


# [v2.1.0](https://github.com/olets/zsh-abbr/compare/v2.0.0...v2.1.0) (2020-02-03)

Under the hood polish; cut down on what is made available to the session; and

### Noteworthy changes

* **aliases:** flag changed to --output-aliases (shorthand -o) from --create-aliases (-c) ([6b922c2](https://github.com/olets/zsh-abbr/commit/6b922c209700060253c42385e9c01795fd72c406))
* **clear globals:** flag changed to --clear-globals (shorthand -c) from --erase-all-globals (-E) ([bf90f87](https://github.com/olets/zsh-abbr/commit/bf90f878287fec6bcb397f9a33713d5ac262c9f1))
* **storage:** universals file is a list of 'abbr -a' commands ([2e191d1](https://github.com/olets/zsh-abbr/commit/2e191d15288b2e43dbaab63bde4886a6dbb43ac7))

### Bug Fixes

* **scope:** only a single scope flag is allowed ([7114a1b](https://github.com/olets/zsh-abbr/commit/7114a1b9798312db156a4c9c47f478b1776e5421))
* **scope:** no internal variables or functions bleed ([4358c2b](https://github.com/olets/zsh-abbr/commit/4358c2b417036ac69ec3bb98697491bbbc09d4c0))

### Features

* **add:** support explicit end of options with -- ([1085a29](https://github.com/olets/zsh-abbr/commit/1085a296edba45bc9435f697de19f552138fa113))
* **options:** no error on hyphen ([a25c7da](https://github.com/olets/zsh-abbr/commit/a25c7daee656cdcc86acc1edbb452ce3bea90d72))
* **rename:** suggest changing scope if abbreviation exists in the other scope but not in the specified one ([0473fb7](https://github.com/olets/zsh-abbr/commit/0473fb730b4d47ef023bf19e1dadf16ef327346a))
* **word:** delimit by '&&', '|', ';', and whitespace ([44b3740](https://github.com/olets/zsh-abbr/commit/44b37405d70ea458a92c62e679a4f788c5fcd622))
* **zinit:** verified installation documentation ([7890320](https://github.com/olets/zsh-abbr/commit/7890320a540153cfcfdc0f7ddc556cba897e7773))


# [v2.0.0](https://github.com/olets/zsh-abbr/compare/v1.2.0...v2.0.0) (2020-01-19)


### Breaking changes

* **universals:** change variable name ([7ee831b](https://github.com/olets/zsh-abbr/commit/7ee831bbf4ef3629e75bf034560122609ed2b602))


### Bug Fixes

* **expansion widget:** abbreviations can end in n or t ([16feffe](https://github.com/olets/zsh-abbr/commit/16feffe826ba5b90b20bc8717a38422b5e63f4c2))


### Features

* **erase-all-globals:** new option ([f7b1bee](https://github.com/olets/zsh-abbr/commit/f7b1beeb8cd9d1e9ac675360fe9f8cd86b6edb71))
* **version:** new option ([206f521](https://github.com/olets/zsh-abbr/commit/206f521b7562ca4b91180d889a690a36c0bb2e26))
* **universals:** change default path ([c7ba374](https://github.com/olets/zsh-abbr/commit/c7ba3745e8b51dd1e70cb61031182d0334e0c811))


# [v1.2.0](https://github.com/olets/zsh-abbr/compare/v1.1.0...v1.2.0) (2020-01-12)


### Bug Fixes

* **erase:** universal abbreviations can be erased ([1d67c8c](https://github.com/olets/zsh-abbr/commit/1d67c8c863449d6ad0b8328b091ce369adffcadd))
* **expansion:** when expanding with spacebar, append a space ([e5b4696](https://github.com/olets/zsh-abbr/commit/e5b469639610516b974518243f2095156f31867b))
* **git-populate:** synax error ([e78eb2b](https://github.com/olets/zsh-abbr/commit/e78eb2b1c87cced3a001033c94c4ca4039eb2a93))
* **rename:** correct syntax for removing an abbreviation ([f99834a](https://github.com/olets/zsh-abbr/commit/f99834a0b6dda311ce0e1b5ae56839f0f1ef0a24))
* **synching:** correct paths ([6cc7e0c](https://github.com/olets/zsh-abbr/commit/6cc7e0c33e968b15cfbbbaea89a6a36b5d1f0f43), [aa80f5d](https://github.com/olets/zsh-abbr/commit/aa80f5d86e820a150eda5de420a219fa5954db11))


### Features

* **arguments:** support long options ([9386436](https://github.com/olets/zsh-abbr/commit/9386436a4ee0e8a1529ef45b4973f504850dd4c6))
* **bindings:** add variable for opting out of defaults ([7edd67e](https://github.com/olets/zsh-abbr/commit/7edd67ea710dcfc93fd9c2e816249b9ecfb9055d))
* **create-aliases:** new option ([35ace71](https://github.com/olets/zsh-abbr/commit/35ace71d5d2baa1f65dc4e2e3f49e922f531da17))
* **expansion:** plays nice with zsh-autosuggestions ([e19a0a1](https://github.com/olets/zsh-abbr/commit/e19a0a10a85aacc69891e63d09a1b82602b3e8df))
* **expansion:** support expand-on-enter (has suggestions bug) ([f8356be](https://github.com/olets/zsh-abbr/commit/f8356be04bc9fdff44549b9ec54f7cf20a94fb1b))
* **expansion:** support zsh-syntax-highlighting ([cff6dc0](https://github.com/olets/zsh-abbr/commit/cff6dc009cf2d4688509360f4914366420169924))
* **rename:** error if old doesn't exist or new already exists ([a030670](https://github.com/olets/zsh-abbr/commit/a0306700c79b486cda6780dbfbcd33b4799bf223))



# [v1.1.0](https://github.com/olets/zsh-abbr/compare/v1.0.0...v1.1.0) (2019-01-26)

Bug fixes and


### Features

* **git-populate:** new option ([28ea419](https://github.com/olets/zsh-abbr/commit/28ea4198ba28a8f764e4685d233cc9b10268623f))
* **populate:** option to create abbreviations from aliases ([fbbf9a6](https://github.com/olets/zsh-abbr/commit/fbbf9a6753bf3aa31625d006c4992a7f0cb21386))



# [v1.0.0](https://github.com/olets/zsh-abbr/compare/initial...v1.0.0) (2019-01-26)

Feature parity with fish's abbr
