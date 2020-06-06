# zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr)

The zsh manager for auto-expanding abbreviations, inspired by fish shell.

**abbr** manages abbreviations - user-defined words that are replaced with longer phrases after they are entered.

For example, a frequently-run command like `git checkout` can be abbreviated to `gco` (or even `co` or `c` or anything else). After entering `gco` and pressing <kbd>Space</kbd>, the full text `git checkout` will appear in the command line. To prevent expansion, press <kbd>Ctrl</kbd><kbd>Space</kbd> in place of <kbd>Space</kbd>. Pressing <kbd>Enter</kbd> after an abbreviation will expand the abbreviation and accept the current line.

Like zsh's `alias`, zsh-abbr supports "regular" (i.e. command-position) and global (anywhere on the line) abbreviations. Like fish abbr, zsh-abbr supports session-specific and cross-session abbreviations.

Run `abbr --help` (or `abbr -h`) for documentation; if the package is installed with Homebrew, `man abbr` is also available.

## Contents

1. [Crash Course](#crash-course)
1. [Installation](#installation)
1. [Usage](#usage)
1. [Advanced](#advanced)
1. [Uninstalling](#uninstalling)
1. [Changelog](#changelog)
1. [Roadmap](#roadmap)
1. [Contributing](#contributing)
1. [License](#license)

## Crash Course

```shell
# Add and use an abbreviation
% abbr gc="git checkout"
% gc[Space] # space expands this to `git checkout `
% abbr gcm="git checkout master"
% gcm[Enter] # enter expands this to `git checkout master` and then accepts
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
%

# Abbreviations are immediately available to all current and future sessions
% source ~/.zshrc
% gc[Space] # expands to `git checkout`

# Add a session-specific abbreviation
% abbr -S x="git checkout"
% x[Space] # expands to `git checkout `
% source ~/.zshrc
% x[Space] # but only in the session it was created in

# Erase an abbreviation
% abbr -e gc
% gc[Space] # no expansion

# Add a global abbreviation
% abbr -g g=git
% echo global && g[Space] # expands to `echo global && git `

# Rename an abbreviation
% abbr -r gcm cm
% gcm[Space] # does not expand
% cm[Space] # expands to `git checkout master `

# Make the switch from aliases
% abbr --import-aliases
% abbr --import-git-aliases
```

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

If you prefer to manage the package with Homebrew but load it with a plugin manager, run the Homebrew installation command and then point the plugin manager to the file Homebrew logs to the console. For example with zinit:

```shell
zinit ice wait lucid
zinit light /usr/local/share/zsh-abbr
```

If running `abbr` gives an error "zsh: permission denied: abbr", reload zsh:

```shell
% source ~/.zshrc
```

### Manual

Clone this repo and add `source path/to/zsh-abbr.zsh` to your `.zshrc`.

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

A given abbreviation can be limited to the current zsh session (i.e. the current terminal) —these are called *session* abbreviations— or to all terminals —these are called *user* abbreviations. Select options take **scope** as an argument.

Newly added user abbreviations are available to all open sessions immediately.

Default is user.

### Type

```shell
[(--global | -g) | (--regular | -r)]
```

zsh-abbr supports regular abbreviations, which match the word at the start of the command line, and global abbreviations, which match any word on the line. Select options take **type** as an argument.

Default is regular.

### Options

zsh-abbr has options to add, rename, and erase abbreviations; to add abbreviations for every alias or Git alias; to list the available abbreviations with or without their expansions; and to create aliases from abbreviations.

`abbr` with no arguments is shorthand for `abbr --list-commands`. `abbr ...` with arguments is shorthand for `abbr --add ...`.

#### Add

```shell
abbr [(--add | -a)] [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)] [--dry-run] [--quiet] [--force] ABBREVIATION=EXPANSION
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

The ABBREVIATION must be only one word long.

As with aliases, to include whitespace, quotation marks, or other special characters like `;`, `|`, or `&` in the EXPANSION, quote the EXPANSION or `\`-escape the characters as necessary.

```shell
abbr a=b\;c  # allowed
abbr a="b|c" # allowed
```

User-scope abbreviations can also be manually to the user abbreviations file. See **Storage** below.

The session regular, session global, user regular, and user global abbreviation sets are independent. If you wanted, you could have more than one abbreviation with the same ABBREVIATION. Order of precedence is "session command > user command > session global > user global".

Use `--dry-run` to see what would result, without making any actual changes.

Will error rather than overwrite an existing abbreviation.

Will warn if the abbreviation would replace an existing command. To add in spite of the warning, use `--force`.

#### Clear Sessions

```shell
abbr (--clear-session | -c)
```

Erase all session abbreviations.

#### Erase

```shell
abbr (--erase | -e) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)] [--dry-run] [--quiet] ABBREVIATION
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

User abbreviations can also be manually erased from the `ZSH_ABBR_USER_PATH`. See **Storage** below.

#### Expand

```shell
abbr (--expand | -x) ABBREVIATION
```

Output the ABBREVIATION's EXPANSION.

```shell
% abbr gc="git checkout"
% abbr -x gc; # or `abbr -x gc[Ctrl-Space][Enter]`
git checkout
```

#### Export Aliases

```shell
abbr --export-aliases [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)] [DESTINATION]
```

Export abbreviations as alias commands. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

Use the **--session** or **-S** scope flag to export only session abbreviations. Use the **--user** or **-U** scope flag to export only user abbreviations.

Use the **--global** or **-g** type flag to export only global abbreviations. Use the **--regular** or **-r** type flag to export only regular abbreviations.

Combine a scope flag and a type flag to further limit the output.

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
abbr --import-aliases [<type>] [--dry-run] [--quiet]
```

Add regular abbreviations for every regular alias in the session, and global abbreviations for every global alias in the session.

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

##### Fish Abbreviations

```shell
abbr --import-fish [(--session | -S) | (--user | -U)] [(--global|-g)] FILE [--dry-run] [--quiet]
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
# If not customizing `ZSH_ABBR_USER_PATH=${HOME}/.config/zsh/universal-abbreviations` feel free to
# rm ${HOME}/.config/zsh/universal-abbreviations
```

Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

Use `--dry-run` to see what would result, without making any actual changes.

##### Git Aliases

```shell
abbr --import-git-aliases [--dry-run] [--quiet]
```

Add two abbreviations for every Git alias available in the current session: a global abbreviation where the WORD is prefixed with `g`, and a command abbreviation. For both the EXPANSION is prefixed with `git[Space]`.

Use the **--session**  or **-S** scope flag to create session abbreviations. Otherwise, or if the **--user** or **-U** scope flag is used, the Git abbreviations will be user.

```shell
% git config alias.co checkout

# session
% abbr --import-git-aliases -S
% gco[Space] # git checkout
% echo gco[Space] # echo git checkout
% co[Space] # git checkout
% echo co[Space] # echo co
% source ~/.zshrc
% gco[Space] # gco

# user
% abbr --import-git-aliases
% gco[Space] # git checkout
% source ~/.zshrc
% gco[Space] # git checkout
```

Note for users migrating from Oh-My-Zsh: [OMZ's Git aliases are shell aliases](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh), not aliases in the Git config. To add abbreviations for them, use **import-aliases**.

Note that zsh-abbr does not lint the imported abbreviations. It is up to the user to double check the result before taking further actions.

Use `--dry-run` to see what would result, without making any actual changes.

#### List

List all the abbreviations available in the current session. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

Use the **--session** or **-S** scope flag to list only session abbreviations. Use the **--user** or **-U** scope flag to list only user abbreviations.

Use the **--global** or **-g** type flag to list only global abbreviations. Use the **--regular** or **-r** type flag to list only regular abbreviations.

Combine a scope flag and a type flag to further limit the output.

##### Abbreviations

```shell
abbr (--list-abbreviations|-l) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
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
abbr (--list-commands | -L | -s) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
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
abbr [--list-definitions] [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)]
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
abbr (--rename | -R) [(--session | -S) | (--user | -U)] [(--global | -g) | (--regular | -r)] [--dry-run] [--quiet] OLD NEW
```

Rename an abbreviation.

Use the **--session** or **-S** scope flag to rename a session abbreviation. Otherwise, or if the **--user** or **-U** scope flag is used, a cross-session abbreviation will be renamed.

Use the **--global** flag to rename a global abbreviation. Otherwise a command abbreviation will be renamed.

Rename is scope- and type-specific. If you get a "no matching abbreviation" error, make sure you added the right flags (list abbreviations if you are not sure).

```shell
% abbr --add gcm git checkout master
% gcm[Space] # expands to git checkout master
% gm[Space] # no expansion
% abbr --rename gcm[Ctrl-Space] gm
% gcm[Space] # no expansion
% gm[Space] # expands to git checkout master
```

Use `--dry-run` to see what would result, without making any actual changes..

Abbreviations can also be manually renamed in the `ZSH_ABBR_USER_PATH`. See **Storage** below.

## Advanced

### Storage and manual editing

User abbreviations live in a plain text file which you can edit directly, share, keep in version control, etc. Abbreviations in this file are loaded when each new session is opened; non-`abbr` commands will be ignored excised from the file.

When zsh-abbr updates the user abbreviations storage file, the lines are alphabetized and global user abbreviations are moved to the top of the file.

Run `abbr --load` to load changes made directly to the user abbreviation file (that is, changes made with a text editor or `echo` as opposed to changes made with `abbr (--add|--erase|--import…|--rename)`) into the current session.

`abbr --load` is run automatically at the start of every other `abbr` command (`abbr (--add|--erase|--import…|--rename)`, not every expansion). This should add no appreciable time (clocked at 0.02ms per saved abbreviation), but it can be turned off by setting `ZSH_ABBR_AUTOLOAD=0`.

The user abbreviations storage file's default location is `${HOME}/.config/zsh/abbreviations`. Customize this by setting the `ZSH_ABBR_USER_PATH` variable in your `.zshrc` before loading zsh-abbr:

```shell
% cat ~/.zshrc
# -- snip --
ZSH_ABBR_USER_PATH="path/to/my/user/abbreviations"
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

If you want to set your own bindings, set `ZSH_ABBR_DEFAULT_BINDINGS` to `0` or `false` in your `.zshrc` before loading zsh-abbr. In the following example, expansion is bound to <kbd>Ctrl</kbd><kbd>a</kbd>:

```shell
% cat ~/.zshrc
# -- snip --
ZSH_ABBR_DEFAULT_BINDINGS=false
bindkey "^A" _zsh_abbr_expand_space
# -- snip --
# load zsh-abbr
```

## Uninstalling

Delete the session data storage directory

```shell
% rm -rf ${TMPDIR:-/tmp/}zsh-abbr
```

To delete the user abbreviations file,

```shell
% rm $ZSH_ABBR_USER_PATH
```

If you haven't customized `$ZSH_ABBR_USER_PATH`, you will probably want to delete its parent directory

```shell
# see if there's anything in there
% ls $ZSH_ABBR_USER_PATH:h
# IF you want to delete it
% rm -rf $ZSH_ABBR_USER_PATH:h
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

To force a dry run without passing `--dry-run`, set `ZSH_ABBR_DRY_RUN` to `1.

To force quiet mode with passing `--quiet`, set `ZSH_ABBR_QUIET` to `1`.

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
