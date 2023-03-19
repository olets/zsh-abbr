# [5.0.1](https://github.com/olets/zsh-abbr/compare/v5.0.0...v5.0.1) (2023-03-19)


### Bug Fixes

* **expand:** quotation marks are preserved ([2cb3613](https://github.com/olets/zsh-abbr/commit/2cb3613d0bb584507b6fb8744c7b3ce61fba5abc))
* Corrected false-negative tests


### Features

* **expand:** support multi-word string ([70663b1](https://github.com/olets/zsh-abbr/commit/70663b1955427e988671b6e2f34e296c766a673f))
* Test suite runs multiple file, logs file names



# [5.0.0](https://github.com/olets/zsh-abbr/compare/v4.9.3...v5.0.0) (2023-02-23)

Has breaking changes. See the [migration guide](https://zsh-abbr.olets.dev/migrating-between-versions).

- 🆕 Support for [multi-word abbreviations](https://zsh-abbr.olets.dev/essential-commands)
- 🆕 New documentation site
- 🆕 [`abbr git`](https://v5.zsh-abbr.olets.dev/commands.html#git) command!
- 📄 Default `ABBR_USER_ABBREVIATIONS_FILE` is now `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations` (but if you have a file in the legacy path `${XDG_CONFIG_HOME:-$HOME/.config}/zsh/abbreviations`, that will be used instead)
- ⚠️ zsh-syntax-highlighting users have to update their snippets
- ⚠️ All features deprecated in the latest v4.x are dropped
- License's ethics requirements are now Hippocratic License v3 (was HL v2.1)

For details see v5.0.0.beta-x release notes below.


# [5.0.0.beta-8](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-6...v5.0.0.beta-8) (2023-02-20)

### Features

From 4.9.3:

* **actions:** publishing releases automatically bumps homebrew ([a87679d](https://github.com/olets/zsh-abbr/commit/a87679d3097e4c9f1c536f94a700b88900387c33))
* **bench:** add configs ([4277de1](https://github.com/olets/zsh-abbr/commit/4277de1dec3726527c50c59376fc2fa4fa822f9d))



# [5.0.0.beta-7](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-6...v5.0.0.beta-7) (2023-02-10)


### Bug Fixes

From v4.9.2:

* **binaries:** delete file missed in 347f2fa [[#73](https://github.com/olets/zsh-abbr/issues/73)] ([627490b](https://github.com/olets/zsh-abbr/commit/627490b169b3011a69491df5b536c264f7278900))

From v4.9.1:

* **man:** correct version and release date ([a6ae1c9](https://github.com/olets/zsh-abbr/commit/a6ae1c972356f092602276a0d369f34f56b5a6cc))


# [5.0.0.beta-6](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-5...v5.0.0.beta-6) (2023-01-05)

### Features

* **user file:** default is now <dir>/zsh-abbr/user-abbreviations ([aa3e42f](https://github.com/olets/zsh-abbr/commit/aa3e42f7f2c62559c406f97c26a1722072e4ca01))

# [5.0.0.beta-5](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-4...v5.0.0.beta-5) (2022-12-23)

### Features

From v4.9:

* **profile:** new command ([4ba4bc8](https://github.com/olets/zsh-abbr/commit/4ba4bc8831d1b3bbd228570a212160494955cc2f))


# [5.0.0.beta-4](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-3...v5.0.0.beta-4) (2022-12-23)

### Bug Fixes

From v4.8.4:

* **expand and accept:** check for zsh-autosuggestion widget ([8c84b54](https://github.com/olets/zsh-abbr/commit/8c84b54af78b6f541e49ec4279a8bb7506b7c381))


# [5.0.0.beta-3](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-2...v5.0.0.beta-3) (2022-12-16)

### Bug Fixes

From v4.8.3:

* **expand-and-accept:** accepting clears zsh-autosuggestions' suggestions [[#67](https://github.com/olets/zsh-abbr/issues/67)] ([a994077](https://github.com/olets/zsh-abbr/commit/a994077e1614d2aed0e07557b3b6452da956868a))


### Features

From v4.8.3:

* **expand-and-accept:** use zsh-autosuggestions' recommendation for how to clear suggestions ([a994077](https://github.com/olets/zsh-abbr/commit/a994077e1614d2aed0e07557b3b6452da956868a))


# [5.0.0.beta-2](https://github.com/olets/zsh-abbr/compare/v5.0.0.beta-1...v5.0.0.beta-2) (2022-11-19)

### Features

From v4.8.2:

* **binaries:** remove [[#65](https://github.com/olets/zsh-abbr/issues/65)] ([a1a530b](https://github.com/olets/zsh-abbr/commit/a1a530bdae2d3a6a85885c1b890d632265c528b4))


# [5.0.0.beta-1](https://github.com/olets/zsh-abbr/compare/v4.8.0...v5.0.0.beta-1) (2022-11-06)

Notably the first release of multi-word abbreviations and the move of the documentation out of the README and into a dedicated site.

### Features

* **multi-word abbreviations**! Thanks to [@henrebotha](https://github.com/henrebotha) for discussion in [#32](https://github.com/olets/zsh-abbr/issues/32)
  * add ([641d94f](https://github.com/olets/zsh-abbr/commit/641d94f77f11c13faae01b141c9d9801bd795f3a))
  * erase, expand ([218cd8e](https://github.com/olets/zsh-abbr/commit/218cd8e497ade6efd40d3c5bf1c32a9b07b0e717)), ([2a3f111](https://github.com/olets/zsh-abbr/commit/2a3f11193f9ac5f669fa4e3ce7a9e30d677e64d9))
  * import-git-aliases ([c98729b](https://github.com/olets/zsh-abbr/commit/c98729ba691c72a8340138dce382a0c7192c45c9))
  * rename ([5c2308f](https://github.com/olets/zsh-abbr/commit/5c2308f2cc2ac781f054140421d755aac8bd0e51))
* **contributors:** use all-contributors ([32da6fb](https://github.com/olets/zsh-abbr/commit/32da6fb74f7688851e03d52eaa838084ce811b83))
* **erase,add:** remove some possibly unnecessary quoting ([02b84b5](https://github.com/olets/zsh-abbr/commit/02b84b551fba7c4f853d3feddb48637ae9033983))
* **expand:** try all substrings from longest to shortest ([4d8ea0f](https://github.com/olets/zsh-abbr/commit/4d8ea0ffd8acd74e8a4216764bba219c343cc09c))
* **git:** support new subcommand ([364a4b0](https://github.com/olets/zsh-abbr/commit/364a4b006cdc6ab9d558f2c7fbc14e4bc8f850fd)), ([ceeca77](https://github.com/olets/zsh-abbr/commit/ceeca776155201f3115ca5a5c01f24db58716751))
* **import-git-aliases:** create only one type ([9979861](https://github.com/olets/zsh-abbr/commit/997986107e4e8c883b44c660b6d7af957d90777d))
* **license:**
  * Hippocratic License v3 is released. Apply it in place of v2.1 clause ([584be08](https://github.com/olets/zsh-abbr/commit/584be08fa0dee1daf03568e76f45a54946dfb96c))
  * add Sky's Edge-inspired stipulations ([1c4c501](https://github.com/olets/zsh-abbr/commit/1c4c50147ef9e79b37f49a5e901599a1f906330e))
* **widgets:** drop support for deprecated names ([6aedbe9](https://github.com/olets/zsh-abbr/commit/6aedbe94297263a39b1f3b6bbaee7685e7a73787))


# [4.9.5](https://github.com/olets/zsh-abbr/compare/v4.9.3...v4.9.5) (2023-02-24)

Updates in support of v5.0.0's release


# [4.9.4](https://github.com/olets/zsh-abbr/compare/v4.9.3...v4.9.4) (2023-02-21)

Update release date

# [4.9.3](https://github.com/olets/zsh-abbr/compare/v4.9.2...4.9.3) (2023-02-21)


### Features

* **actions:** publishing releases automatically bumps homebrew ([a87679d](https://github.com/olets/zsh-abbr/commit/a87679d3097e4c9f1c536f94a700b88900387c33))
* **bench:** add configs ([4277de1](https://github.com/olets/zsh-abbr/commit/4277de1dec3726527c50c59376fc2fa4fa822f9d))



# [4.9.2](https://github.com/olets/zsh-abbr/compare/v4.9.1...v4.9.2) (2023-02-10)


### Bug Fixes

* **binaries:** delete file missed in 347f2fa [[#73](https://github.com/olets/zsh-abbr/issues/73)] ([627490b](https://github.com/olets/zsh-abbr/commit/627490b169b3011a69491df5b536c264f7278900))



# [4.9](https://github.com/olets/zsh-abbr/compare/v4.8.4...v4.9) (2022-12-28)


### Features

* **profile:** new command ([4ba4bc8](https://github.com/olets/zsh-abbr/commit/4ba4bc8831d1b3bbd228570a212160494955cc2f))



# [4.8.4](https://github.com/olets/zsh-abbr/compare/v4.8.3...v4.8.4) (2022-12-23)


### Bug Fixes

* **expand and accept:** check for zsh-autosuggestion widget ([53a8b06](https://github.com/olets/zsh-abbr/commit/53a8b06a4e210fd9456cd1a83034d153be9589b5))



# [4.8.3](https://github.com/olets/zsh-abbr/compare/v4.8.2...v4.8.3) (2022-12-16)


### Bug Fixes

* **expand-and-accept:** accepting clears zsh-autosuggestions' suggestions [[#67](https://github.com/olets/zsh-abbr/issues/67)] ([752cef8](https://github.com/olets/zsh-abbr/commit/752cef83eed89912ebed68c54d9c07241b8b60e8))


### Features

* **expand-and-accept:** use zsh-autosuggestions' recommendation for how to clear suggestions ([c71302d](https://github.com/olets/zsh-abbr/commit/c71302df14e10c6227367b02901027b77f753711))



# [4.8.2](https://github.com/olets/zsh-abbr/compare/v4.8.1...v4.8.2) (2022-11-19)


### Features

* **binaries:** remove [[#65](https://github.com/olets/zsh-abbr/issues/65)] ([347f2fa](https://github.com/olets/zsh-abbr/commit/347f2fa0c6b0a4069acc56dabd86911f04d777e5))



# [4.8.1](https://github.com/olets/zsh-abbr/compare/v4.8.0...v4.8.1) (2022-11-10)


### Features

* **widgets:** deprecate functions which were not dropped in v4.1.0... ([8a01f32](https://github.com/olets/zsh-abbr/commit/8a01f32514257422a4d50484e22a1ea40386f098))



# [4.8.0](https://github.com/olets/zsh-abbr/compare/v4.7.1...v4.8.0) (2022-09-08)


### Features

* **user abbreviation file:** respect XDG_CONFIG_HOME if defined (unless there's already an abbreviations file in the old default location), with [@qubidt](https://github.com/qubidt) ([5d59cd0](https://github.com/olets/zsh-abbr/commit/5d59cd0a62af1367aa4e6f0f548ee00914031013), [2df61f9](https://github.com/olets/zsh-abbr/commit/2df61f96f142e7ba13ffecbaae1256254608cf25))

# [4.7.1](https://github.com/olets/zsh-abbr/compare/v4.7.0...v4.7.1) (2022-01-03)

Copyright update



# [4.7.0](https://github.com/olets/zsh-abbr/compare/v4.6.0...v4.7.0) (2021-12-30)


### Breaking

* **widgets:** drop support for functions deprecated in 4.1.0 ([4166395](https://github.com/olets/zsh-abbr/commit/4166395f623ab44cfe992afd7d8d4e904f9aa9ea))

### Features

* **init:** no unnecessary NO_COLOR checks ([da5205a](https://github.com/olets/zsh-abbr/commit/da5205ab5b9a5508d0ca818cceb7dc27fc0d83fa))


# [4.6.0](https://github.com/olets/zsh-abbr/compare/v4.5.0...v4.6.0) (2021-09-24)

- `--version` shows the correct version number again.
### Features

* **license:** new license ([cfe5abb](https://github.com/olets/zsh-abbr/commit/cfe5abb2c16fa5ceb4fd6b965b5667c69e375628))


# [4.5.0](https://github.com/olets/zsh-abbr/compare/v4.4.0...v4.5.0) (2021-09-14)


_In this version `abbr -v` gives `zsh-abbr version 4.4.0`_

### Bug Fixes

* **temp files:** account for possibility of garbage cleaning [[#42](https://github.com/olets/zsh-abbr/issues/42)] ([38ffea2](https://github.com/olets/zsh-abbr/commit/38ffea289e31980e52d140868cdb4d0adf475e56))


### Features

* **color:** more reliable respect for NO_COLOR ([4706cf4](https://github.com/olets/zsh-abbr/commit/4706cf4722debb7ca2d9b9cc0b7089c74c89fd4b))



# [4.4.0](https://github.com/olets/zsh-abbr/compare/v4.3.0...v4.4.0) (2021-08-1)


### Features

* **add:** use --quieter to silence 'command expands' logs, idea from [@knu](https://github.com/olets/zsh-abbr/commits?author=knu) in [#38](https://github.com/olets/zsh-abbr/issues/38) ([8c02d9a](https://github.com/olets/zsh-abbr/commit/8c02d9affd1820be9dad9df9f8c3e992d5725b5b))
 

### Bug Fixes

* **help:** show manpage regardless of installation method ([55c4c29](https://github.com/olets/zsh-abbr/commit/55c4c2916f153717269c6ef8a77a14608548ab28))


### Other

The README now includes instructions for importing macOS substitutions, by [@mortenscheel](https://github.com/olets/zsh-abbr/commits?author=mortenscheel) ([99af045](https://github.com/olets/zsh-abbr/commit/99af0455b7b86ff3894a4bcf73380be2d595fa54))


# [4.3.0](https://github.com/olets/zsh-abbr/compare/v4.3.0...v4.3.0) (2021-03-28)


### Features

* **tests:** use zsh-test-runner (ztr) ([da2b0b9](https://github.com/olets/zsh-abbr/commit/da2b0b989b57e0828a766f330ccc0b2df889f8e3))


# [4.2.1](https://github.com/olets/zsh-abbr/compare/v4.2.0...v4.2.1) (2021-02-28)


### Features

* **echo:** always use builtin ([093269a](https://github.com/olets/zsh-abbr/commit/093269a6a687dd28cb4d5c5122809725c8724998))
* **tests:** new harness + support skipping ([b884a9f](https://github.com/olets/zsh-abbr/commit/b884a9f533c6f2ca1bd696ad056e06c6257b0bff))
* **rm:** Make sure "rm" is run as command and not as alias, by [@hojerst](https://github.com/olets/zsh-abbr/commits?author=hojerst) ([d275169](https://github.com/olets/zsh-abbr/commit/d275169fe16be53dcaad93e4ad18d1bb1d11d542))


# [4.2.0](https://github.com/olets/zsh-abbr/compare/v4.1.2...v4.2.0) (2020-12-13)


### Features

* **add:** logs always include type and scope ([70ee858](https://github.com/olets/zsh-abbr/commit/70ee8580402bc7ce766ecfac4f57c22bf0ec8f3d))
* **import-git-aliases:** respect multiline Git aliases ([#30](https://github.com/olets/zsh-abbr/issues/30) / PR [#31](https://github.com/olets/zsh-abbr/issues/31)) by [@henrebotha](https://github.com/olets/zsh-abbr/commits?author=henrebotha) ([5deee28](https://github.com/olets/zsh-abbr/commit/5deee288b1c29441358922f437b9e04c2d99c86d))
* **import-git-aliases:** support specifying config file path ([31fca3f](https://github.com/olets/zsh-abbr/commit/31fca3f21103c2ddcb02b69b6d4c62a3fc7b988c))



# [v4.1.2](https://github.com/olets/zsh-abbr/compare/v4.1.1...v4.1.2) (2020-11-02)


### Bug Fixes

* **expand and accept:** autosuggestions not required [[#28](https://github.com/olets/zsh-abbr/issues/28)] ([7cdc57a](https://github.com/olets/zsh-abbr/commit/7cdc57a58f83b9ec929fdfd955716df97ee58919))


# [v4.1.1](https://github.com/olets/zsh-abbr/compare/v4.1.0...v4.1.1) (2020-10-27)


### Bug Fixes

* **homebrew:** shas match (empty) [[#27](https://github.com/olets/zsh-abbr/issues/27)] ([97b5fc2](https://github.com/olets/zsh-abbr/commit/97b5fc25205614d85b6a53f72b997935afa20d93))



# [v4.1.0](https://github.com/olets/zsh-abbr/compare/v4.0.2...v4.1.0) (2020-10-24)

Friendlier widget names, and syntax highlighting snippets for `zsh-syntax-highlighting`.

### Features

* **deprecations:** reinstate support for warnings + add example forms ([73c4626](https://github.com/olets/zsh-abbr/commit/73c4626c06f6d0d7a50e83f1f32a0d614f84116e))
* **widgets:** rename widgets, deprecate old names, add precmd ([35a2c15](https://github.com/olets/zsh-abbr/commit/35a2c155636dfd4510646fa51d80c1a9d01059c1))
* **precmd:** add precmd logging ([35a2c15](https://github.com/olets/zsh-abbr/commit/35a2c155636dfd4510646fa51d80c1a9d01059c1))



# [v4.0.2](https://github.com/olets/zsh-abbr/compare/v4.0.1...v4.0.2) (2020-09-14)


### Bug Fixes

* **init:** all initialization happens in function [[#22](https://github.com/olets/zsh-abbr/issues/22)] ([8bbaa84](https://github.com/olets/zsh-abbr/commit/8bbaa841254e95b22144243d317f95051be31bf0))


### Features

* **abbr_job_pop:** use command 'rm' ([15e383b](https://github.com/olets/zsh-abbr/commit/15e383b8fff34fe14cf5191fe420f86d16058bd7))



# [v4.0.1](https://github.com/olets/zsh-abbr/compare/v4.0.0...v4.0.1) (2020-08-23)

`abbr e -g <existing global abbreviation>` finished with the log message "regular user abbreviation". No longer! And polishes up tests.


### Bug Fixes

* **fix,refactor(logs):** correct type and scope ([a5a4171](https://github.com/olets/zsh-abbr/commit/a5a4171d448f3ee2cfe83d8c1dc8fa2063bb3e2c))



# [v4.0.0](https://github.com/olets/zsh-abbr/compare/v3.3.4...v4.0.0) (2020-07-26)


### Bug Fixes

* **dry run:** message appended to log ([4dd118f](https://github.com/olets/zsh-abbr/commit/4dd118f5d5aadf67fd45a55d7f149c2203a97efa))


### Features

* **abbreviations arrays:** prefix var names with ABBR_ ([fef023b](https://github.com/olets/zsh-abbr/commit/fef023b9a626d27a417ae272ece371aef4eae396))
* **color:** do not load module if NO_COLOR is set ([25264ae](https://github.com/olets/zsh-abbr/commit/25264ae99b5d8254aac08887109d7553358bb31f))
* **export aliases:** drop support for output path arg ([35b9274](https://github.com/olets/zsh-abbr/commit/35b92744ab244e03d17751d9b330884f5e8de8c1))
* **list, list-abbreviations:** swap; list is default ([39fd84d](https://github.com/olets/zsh-abbr/commit/39fd84d3863911242141993edadb10a07e446281))
* **quiet:** does not silence dry run message ([0a4d5b6](https://github.com/olets/zsh-abbr/commit/0a4d5b66df109c00279c835b48c8616aebd2902b))
* **subcommands:** drop support and messages for deprecateds ([f1b0ce7](https://github.com/olets/zsh-abbr/commit/f1b0ce705d1323b6ea62a714cb319408fa694a07))
* **temp files:** new global var ABBR_TMPDIR ([2fa0e88](https://github.com/olets/zsh-abbr/commit/2fa0e88404a721e589fbc89d66719f490188e718))
* **temp files:** no longer clean up v<3.2 temp files ([f15ab53](https://github.com/olets/zsh-abbr/commit/f15ab53a6a88442210f49d08b6a6539dd7babb1b))
* **variables, functions:** drop support for 'zsh_' prefix... ([7557ef4](https://github.com/olets/zsh-abbr/commit/7557ef44b2eb9fae951241146b17305b2319b4e5))



# [v.3.3.4](https://github.com/olets/zsh-abbr/compare/v3.3.3...v) (2020-07-26)

Deprecates `ABBR_USER_PATH` in favor of `ABBR_USER_ABBREVIATIONS_FILE`.

# [v3.3.3](https://github.com/olets/zsh-abbr/compare/v3.3.2...v3.3.3) (2020-06-14)

Fix a session abbreviations bug, support NO_COLOR, and polish deprecation warnings.

### Bug Fixes

* **session abbreviations:** do not unintentionally clear ([113ffc6](https://github.com/olets/zsh-abbr/commit/113ffc6c10b53bd2bbdea5b8838ba89d598434f3))


### Features

* **config:** deprecate ABBR_DEFAULT_BINDINGS 'true'/'false' (use 0/1) ([5f25f1c](https://github.com/olets/zsh-abbr/commit/5f25f1cb8b8232beee15d77ae24af44895a8dcc5))
* **debugging:** deprecate ZSH_-prefixed var name ([2b5de18](https://github.com/olets/zsh-abbr/commit/2b5de186411a32dc7e1414669133bb2411eb59ca))
* **deprecation:** post-init warnings for non-init config vars ([69d73b8](https://github.com/olets/zsh-abbr/commit/69d73b827d4cab1a10f6941a60c6b6cf6f8b4ffe))
* **deprecation message:** use warning color ([fd53852](https://github.com/olets/zsh-abbr/commit/fd5385294cc4c32627cb90f60cc0748a160a69b8))
* **output:** support NO_COLOR (see https://no-color.org/) ([54f16db](https://github.com/olets/zsh-abbr/commit/54f16dbd2be2e3913a8013822d9b1dd30664706a))



# [v3.3.2](https://github.com/olets/zsh-abbr/compare/v3.3.1...v3.3.2) (2020-06-06)

Save some keystrokes! `--` and `-` prefixes in actions are deprecated. Just say `add`, `clear-session`, `erase`, `expand`, `export-aliases`, `help`, `import-aliases`, `import-fish`, `import-git-aliases`, `list`, `list-abbreviations`, `list-commands`, `rename`, and `version`, or their single letter short forms (`--help` and `--version` are not deprecated, for findability; `-L` is not deprecated to match zsh's `alias -L`).

Advanced users no longer need to source zshrc after directly (ie not via the abbr CLI) editing the user abbreviations file to prevent against the possibility of losing data when subsequently running abbr actions in an open session. Details in the README.

Also a fix for Oh-My-Zsh users, and protection against the possibility that builtins have been redefined by aliases and that zsh emulation has been set to another shell.

### Bug Fixes

* **omz:** plugin file is executable ([e2f6632](https://github.com/olets/zsh-abbr/commit/e2f6632e014675526fbb70d19af5923bb0286891))


### Features

* **abbr:** argument can be a supported parameter's name... ([47cfb6a](https://github.com/olets/zsh-abbr/commit/47cfb6a7afd86357f1ea87ac99ce8f14a42c8fe3))
* **add:** dry run, command overwriting, and log messages play nice ([9a17c8b](https://github.com/olets/zsh-abbr/commit/9a17c8b2e3d38b93bb101b0ff9437d620cd5ce46))
* **add:** wrap 'command', using builtin ([042e68d](https://github.com/olets/zsh-abbr/commit/042e68dbc07b64e8ff7a569825e9585aa00d9c61))
* **autoload:** support opting out with env var ([9658a67](https://github.com/olets/zsh-abbr/commit/9658a677bd03ac60654ea6f382b344d8671c552c))
* **commands:** deprecate dash prefixes ([3f75f57](https://github.com/olets/zsh-abbr/commit/3f75f575090dc9ffdb90f0010db8443e07e507b7))
* **data:** manual changes are taken into account... ([00abe87](https://github.com/olets/zsh-abbr/commit/00abe87ef059f92c0cbd5a091e5c4c4e12a01929))
* **echo:** wrap builtin ([c4ee8e2](https://github.com/olets/zsh-abbr/commit/c4ee8e2292493a63fda8fd64fbc2887dd0528f75))
* **emulation:** emulate zsh in all functions ([f644f1a](https://github.com/olets/zsh-abbr/commit/f644f1ad41daf968df768c80ff7fa32836f00cba))
* **error:** do not push the help command ([379ae70](https://github.com/olets/zsh-abbr/commit/379ae7043e6a593e87fa2fe9060232e457bf2ded))
* **import aliases:** wrap alias command ([cbb9bb5](https://github.com/olets/zsh-abbr/commit/cbb9bb504f9be74ab42a793177b9278fd6f308cc))
* **list-commands:** deprecate --show, s ([fd58b39](https://github.com/olets/zsh-abbr/commit/fd58b39550c30aaf7f4ee09c8a6ccb9917156bcc))
* **loading:** always reload user file ([3776076](https://github.com/olets/zsh-abbr/commit/3776076b7ab4d9e06fc93fc9fb3261c1d201f789))
* **warnings:** do not cause an error exit code ([f8b02be](https://github.com/olets/zsh-abbr/commit/f8b02be1d9db6a38e899518496313041cdec04ad))



# [v3.3.1](https://github.com/olets/zsh-abbr/compare/v3.3.0...v3.3.1) (2020-05-12)

Fixed a Linux error, caught a regression.

### Bug Fixes

* **add:** do not wrap 'command' [[#16](https://github.com/olets/zsh-abbr/issues/16)] ([28697f3](https://github.com/olets/zsh-abbr/commit/28697f359de6382a75ae506feee6b63a01d66451))
* **help:** reinstate man fallback ([1ae0acb](https://github.com/olets/zsh-abbr/commit/1ae0acbb0aa72ea1ad83771e1fb98ae186dfd086))


### Features

* **add:** do not check for command name conflicts during init ([153b2e3](https://github.com/olets/zsh-abbr/commit/153b2e3f273612582b38f69242d6ee425649b460))



# [v3.3.0](https://github.com/olets/zsh-abbr/compare/v3.2.3...v3.3.0) (2020-05-09)

Prettier output. Suppress output with `--quiet`. Don't add an abbreviation if it would interfere with an existing command. Add it anyway with `--force`.

### Features

* **add:** support forcing add over system command ([57eb4a8](https://github.com/olets/zsh-abbr/commit/57eb4a8671df10f30cf24e49cad3be1156511f40))
* **add:** warn if a command exists ([0311ecf](https://github.com/olets/zsh-abbr/commit/0311ecf6db742df733f20c583d0c27afeb3ecff3))
* **dry run:** helper message more visible ([cce33fc](https://github.com/olets/zsh-abbr/commit/cce33fcf6cb37bd0f36dfdbfddb3d9f689bdbe4d))
* **import aliases:** respect type ([c000975](https://github.com/olets/zsh-abbr/commit/c000975526a798498e1b1cbdb679e1a796ed1943))
* **import git aliases:** warning gives key not full key+value ([cbe4074](https://github.com/olets/zsh-abbr/commit/cbe4074ef5c795d4d641715bf0bf5490a75087ab))
* **quiet, exit status:** output to stdout or stderr with quiet option ([e671a87](https://github.com/olets/zsh-abbr/commit/e671a8794f9b1abcd0976583c0727a8ebf18caf9))


# [v3.2.3](https://github.com/olets/zsh-abbr/compare/v3.2.2...v3.2.3) (2020-04-23)


### Bug Fixes

* **import git aliases:** preserve quotation marks ([aa62bd2](https://github.com/olets/zsh-abbr/commit/aa62bd289c8b1d1e4068679f9a6d9139930a9db7))



# [3.2.2](https://github.com/olets/zsh-abbr/compare/v3.2.1...v3.2.2) (2020-04-18)


### Bug Fixes

* **import aliases:** support multi-word aliases and a variety of quote levels, with [@allisio](https://github.com/allisio) [#15](https://github.com/olets/zsh-abbr/pull/15)



# [3.2.1](https://github.com/olets/zsh-abbr/compare/v3.2...v3.2.1) (2020-04-18)

### Features

* **ls:** wrap command to not follow potential alias [#13](https://github.com/olets/zsh-abbr/issues/13) ([a5d7c1d](https://github.com/olets/zsh-abbr/commit/a5d7c1d6f3aa0d6e4b4839c3c3c40c80b876e7a7))

# [3.2](https://github.com/olets/zsh-abbr/compare/v3.1.2...v3.2) (2020-04-07)

Key changes:
- Significantly faster initialization, significantly faster time per add
- Linux-friendly paths (with help from @AlwinW. Thanks!)
- More informative error messages
- Git alias import works again
- Two abbreviations are created for each Git alias, `abbr <alias>` and `abbr -g g<alias>`
- The user abbreviation file is kept alphabetized
- Anything in the user abbreviation file other than abbr commands is ignored and, after the first syncing action, sanitized away
- Erase does not insist that you pass the correct scope and type flags
- Under the hood updates to use more idiomatic zsh

### Bug Fixes

* **git aliases:** one alias per array element ([72b0bd7](https://github.com/olets/zsh-abbr/commit/72b0bd709f52f7ca831fae6a16d1a173c52310d1))
* **git aliases:** proper quoting ([44432b2](https://github.com/olets/zsh-abbr/commit/44432b26fad4c4ff3df54a245e8eb38b2d6ff01b))
* **import aliases:** point to correct command ([2fe9cbf](https://github.com/olets/zsh-abbr/commit/2fe9cbfeb23cd8c875dfc51768e4b2f5cffd8301))
* **initialization:** correct file name ([d1e29eb](https://github.com/olets/zsh-abbr/commit/d1e29eb9b9b0359d2ccddb444168760c37b05a29))
* **job:** typo missing '/' in '/tmp/zsh-abbr-jobs' ([e83f54c](https://github.com/olets/zsh-abbr/commit/e83f54caa0f4ed91908ec2ccb8ce974dfec1f22e))
* **job stack:** play nice with bad options ([c84a1bf](https://github.com/olets/zsh-abbr/commit/c84a1bf33529036257d8e3c654b95df6459d7c71))
* **quotation marks:** unsetting assoc array element requires quotes... ([22336be](https://github.com/olets/zsh-abbr/commit/22336bef67a356281e4d271b1007292a7dca3460))
* **temp files:** directory path plays nice with macos and linux ([814d121](https://github.com/olets/zsh-abbr/commit/814d121776b19e0d2e3b8c594fc9d0cd910cfc37))
* **tests:** test file is removed after tests run ([77b0753](https://github.com/olets/zsh-abbr/commit/77b0753e0a3c51bf16fafb8e77a0af9d59bb4d93))


### Features

* **add, job stack:** error messages are more informative ([3611d33](https://github.com/olets/zsh-abbr/commit/3611d33ade5516c9a2bd12aa7a2d4063631d3a1a))
* **alias, list, sync user:** alphabetize, case-insensitively ([459923c](https://github.com/olets/zsh-abbr/commit/459923cfa0cf6a48d84cd972b102e478d8cad6d0))
* **debugging:** support debug messages ([add63cb](https://github.com/olets/zsh-abbr/commit/add63cb9cf6f664dc6b9d52664c0b18c230bb57e))
* **dry run:** support env variable ([a7df1d7](https://github.com/olets/zsh-abbr/commit/a7df1d7b6fa03de51384223c95db715f8a77dd48))
* **erase:** guess unspecified type + scope; list if multiple matches ([1976228](https://github.com/olets/zsh-abbr/commit/19762280638b238666373ecb96c2e28b2d6cd04a))
* **erase, rename:** support dry run ([c18a57d](https://github.com/olets/zsh-abbr/commit/c18a57ddc3d372feab9ec3fa3db542899504eab1))
* **export aliases:** use list utility to support all quotation levels ([ababcfd](https://github.com/olets/zsh-abbr/commit/ababcfdbc824cd8f358d2d23e55be9f150a30a05))
* **fish:** no longer any need to warn about quotation marks ([a2878ea](https://github.com/olets/zsh-abbr/commit/a2878ea0e5b207f729a84ad8c58dd7b4422b0832))
* **git aliases:** add unprefixed command aliases ([4a7ab7e](https://github.com/olets/zsh-abbr/commit/4a7ab7eb4595a2f394c796acdc3578c60e10f775))
* **git aliases:** skip function aliases ([2733d6b](https://github.com/olets/zsh-abbr/commit/2733d6b5b810dc582b2f6fd1c75b11e72a6ffc9d))
* **importing:** no help instructions when skipping an existing ([b4e406c](https://github.com/olets/zsh-abbr/commit/b4e406c6e4c9732a895edd1d11e5546ce235c7c6))
* **init:** at no point are the user temp files missing... ([4603f5d](https://github.com/olets/zsh-abbr/commit/4603f5d0b1153a62f2ce7515da955d8ef3d8f239))
* **init:** only run abbr commands in user file code... ([93f2024](https://github.com/olets/zsh-abbr/commit/93f20244a7158d57d07df5c0957d9a1c79dc923c))
* **init:** remove deprecated temp files ([af1e348](https://github.com/olets/zsh-abbr/commit/af1e3483de06157e2e8046beaf8965eec632ed41))
* **init, performance:** check to see if file exists before deleting ([6cc58d3](https://github.com/olets/zsh-abbr/commit/6cc58d3537f7514a5bd0e29af1488cb986ad1d28))
* **job pop:** don't add variable to session unnecessarily ([c3af3d7](https://github.com/olets/zsh-abbr/commit/c3af3d7ba9ef10af271ef97875abc842935ebb4e))
* **job stack:** better error message ([a3980df](https://github.com/olets/zsh-abbr/commit/a3980df8bb85f6f071becc34b88a01741887ece3))
* **job stack:** ignore session-scope activity ([9cd9616](https://github.com/olets/zsh-abbr/commit/9cd9616f2d2d5cd6f8022e49b56445dede336a33))
* **job stack:** prevent possibility of collision between sessions ([099145a](https://github.com/olets/zsh-abbr/commit/099145ac1c982149942c9c19a840e030eba1bcd5))
* **job stack:** surface the current job's identity ([3257867](https://github.com/olets/zsh-abbr/commit/3257867b6af4e39407b252714773f3a648b4ac1c))
* **job stack, performance:** max one stack item per session ([f50df95](https://github.com/olets/zsh-abbr/commit/f50df958d263418c3bb7a79cba9de01ce6aefd64))
* **list:** reinstate option to list abbreviations without expansions ([99a16e2](https://github.com/olets/zsh-abbr/commit/99a16e2c187b3df4a1957961b933aff07f7b848c))
* **rename, add:** error includes type and scope ([cdf22c0](https://github.com/olets/zsh-abbr/commit/cdf22c0aa117225b80264742f4663924291fafe6))



# [3.1.2](https://github.com/olets/zsh-abbr/compare/v3.1.1...v3.1.2) (2020-03-22)

### Features

* **manpage**: brew users get manpage, rest get text copy ([ed35f49](https://github.com/olets/zsh-abbr/commit/ed35f49c40e1e503881aeb8023616a3c791cb51f))
* **quotes**: quotation marks are preserved [[#10](https://github.com/olets/zsh-abbr/issues/10)] ([5a3b905](https://github.com/olets/zsh-abbr/commit/5a3b9056695fe8c852790d2cfc6f352959cbcfbf))


# [v3.1.1](https://github.com/olets/zsh-abbr/compare/v3.1.0...v3.1.1) (2020-03-07)

### Bug Fixes

* **export aliases:** respect the abbreviation's type ([69fb7a3](https://github.com/olets/zsh-abbr/commit/69fb7a32416fdc5a15945850db7d985370166b44))


### Features

* **CONTRIBUTING:** new file for GitHub friendliness ([6d04986](https://github.com/olets/zsh-abbr/commit/6d04986e754a77da4ff8cb221180e76baeb49627))



# [v3.1.0](https://github.com/olets/zsh-abbr/compare/v3.0.2...v3.1.0) (2020-03-07)

Look like zsh's `alias` not fish's `abbr`

### Changes

* **list commands:** rename from show ([45b9a69](https://github.com/olets/zsh-abbr/commit/45b9a690a4688eb039d261fb463b1d03c00a0cbf))
* **rename:** shorthand is now capital -R and update tests ([c0cdce2](https://github.com/olets/zsh-abbr/commit/c0cdce22f06ffc282b6975893e6ae602b1b51f73))


### Bug Fixes

* **show:** listed session abbreviation commands include -S ([57f98ea](https://github.com/olets/zsh-abbr/commit/57f98eade5fa2f25c65f5df0131e5ac5d15ce1a8))


### Features

* **list commands:** support listing globals only ([7418fac](https://github.com/olets/zsh-abbr/commit/7418facc8353dabbbc3ad886f05b32ffcf499ace))
* **list commands:** support listing regulars only ([a5cab16](https://github.com/olets/zsh-abbr/commit/a5cab1620200240bc716da61f0da7f8cc12d241f))
* **list commands:** support listing users only ([9544e98](https://github.com/olets/zsh-abbr/commit/9544e98133f9b4789627ca7e08e21bed7ced1d5d))
* **list definitions:** with no arguments, behaves like zsh alias ([6c1a7a8](https://github.com/olets/zsh-abbr/commit/6c1a7a802dff9eebcdab8b0625695b85c25c2a6f))



# [v3.0.2](https://github.com/olets/zsh-abbr/compare/v3.0.1...v3.0.2) (2020-03-07)


### Bug Fixes

* **expand and accept:** respect trailing whitespace ([f027565](https://github.com/olets/zsh-abbr/commit/f0275653a93579ba66caa01abbeef950bef31b39))
* **expansion:** no false positive expansions after (( ([2b53f6a](https://github.com/olets/zsh-abbr/commit/2b53f6adb262e08a45da6ec51938ad49d763c349))



# [v3.0.1](https://github.com/olets/zsh-abbr/compare/v3.0.0...v3.0.1) (2020-03-07)

### Bug Fixes

* **init:** prevent collision with other initializing sessions [[#8](https://github.com/olets/zsh-abbr/issues/8)] ([f02fe24](https://github.com/olets/zsh-abbr/commit/f02fe2414b07f2a84dff887db91cd6c0465a0546))


# [v3.0.0](https://github.com/olets/zsh-abbr/compare/v2.1.3...v3.0.0) (2020-03-01)

Parity with zsh alias's behavior: syntax is `abbreviation=word` instead of fish abbr-like `abbreviation word`. Distinguish between command-position abbreviations and global abbreviations. User abbreviations file is now at `${HOME}/.config/zsh/abbreviations`. Check the README documentation for `--import-fish` to move from fish abbr and zsh-abbr<\v3 to zsh-abbr v3.

* **erase, rename:** support global expansions ([bab6341](https://github.com/olets/zsh-abbr/commit/bab63410770d2e1d515e78d933a91c5b681dd712))
* **expansion:** shell grammar word splitting determines current word ([a3c00f5](https://github.com/olets/zsh-abbr/commit/a3c00f58e29370ba294ed3e3d6064af0767fa1ca))
* **global abbreviations:** distinct from command abbreviations ([cd58e0d](https://github.com/olets/zsh-abbr/commit/cd58e0db949f8863393ded51eaa5a894d3e0aae7))
* **import aliases:** rename from populate ([2d4153a](https://github.com/olets/zsh-abbr/commit/2d4153a9fd7002f9710a68a16a1cf1f3ac6063ef))
* **import git aliases:** rename from git populate ([2f8e7bf](https://github.com/olets/zsh-abbr/commit/2f8e7bf6859c9562b6ec5561b668de28e649de99))
* **init,add,erase,rename:** use abbr=expansion syntax ([455dc75](https://github.com/olets/zsh-abbr/commit/455dc75784e57a9481a818cc0bf9300d2729cfeb))
* **scope:** shorthand for --session is now -S ([cf2f3b8](https://github.com/olets/zsh-abbr/commit/cf2f3b8564ce6f8295fc7396131e4fb171fbe2cf))
* **user file:** no '-a -U' ([ecb367e](https://github.com/olets/zsh-abbr/commit/ecb367e484ac3337b42cbdde9504d129aa26431e))
* **user file, exported variables:** style(env functions, env variables): more consistent naming ([2f52f9f](https://github.com/olets/zsh-abbr/commit/2f52f9f6810a8b77a9a923168d5e703e20e0d38e))


### Features

* **abbreviation, expansion:** can be just a hyphen ([be1a0c9](https://github.com/olets/zsh-abbr/commit/be1a0c914e97f60983909d64ed6515226f492dd2))
* **dry run:** support for add, import, and rename ([59cbdee](https://github.com/olets/zsh-abbr/commit/59cbdee7601be7aa80c61357eb41d3a1bf71675e))
* **import fish:** new option + documentation ([6d674bb](https://github.com/olets/zsh-abbr/commit/6d674bb738b03b057f488d6c2eb13284eaef0976))
* **list:** sections are divided with a newline ([055e378](https://github.com/olets/zsh-abbr/commit/055e3789ab7f6ffbd4b2be6963cd80eaf44f4b76))
* **storage:** globals are at top of file ([79a920b](https://github.com/olets/zsh-abbr/commit/79a920b8f9014bd1acf5657664e1a9bf74069edc))
* **sync:** use latest user globals ([44b8281](https://github.com/olets/zsh-abbr/commit/44b8281115e9c36ff145b9df94aa8a307cf71318))
* **tests:** add basic test suite ([af08727](https://github.com/olets/zsh-abbr/commit/af08727778043954b7b69000d45d517dd790cd44))


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

* **scratch file:** Linux compatibility ([#3](https://github.com/olets/zsh-abbr/pull/3) by [@ifreund](https://github.com/olets/zsh-abbr/commits?author=ifreund)) ([0e647cd](https://github.com/olets/zsh-abbr/commit/0e647cdf2d07c55b14fb98a6b3a39911c9bdb49d))

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
