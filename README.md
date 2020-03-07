# zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr)

The zsh manager for auto-expanding abbreviations.

**abbr** manages abbreviations - user-defined words that are replaced with longer phrases after they are entered.

For example, a frequently-run command like `git checkout` can be abbreviated to `gco`. After entering `gco` and pressing <kbd>Space</kbd>, the full text `git checkout` will appear in the command line. To prevent expansion, press <kbd>Ctrl</kbd><kbd>Space</kbd> in place of <kbd>Space</kbd>. Pressing <kbd>Enter</kbd> after an abbreviation will expand the abbreviation and accept the current line.

Like zsh's `alias`, zsh-abbr supports "regular" (i.e. command-position) and global (anywhere on the line) abbreviations. Like fish abbr, zsh-abbr supports session-specific and cross-session abbreviations.

Run `abbr --help` (or `abbr -h`) for documentation.

## Contents

1. [Installation](#installation)
1. [Quick Start](#quick-start)
1. [Usage](#usage)
1. [Configuration](#configuration)
1. [Changelog](#changelog)
1. [Roadmap](#roadmap)
1. [Contributing](#contributing)
1. [Uninstalling](#uninstalling)

## Installation

### Package

zsh-abbr is available on Homebrew. Run

```
brew install olets/tap/zsh-abbr
```

and follow the post-install instructions logged to the terminal.

### Plugin

Or install zsh-abbr with your favorite plugin manager:

- **[antibody](https://getantibody.github.io/)**: Add `olets/zsh-abbr` to your plugins file. If you use static loading, reload plugins.

- **[Antigen](https://github.com/zsh-users/antigen)**: Add `antigen bundle olets/zsh-abbr` to your `.zshrc`.

- **[Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh)**:

  - Clone to OMZ's plugins' directory:

    ```shell
    git clone https://github.com/olets/zsh-abbr.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-abbr
    ```

  - Add to the OMZ plugins array in your `.zshrc`:

    ```shell
    plugins=( [plugins...] zsh-abbr)
    ```

- **[zgen](https://github.com/tarjoilija/zgen)**: add `zgen load olets/zsh-abbr` to your `.zshrc`.

- **[zinit](https://github.com/zdharma/zinit)** (formerly **zplugin**): add this to your `.zshrc`:
  ```shell
  zinit ice wait lucid
  zinit light olets/zsh-abbr # or `load` instead of `light` to enable zinit reporting
  ```

- **[zplug](https://github.com/zplug/zplug)**: add `zplug "olets/zsh-abbr"` to your `.zshrc`.

If running `abbr` gives an error "zsh: permission denied: abbr", reload zsh:

```shell
% source ~/.zshrc # or your custom .zshrc path
```

### Manual

Clone this repo and add `source path/to/zsh-abbr.zsh` to your `.zshrc`.

## Quick Start

```shell
# Add and use an abbreviation
% abbr g=git
% g[Space] # expands to `git `
# It is saved for your user and immediately available to open sessions
% source ~/.zshrc # or switch to different session
% g[Space] # expands to `git `

# Add a session-specific abbreviation
% abbr -S x=git
% x[Space] # expands to `git `
% source ~/.zshrc # or switch to different session
% x[Space] # no special treatment

# Erase an abbreviation
% abbr -e g; # the `;` prevents expansion. Ctrl-Space would work too
% g[Space] # no expansion

# Add a global abbreviation
% abbr -g g=git
% echo hello world && g[Space] # expands

# Enter expands and accepts
% abbr gcm="git checkout master"
% gcm[Enter]
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
%

# Rename an abbreviation
% abbr -r gcm gm
% gcm[Space] # does not expand
% gm[Space] # expands to `git checkout master `

# Make the switch from aliases
% abbr --import-aliases
% abbr -g --import-git-aliases
```

## Usage

```shell
abbr <SCOPE> <OPTION> <ANY OPTION ARGUMENTS>
```

or

```shell
abbr <OPTION> <SCOPE> <ANY OPTION ARGUMENTS>
```

### Scope

```shell
[(--session | -S) | (--user | -U)]
```

A given abbreviation can be made available in the current zsh session (i.e. in the current terminal) —these are called *session* abbreviations— or to all terminals —these are called *user* abbreviations. Select options take **scope** as an argument.

Newly added user abbreviations are available to all open sessions immediately.

Default is user.

### Type

```shell
[(--global | -g) | (--regular | -r)]
```

zsh-abbr supports regular abbreviations, which match the word at the start of the command line, and global abbreviations, which match any word on the line. Select options take **type** as an argument.

Default is regular.

### Options

```shell
[(--add | -a )] [(--global | -g)] [--dry-run] arg
  | (--clear-session | -c)
  | (--erase | -e ) [(--global | -g)] arg
  | (--expand | -x) arg
  | --export-aliases arg
  | (--help | -h)
  | --import-aliases [(--global | -g)] [--dry-run]
  | --import-fish [(--global | -g)] [--dry-run] arg
  | --import-git-aliases [--dry-run]
  | (--list-abbreviations | -l) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
  | (--list-commands | -L | -s) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
  | [--list-definitions] [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
  | (--rename | -R ) [(--global | -g)] [--dry-run] args
]
```

`zsh-abbr` has options to add, rename, and erase abbreviations; to add abbreviations for every alias or Git alias; to list the available abbreviations with or without their expansions; and to create aliases from abbreviations.

`abbr` with no arguments is shorthand for `abbr --list-commands`. `abbr ...` with arguments and no flags is shorthand for `abbr --add ...`.

#### Add

```shell
abbr [(--add | -a)] [(--global | -g)] [--dry-run] ABBREVIATION=EXPANSION
```

Add a new abbreviation.

To add a session abbreviation, use the **--session** or **-S** scope flag. Otherwise, or if the **--user** or **-U** scope flag is used, the new abbreviation will be available to all sessions.

To add a global abbreviation, use the **--global** flag. Otherwise the new abbreviation will be a command abbreviation.

```shell
% abbr --add gcm='git checkout master'
% gcm[Space] # expands as git checkout master
% gcm[Enter] # expands and accepts git checkout master
```

The following are equivalent:

```shell
% abbr --add --user gcm='git checkout master'
% abbr -a --user gcm='git checkout master'
% abbr --user gcm='git checkout master'
% abbr --add -U gcm='git checkout master'
% abbr -a -U gcm='git checkout master'
% abbr -U gcm='git checkout master'
% abbr gcm='git checkout master'
```

The following are not allowed in the abbreviation: `;`, `|`, `&&`, `=`, and whitespace.

```shell
abbr a\;b=c   # will error
abbr 'a||b'=c # will error
```

As with aliases, to include whitespace, quotation marks, or other special characters like `;`, `|`, or `&` in the EXPANSION, quote the EXPANSION or `\`-escape the characters as necessary.

```shell
abbr a=b\;c  # allowed
abbr a="b|c" # allowed
```

User-scope abbreviations can also be manually to the user abbreviations file. See **Storage** below.

The session regular, session global, user regular, and user global abbreviation sets are independent. Order of precedence is "session command > user command > session global > user global".

Use `--dry-run` to see what would result, without making any actual changes.

#### Clear Sessions

```shell
abbr (--clear-session | -c)
```

Erase all session abbreviations.

#### Erase

```shell
abbr (--erase | -e) [(--global | -g)] ABBREVIATION
```

Erase an abbreviation.

Use the **--session** or **-S** scope flag to erase a session abbreviation. Otherwise, or if the **--user** or **-U** scope flag is used, a cross-session abbreviation will be erased.

Use the **--global** flag to erase a session abbreviation. Otherwise a cross-session abbreviation will be erased.

```shell
% abbr gcm="git commit master"
% gcm[Enter] # expands and accepts git commit master
Switched to branch 'master'
% abbr -e gcm;[Enter] # or abbr -e gcm[Ctrl-Space][Enter]
% gcm[Space|Enter] # normal
```

User abbreviations can also be manually erased from the `ZSH_USER_ABBREVIATIONS_PATH`. See **Storage** below.

#### Expand

```shell
abbr (--expand | -x) ABBREVIATION
```

Output the ABBREVIATION's EXPANSION. Useful in scripting.

```shell
% abbr gc="git checkout"
% abbr -x gc[Ctrl-Space]
git checkout
```

#### Export Aliases

```shell
abbr --export-aliases [DESTINATION]
```

Export abbreviations as aliases declarations.

To export session abbreviations, use the **--session** or **-S** scope flag. Otherwise, or if the **--user** or **-U** scope flag is used, cross-session abbreviations are exported.

```shell
% abbr gcm="git checkout master"
% abbr -S g=git
% abbr --export-aliases
alias gcm='git checkout master'
% abbr --export-aliases --session
alias g='git'
% abbr --export-aliases ~/.zshrc
% cat ~/.zshrc
# -- snip --
alias g='git'
```

#### Import

##### Aliases

```shell
abbr --import-aliases [--dry-run]
```

Add regular abbreviations for every regular alias in the session, and global abbreviations for every global alias in the session.

Use the **--session** or **-S** scope flag to create session abbreviations. Otherwise, or if the **--user** or **-U** scope flag is used, the abbreviations will be cross-session.

```shell
% cat ~/.zshrc
# --snip--
alias -S d='bin/deploy'
# --snip--

% abbr --import-aliases
% d[Space] # expands to bin/deploy
```

Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

Use `--dry-run` to see what would result, without making any actual changes.

##### Git Aliases

```shell
abbr --import-git-aliases [(--global | -g)] [--dry-run]
```

Add abbreviations for every Git alias available in the current session. WORDs are prefixed with `g`; EXPANSIONs are prefixed with `git[Space]`. Use the **--session**  or **-S** scope flag to create session abbreviations. Otherwise, or if the **--user** or **-U** scope flag is used, the Git abbreviations will be user.

```shell
% git config alias.co checkout
% abbr --import-git-aliases -S
% gco[Space] # expands to git checkout
% source ~/.zshrc
% gco[Space] # no expansion
% abbr --import-git-aliases
% source ~/.zshrc
% gco[Space] # expands to git checkout
```

Note for users migrating from Oh-My-Zsh: [OMZ's Git aliases are shell aliases](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh), not aliases in the Git config. To add abbreviations for them, use **Populate**.

Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

Use `--dry-run` to see what would result, without making any actual changes.

##### Fish Abbreviations

```shell
abbr --import-fish FILE [--dry-run]
```

Import fish abbr-syntax abbreviations (`abbreviation expansion` as compared to zsh abbr's `abbreviation=expansion`).

To migrate from fish:

```shell
fish
abbr -s > file/to/save/fish/abbreviations/to
zsh
abbr [(--global|-g)] [SCOPE] --import-fish file/to/save/fish/abbreviations/to
# file is no longer needed, so feel free to
# rm file/to/save/fish/abbreviations/to
```

To migrate from zsh-abbr < 3:

```shell
zsh
abbr [(--global|-g)] [SCOPE] ${HOME}/.config/zsh/universal-abbreviations
# zsh-abbr > 2 no longer uses that file
# If not customizing `ZSH_USER_ABBREVIATIONS_PATH=${HOME}/.config/zsh/universal-abbreviations` feel free to
# rm ${HOME}/.config/zsh/universal-abbreviations
```

Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

Use `--dry-run` to see what would result, without making any actual changes.

#### List

List all the abbreviations available in the current session. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

Use the **--session** or **-S** scope flag to list only a session abbreviations. Use the **--user** or **-U** scope flag to list only a session abbreviations.

Use the **--global** or **-g** type flag to list only global abbreviations. Use the **--regular** or **-r** type flag to list only global abbreviations.

Combine a scope flag and a type flag to further limit the output.

##### Abbreviations

```shell
abbr (--list-abbreviations|-l) [(--session | -S) | (--user | -U)] [(--global | -g)]
```

List the abbreviations only, like fish's `abbr -l`.

```shell
% abbr a=apple
% abbr -g b=ball
% abbr -S c=cat
% abbr -S -g d=dog
% abbr --list-abbreviations
a
b
c
d
% source ~/.zshrc
% abbr --list-abbreviations
a
b
```

##### Commands

```shell
abbr (--list-commands | -L | -s) [(--session | -S) | (--user | -U)] [(--global | -g)]
```

List as commands, like zsh's `alias -L`.

```shell
% abbr a=apple
% abbr -g b=ball
% abbr -S c=cat
% abbr -S -g d=dog
% abbr --list-abbreviations
abbr a="apple"
abbr -g b="ball"
abbr -S c="cat"
abbr -S -g d="dog"
% source ~/.zshrc
% abbr --list-abbreviations
abbr a="apple"
abbr -g b="ball"
```

##### Definitions

```shell
abbr [--list-definitions] [(--session | -S) | (--user | -U)] [(--global | -g)]
```

List as commands, like zsh's `alias`.

```shell
% abbr a=apple
% abbr -g b=ball
% abbr -S c=cat
% abbr -S -g d=dog
% abbr # or abbr --list-abbreviations
a="apple"
b="ball"
c="cat"
d="dog"
% source ~/.zshrc
% abbr # or abbr --list-abbreviations
a="apple"
b="ball"
```

#### Rename

```shell
abbr (--rename | -R) [(--global | -g)] [--dry-run] OLD NEW
```

Rename an abbreviation.

Use the **--session** or **-S** scope flag to rename a session abbreviation. Otherwise, or if the **--user** or **-U** scope flag is used, a cross-session abbreviation will be renamed.

Use the **--global** flag to rename a global abbreviation. Otherwise a command abbreviation will be renamed.

Rename is session/user- and regular/global-specific. If you get a "no matching abbreviation" error, make sure you added the right flags.

```shell
% abbr --add gcm git checkout master
% gcm[Space] # expands to git checkout master
% gm[Space] # no expansion
% abbr --rename gcm[Ctrl-Space] gm
% gcm[Space] # no expansion
% gm[Space] # expands to git checkout master
```

Use `--dry-run` to see what would result, without making any actual changes..

Abbreviations can also be manually renamed in the `ZSH_USER_ABBREVIATIONS_PATH`. See **Storage** below.

## Configuration

### Storage

User abbreviations live in a plain text file which you can edit directly, share, keep in version control, etc. This file is `source`d when each new session is opened.

When zsh-abbr updates the user abbreviations storage file, global user abbreviations are moved to the top of the file.

_It is possible for direct edits to the storage file to be lost_ if you make a change to the user abbreviations in a session that opened before the manual change was made. Run `source ~/.zshrc` in all open sessions after directly editing the user abbreviations storage file.

The user abbreviations storage file's default location is `${HOME}/.config/zsh/abbreviations`. Customize this by setting the `ZSH_USER_ABBREVIATIONS_PATH` variable in your `.zshrc` before loading zsh-abbr.

```shell
% cat ~/.zshrc
# -- snip --
ZSH_USER_ABBREVIATIONS_PATH="path/to/my/user/abbreviations"
# -- snip --
# load zsh-abbr
```

The default file is created the first time zsh-abbr is run. If you customize the path, you may want to delete the default file or even the default zsh-abbr config directory.

### Bindings

By default

- <kbd>Space</kbd> expands abbreviations
- <kbd>Ctrl</kbd><kbd>Space</kbd> is a normal space
- <kbd>Enter</kbd> expands and accepts abbreviations

(In incremental search mode, <kbd>Space</kbd> is a normal space and <kbd>Ctrl</kbd><kbd>Space</kbd> expands abbreviations.)

If you want to set your own bindings, set `ZSH_ABBR_DEFAULT_BINDINGS` to `false` in your `.zshrc` before loading zsh-abbr. In the following example, expansion is bound to <kbd>Ctrl</kbd><kbd>a</kbd>:

```shell
% cat ~/.zshrc
# -- snip --
ZSH_ABBR_DEFAULT_BINDINGS=false
bindkey "^A" _zsh_abbr_expand_space
# -- snip --
# load zsh-abbr
```

## Uninstalling

Delete the zsh-abbr configuration directory. Note that this will permanently delete the user abbreviations file.

```shell
% rm -rf $(dirname "$ZSH_USER_ABBREVIATIONS_PATH")
```

Then follow the standard uninstallation procedure for your installation method. This is typically the reverse of what you did to install.

## Changelog

See the [CHANGELOG](CHANGELOG.md) file.

## Roadmap

See the [ROADMAP](ROADMAP.md) file.

## Contributing

Thanks for your interest. Contributions are welcome!

> Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Check the [Issues](https://github.com/olets/zsh-abbr/issues) to see if your topic has been discussed before or if it is being worked on. You may also want to check the roadmap (see above). Discussing in an Issue before opening a Pull Request means future contributors only have to search in one place.

This project loosely follows the [Angular commit message conventions](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit). This helps with searchability and with the changelog, which is generated automatically and touched up by hand only if necessary. Use the commit message format `<type>(<scope>): <subject>`, where `<type>` is **feat** for new or changed behavior, **fix** for fixes, **docs** for documentation, **style** for under the hood changes related to for example zshisms, **refactor** for other refactors, **test** for tests, or **chore** chore for general maintenance (this will be used primarily by maintainers not contributors, for example for version bumps). `<scope>` is more loosely defined. Look at the [commit history](https://github.com/olets/zsh-abbr/commits/master) for ideas.

Tests are in the `tests` directory. To run them, replace `zsh-abbr` with `zsh-abbr/tests` in .zshrc. For example, zinit users will run

```shell
zinit ice lucid
zinit light olets/zsh-abbr/tests
```

in place of

```shell
zinit ice lucid
zinit light olets/zsh-abbr
```

Open a new session and the tests will run.

## License

This project is licensed under [MIT license](http://opensource.org/licenses/MIT).
For the full text of the license, see the [LICENSE](LICENSE) file.
