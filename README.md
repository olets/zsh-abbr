# zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr)

The zsh manager for auto-expanding abbreviations manager.

**abbr** manages abbreviations - user-defined words that are replaced with longer phrases after they are entered.

For example, a frequently-run command like `git checkout` can be abbreviated to `gco`. After entering `gco` and pressing <kbd>Space</kbd>, the full text `git checkout` will appear in the command line. To prevent expansion, press <kbd>Ctrl</kbd><kbd>Space</kbd> in place of <kbd>Space</kbd>. Pressing <kbd>Enter</kbd> after an abbreviation will expand the abbreviation and accept the current line.

Abbreviations are expanded whether or not they are the first word on the line, like zsh's global aliases. Cross-session abbreviations are stored in the clear in a plaintext configuration file.

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
% abbr m master
% m[Space] # expands to `master`
% git checkout m[Space] # becomes `git checkout master`
% git checkout m[Enter]
# expands to and runs `git checkout master`

% abbr gcm git checkout master
# Note the `m`s in `gcm` and `master` did not expand. Expansion only run on entire words
% gcm[Enter]
# expands to and runs `git checkout master`

# The above will in other open sessions, and in future sessions.
# Add an abbreviation only available in the current terminal
% abbr -S gco[Ctrl-Space] https://en.wikipedia.org/wiki/GCO
# (Note that Ctrl-Space opts out of space-triggered expansion)
% gco[Space] # expands to `https://en.wikipedia.org/wiki/GCO`

# Rename it
% abbr -r gco[Ctrl-Space] wgco
% gco[Space] # expands to `git checkout`
% wgco[Space] # expands to `https://en.wikipedia.org/wiki/GCO`

# Delete it
% abbr -S wgco[Ctrl-Space]
% wgco[Space] # no expansion

# Migrate your aliases to abbreviations
% abbr -p # creates abbreviations from all aliases
% abbr -i # creates abbreviations from all Git aliases, adding 'g' prefix
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

A given abbreviation can be made available in the current zsh session (i.e. in the current terminal) —these are called *session* abbreviations— or to all terminals —these are called *user* abbreviations.

Newly added user abbreviations are available to all open sessions immediately.

Default is user.

### Options

```shell
[(--add | -a ) [(--global | -g)] arg
  | (--clear-session | -c)
  | (--erase | -e ) [(--global | -g)] arg
  | (--expand | -x) arg
  | --export-aliases arg
  | (--help | -h)
  | --import-fish [(--global | -g)] arg
  | --import-aliases
  | --import-git-aliases
  | (--list | -l)
  | (--rename | -r ) [(--global | -g)] args
  | (--show | -s)
]
```

`zsh-abbr` has options to add, rename, and erase abbreviations; to add abbreviations for every alias or Git alias; to list the available abbreviations with or without their expansions; and to create aliases from abbreviations.

`abbr` with no arguments is shorthand for `abbr --show`. `abbr ...` with arguments and no flags is shorthand for `abbr --add ...`.

#### Add

```shell
abbr [(--add  [(--global | -g)] | -a [(--global | -g)] )] ABBREVIATION=EXPANSION
```

Add a new abbreviation.

To add a session abbreviation, use the **--session** flag. Otherwise, or if the **--user** flag is used, the new abbreviation will be available to all sessions.

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

User-scope abbreviations can also be manually to the user abbreviations file. See the Storage documentation, below.

#### Clear Sessions

```shell
abbr (--clear-session | -c)
```

Erase all session abbreviations.

#### Erase

```shell
abbr (--erase [(--global | -g)] | -e [(--global | -g)]) ABBREVIATION
```

Erase an abbreviation.

Use the **--session** flag to erase a session abbreviation. Otherwise, or if the **--user** flag is used, a cross-session abbreviation will be erased.

Use the **--global** flag to erase a session abbreviation. Otherwise a cross-session abbreviation will be erased.

```shell
% abbr --add gcm git commit master
% gcm[Enter] # expands and accepts git commit master
Switched to branch 'master'
% abbr --erase gcm[Ctrl-Space][Enter]
% gcm[Space|Enter] # nothing
% abbr --add --session gcm echo gimme cookie monster
% gcm[Enter]
gimme cookie monster
% abbr --erase --session gcm[Ctrl-Space][Enter]
% gcm[Enter]
Already on 'master'
```

User abbreviations can also be manually erased from the `ZSH_USER_ABBREVIATIONS_PATH`.

#### Expand

```shell
abbr (--expand | -x) ABBREVIATION
```

Output the ABBREVIATION's EXPANSION. Useful in scripting.

```shell
% abbr --add gc git checkout
% abbr --expand gc[Ctrl-Space]
git checkout
```

#### Import Git Aliases

```shell
abbr --import-git-aliases
```

Add abbreviations for every Git alias available in the current session. WORDs are prefixed with `g`; EXPANSIONs are prefixed with `git[Space]`. Use the **--session** scope to create session abbreviations. Otherwise, or if the **--user** flag is used, the Git abbreviations will be user.

This command is useful for migrating from aliases to abbreviations.

```shell
% git config alias.co checkout
% abbr --import-git-aliases --session
% gco[Space] # expands to git checkout
% source ~/.zshrc
% gco[Space] # no expansion
% abbr --import-git-aliases
% source ~/.zshrc
% gco[Space] # expands to git checkout
```

Note for users migrating from Oh-My-Zsh: [OMZ's Git aliases are shell aliases](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh), not aliases in the Git config. To add abbreviations for them, use **Populate**.

### Import Fish

```shell
abbr --import-fish FILE
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

#### List

```shell
abbr (--list|-l)
```

List all abbreviations available in the current shell. User abbreviations appear first.

```shell
% abbr a apple
% abbr b ball
% abbr -S c cat
% abbr -l
a
b
c
% source ~/.zshrc
% abbr -l
a
b
```

#### Export Aliases

```shell
abbr --export-aliases [DESTINATION]
```

Export abbreviations as aliases declarations.

To export session abbreviations, use the **--session** flag. Otherwise, or if the **--user** flag is used, cross-session abbreviations are exported.

```shell
% abbr --add gcm git checkout master
% abbr --add --session g git
```
```shell
% abbr --export-aliases
alias -S gcm='git checkout master'
```
```shell
% abbr --export-aliases --session
alias -S g='git'
```
```shell
% abbr --export-aliases ~/.zshrc
% cat ~/.zshrc
# -- snip --
alias -S g='git'
```

#### Import Aliases

```shell
abbr (--import-aliases | -i)
```

Add abbreviations for every alias available in the current session.

Use the **--session** flag to create session abbreviations. Otherwise, or if the **--user** flag is used, the abbreviations will be cross-session.

This command is useful for migrating from aliases to abbreviations.

See also **Import Git Aliases**.

```shell
% cat ~/.zshrc
# --snip--
alias -S d='bin/deploy'
# --snip--

% abbr --import-aliases
% d[Space] # expands to bin/deploy
```

#### Rename

```shell
abbr (--rename [(--global | -g)] | -r [(--global | -g)]) OLD_WORD NEW_WORD
```

Rename an abbreviation.

Use the **--session** flag to rename a session abbreviation. Otherwise, or if the **--user** flag is used, a cross-session abbreviation will be renamed.

Use the **--global** flag to rename a global abbreviation. Otherwise a command abbreviation will be renamed.

```shell
% abbr --add gcm git checkout master
% gcm[Space] # expands to git checkout master
% gm[Space] # no expansion
% abbr --rename gcm[Ctrl-Space] gm
% gcm[Space] # no expansion
% gm[Space] # expands to git checkout master
```

Abbreviations can also be manually renamed in the `ZSH_USER_ABBREVIATIONS_PATH`.

#### Show

```shell
abbr [(--show|-s)]
```

Show all the abbreviations available in the current session, along with their expansions. _**Show** does not take a scope._ Session abbreviations are marked `-g` and follow user abbreviations, which are marked `-U`.

```shell
% abbr --add gcm git checkout master
% abbr --add --session a apple
% abbr --show # or `abbr` with no arguments
abbr -a -U -- gcm git checkout master
abbr -a -S -- a apple
% source ~/.zshrc
% abbr --show
abbr -a -U -- gcm git checkout master
```

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
