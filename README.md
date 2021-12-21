# zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr)

**abbr** is the zsh manager for auto-expanding abbreviations - text that when written in a terminal is replaced with other (typically longer) text. Inspired by fish shell.

For example, a frequently-run command like `git checkout` can be abbreviated to `gco` (or even `co` or `c` or anything else). Type <kbd>Space</kbd> after an abbreviation to expand it. Type <kbd>Enter</kbd> after an abbreviation to expand it and run the expansion. To prevent expansion, add <kbd>Ctrl</kbd> (<kbd>Ctrl</kbd><kbd>Space</kbd> / <kbd>Ctrl</kbd><kbd>Enter</kbd>) or add a delimiter like `;` after the abbreviation.

Like zsh's `alias`, zsh-abbr supports "regular" (i.e. command-position) and "global" (anywhere on the line) abbreviations. Like fish's abbr, zsh-abbr supports interactive creation of persistent abbreviations that are immediately available in all terminal sessions.

Run `abbr help` for documentation; if the package is installed with Homebrew, `man abbr` is also available.

## Contents

1. [Crash Course](#crash-course)
1. [Installation](#installation)
1. [Usage](#usage)
1. [Advanced](#advanced)
1. [Performance](#performance)
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
% abbr gcm="git checkout main"
% gcm[Enter] # enter expands this to `git checkout main` and then accepts
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
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
% cm[Space] # expands to `git checkout main `

# Make the switch from aliases
% abbr import-aliases
% abbr import-git-aliases
```

## Installation

### Package

zsh-abbr is available on Homebrew. Run

```
brew install olets/tap/zsh-abbr
```

and follow the post-install instructions logged to the terminal.

### Plugin

You can install zsh-abbr with a zsh plugin manager. Each has their own way of doing things. See your package manager's documentation or the [zsh plugin manager plugin installation procedures gist](https://gist.github.com/olets/06009589d7887617e061481e22cf5a4a); Fig users can install zsh-abbr from [its page in the Fig plugin directory](https://fig.io/plugins/other/zsh-abbr_olets).

After adding the plugin to the manager, restart zsh:

```shell
exec zsh
```

### Manual

Clone this repo and add `source path/to/zsh-abbr.zsh` to your `.zshrc`. Then restart zsh:

```shell
exec zsh
```

## Usage

```shell
abbr [<SCOPE>] [<TYPE>] <COMMAND> [<ARGS>]
```

Commands which make changes can be passed `--dry-run`.

Commands which have output can be passed `--quiet`.

`<COMMAND> [<ARGS>]` must be last.

### Scopes

A given abbreviation can be limited to the current zsh session (i.e. the current terminal) —these are called *session* abbreviations— or to all terminals —these are called *user* abbreviations. Select commands take **scope** as an argument.

Newly added user abbreviations are available to all open sessions immediately.

Default is user.

### Types

Regular abbreviations match the word at the start of the command line, and global abbreviations match any word on the line. Select commands take **type** as an argument.

Default is regular.

### Commands

zsh-abbr has commands to add, rename, and erase abbreviations; to add abbreviations for every alias or Git alias; to list the available abbreviations with or without their expansions; and to create aliases from abbreviations.

`abbr` with no arguments is shorthand for `abbr list`. `abbr ...` with arguments is shorthand for `abbr add ...`.

- **`add`**

  ```shell
  abbr [(add | -a)] [<SCOPE>] [<TYPE>] [--dry-run] [(--quiet | --quieter)] [--force] ABBREVIATION=EXPANSION
  ```

  Add a new abbreviation.

  To add a session abbreviation, use the **--session** or **-S** scope flag. Otherwise, or if the **--user** or **-U** scope flag is used, the new abbreviation will be available to all sessions.

  To add a global abbreviation, use the **--global** flag. Otherwise the new abbreviation will be a command abbreviation.

  ```shell
  % abbr add gcm='git checkout main'
  % gcm[Space] # expands as git checkout main
  % gcm[Enter] # expands and accepts git checkout main
  ```

  `add` is the default command, and does not need to be explicit:

  ```shell
  % abbr gco='git checkout'
  % gco[Space] # expands as git checkout
  % gco[Enter] # expands and accepts git checkout
  ```

  The ABBREVIATION may be more than one word long.

  ```shell
  % abbr "git cp"="git cherry-pick"
  % git cp[Space] # expands as git cherry-pick
  % abbr g=git
  % g[Space]cp[Space] # expands to git cherry-pick
  ```

  As with aliases, to include whitespace, quotation marks, or other special characters like `;`, `|`, or `&` in the EXPANSION, quote the EXPANSION or `\`-escape the characters as necessary.

  ```shell
  abbr a=b\;c  # allowed
  abbr a="b|c" # allowed
  ```

  User-scope abbreviations can also be manually to the user abbreviations file. See **Storage** below.

  The session regular, session global, user regular, and user global abbreviation sets are independent. If you wanted, you could have more than one abbreviation with the same ABBREVIATION. Order of precedence is "session command > user command > session global > user global".

  Use `--dry-run` to see what would result, without making any actual changes.

  Will error rather than overwrite an existing abbreviation.

  Will warn if the abbreviation would replace an existing command. To add in spite of the warning, use `--force`. To silence the warning, use `--quieter`.

- **`clear-session`**

  ```shell
  abbr (clear-session | c)
  ```

  Erase all session abbreviations.

- **`erase`**

  ```shell
  abbr (erase | e) [<SCOPE>] [<TYPE>] [--dry-run] [--quiet] ABBREVIATION
  ```

  Erase an abbreviation.

  Use the **--session** or **-S** scope flag to erase a session abbreviation. Otherwise, or if the **--user** or **-U** scope flag is used, a cross-session abbreviation will be erased.

  Use the **--global** flag to erase a session abbreviation. Otherwise a cross-session abbreviation will be erased.

  ```shell
  % abbr gcm="git checkout main"
  % gcm[Enter] # expands and accepts git checkout main
  Switched to branch 'main'
  % abbr -e gcm;[Enter] # or abbr -e gcm[Ctrl-Space][Enter]
  % gcm[Space|Enter] # normal
  ```

  User abbreviations can also be manually erased from the `ABBR_USER_ABBREVIATIONS_FILE`. See **Storage** below.

- **`expand`**

  ```shell
  abbr (expand | x) ABBREVIATION
  ```

  Output the ABBREVIATION's EXPANSION.

  ```shell
  % abbr gc="git checkout"
  % abbr -x gc; # or `abbr -x gc[Ctrl-Space][Enter]`
  git checkout
  ```

- **`export-aliases`**

  ```shell
  abbr export-aliases [<SCOPE>] [<TYPE>]
  ```

  Export abbreviations as alias commands. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

  Use the **--session** or **-S** scope flag to export only session abbreviations. Use the **--user** or **-U** scope flag to export only user abbreviations.

  Use the **--global** or **-g** type flag to export only global abbreviations. Use the **--regular** or **-r** type flag to export only regular abbreviations.

  Combine a scope flag and a type flag to further limit the output.

  ```shell
  % abbr gcm="git checkout main"
  % abbr -S g=git
  % abbr export-aliases
  alias gcm='git checkout main'
  % abbr export-aliases --session
  alias g='git'
  ```

- **`import-aliases`**

  ```shell
  abbr import-aliases [<type>] [--dry-run] [--quiet]
  ```

  Add regular abbreviations for every regular alias in the session, and global abbreviations for every global alias in the session.

  ```shell
  % cat ~/.zshrc
  # --snip--
  alias -S d='bin/deploy'
  # --snip--

  % abbr import-aliases
  % d[Space] # expands to bin/deploy
  ```

  Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

  Use `--dry-run` to see what would result, without making any actual changes.

- **`import-fish`**

  ```shell
  abbr import-fish [<SCOPE>] FILE [--dry-run] [--quiet]
  ```

  Import fish abbr-syntax abbreviations (`abbreviation expansion` as compared to zsh abbr's `abbreviation=expansion`).

  In fish:

  ```shell
  abbr -s > file/to/save/fish/abbreviations/to
  ```

  Then in zsh:

  ```shell
  abbr import-fish file/to/save/fish/abbreviations/to
  # file is no longer needed, so feel free to
  # rm file/to/save/fish/abbreviations/to
  ```

  Note that zsh-abbr does not lint the imported abbreviations. An effort is made to correctly wrap the expansion in single or double quotes, but it is possible that importing will add an abbreviation with a quotation mark problem in the expansion. It is up to the user to double check the result before taking further actions.

  Use `--dry-run` to see what would result, without making any actual changes.

- **`import-git-aliases`**

  ```shell
  abbr [--dry-run] [--quiet] import-git-aliases [--file <config-file>]
  ```

  Add two abbreviations for every Git alias available in the current session: a global abbreviation where the WORD is prefixed with `g`, and a command abbreviation. For both the EXPANSION is prefixed with `git[Space]`.

  Use `--file <config-file>` to use a config file instead of the one specified by GIT_CONFIG (see `man git-config`).

  Use the **--session**  or **-S** scope flag to create session abbreviations. Otherwise, or if the **--user** or **-U** scope flag is used, the Git abbreviations will be user.

  ```shell
  % git config alias.co checkout

  # session
  % abbr import-git-aliases -S
  % gco[Space] # git checkout
  % echo gco[Space] # echo git checkout
  % co[Space] # git checkout
  % echo co[Space] # echo co
  % source ~/.zshrc
  % gco[Space] # gco

  # user
  % abbr import-git-aliases
  % gco[Space] # git checkout
  % source ~/.zshrc
  % gco[Space] # git checkout
  ```

  Note for users migrating from Oh-My-Zsh: [OMZ's Git aliases are shell aliases](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh), not aliases in the Git config. To add abbreviations for them, use **import-aliases**.

  Note that zsh-abbr does not lint the imported abbreviations. It is up to the user to double check the result before taking further actions.

  Use `--dry-run` to see what would result, without making any actual changes.

- **`list`**

  ```shell
  abbr [list] [<SCOPE>] [<TYPE>]
  ```

  List the abbreviations with their expansions, like zsh's `alias`. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

  ```shell
  % abbr a=apple
  % abbr -g b=ball
  % abbr -S c=cat
  % abbr -S -g d=dog
  % abbr list
  a="apple"
  b="ball"
  c="cat"
  d="dog"
  % source ~/.zshrc
  % abbr list
  a="apple"
  b="ball"
  ```

  `list` is the default when no additional arguments are passed; it does not need to be made explicit:

  ```shell
  % abbr a=apple
  % abbr
  a="apple"
  ```

- **`list-abbreviations`**

  ```shell
  abbr (list-abbreviations | l) [<SCOPE>] [<TYPE>]
  ```

  List the abbreviations only, like fish's `abbr -l`. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

  ```shell
  % abbr a=apple
  % abbr -g b=ball
  % abbr -S c=cat
  % abbr -S -g d=dog
  % abbr list-abbreviations
  a
  b
  c
  d
  % source ~/.zshrc
  % abbr list-abbreviations
  a
  b
  ```

- **`list-commands`**

  ```shell
  abbr (list-commands | L) [<SCOPE>] [<TYPE>]
  ```

  List as commands suitable for export, like zsh's `alias -L`. Regular abbreviations follow global abbreviations. Session abbreviations follow user abbreviations.

  ```shell
  % abbr a=apple
  % abbr -g b=ball
  % abbr -S c=cat
  % abbr -S -g d=dog
  % abbr list-abbreviations
  abbr a="apple"
  abbr -g b="ball"
  abbr -S c="cat"
  abbr -S -g d="dog"
  % source ~/.zshrc
  % abbr list-abbreviations
  abbr a="apple"
  abbr -g b="ball"
  ```

- **`rename`**

  ```shell
  abbr (rename | R) [<SCOPE>] [<TYPE>] [--dry-run] [(--quiet | --quieter)] OLD NEW
  ```

  Rename an abbreviation.

  Use the **--session** or **-S** scope flag to rename a session abbreviation. Otherwise, or if the **--user** or **-U** scope flag is used, a cross-session abbreviation will be renamed.

  Use the **--global** flag to rename a global abbreviation. Otherwise a command abbreviation will be renamed.

  Rename is scope- and type-specific. If you get a "no matching abbreviation" error, make sure you added the right flags (list abbreviations if you are not sure).

  ```shell
  % abbr add gcm git checkout main
  % gcm[Space] # expands to git checkout main
  % gm[Space] # no expansion
  % abbr rename gcm[Ctrl-Space] gm
  % gcm[Space] # no expansion
  % gm[Space] # expands to git checkout main
  ```

  Use `--dry-run` to see what would result, without making any actual changes.

  Abbreviations can also be manually renamed in the `ABBR_USER_ABBREVIATIONS_FILE`. See **Storage** below.

  Conflicts will error or warn. See **add** for details.

## Advanced

### Configuration variables

In addition to the following, setting `NO_COLOR` (regardless of its value) will disable color output. See https://no-color.org/.

Variable | Type | Use | Default
---|---|---|---
`ABBR_AUTOLOAD` | integer | If non-zero, automatically account for updates to the user abbrevations file (see [Storage and manual editing](#storage-and-manual-editing)) | 1
`ABBR_DEBUG` | integer | If non-zero, print debugging messages | 0
`ABBR_DEFAULT_BINDINGS` | integer | If non-zero, add the default bindings (see [Bindings](#bindings)) | 1
`ABBR_DRY_RUN` | integer | If non-zero, use dry run mode without passing `--dry-run` | 0
`ABBR_FORCE` | integer | If non-zero, use force mode without passing `--force` (see [`add`](#add)) | 0
`ABBR_PRECMD_LOGS` | interger | If non-zero, support precmd logs, for example to warn that a deprecated widget was used | 1
`ABBR_QUIET` | integer | If non-zero, use quiet mode without passing `--quiet` | 0
`ABBR_QUIETER` | integer | If non-zero, use quieter mode without passing `--quieter` | 0
`ABBR_TMPDIR` | String | Path to the directory temporary files are stored in. _Ends in `/`_ | `${${TMPDIR:-/tmp}%/}/zsh-abbr/` *
`ABBR_USER_ABBREVIATIONS_FILE` | String | Path to the file user abbreviation are stored in (see [Storage and manual editing](#storage-and-manual-editing)) | `$XDG_CONFIG_HOME/zsh/abbreviations` if you have `XDG_CONFIG_HOME` defined\*\*, otherwise `$HOME/.config/zsh/abbreviations` \*\*\*

\* If changing this, you may want to delete the default directory.

\*\* Unless you've been using zsh-abbr without a customized `ABBR_USER_ABBREVIATIONS_FILE` since before `XDG_CONFIG_HOME` support was added (v4.8.0). In that case zsh-abbr will use the pre-4.8.0 `$HOME/.config/zsh/abbreviations`.

\*\*\* If changing this, you may want to delete the default file.

### Exported variables

In addition to exporting the configuration variables above, zsh-abbr creates the following variables:

Variable | Type | Value
---|---|---
`ABBR_GLOBAL_SESSION_ABBREVIATIONS` | associative array | The global session abbreviations
`ABBR_GLOBAL_USER_ABBREVIATIONS` | associative array | The global user abbreviations
`ABBR_INITIALIZING` | integer | Set to `1` when zsh-abbr is initializing
`ABBR_LOADING_USER_ABBREVIATIONS` | integer | Set to `1` when the interactive shell is refreshing its list of user abbreviations, otherwise not set
`ABBR_PRECMD_MESSAGE` | prompt string | Message shown by `precmd` hook if `ABBR_PRECMD_LOGS` is non-zero
`ABBR_REGULAR_SESSION_ABBREVIATIONS` | associative array | The regular session abbreviations
`ABBR_SOURCE_PATH` | string | Path to the `zsh-abbr.zsh`
`ABBR_REGULAR_USER_ABBREVIATIONS` | associative array | The regular user abbreviations

Each element in `ABBR_GLOBAL_SESSION_ABBREVIATIONS`, `ABBR_GLOBAL_USER_ABBREVIATIONS`, `ABBR_REGULAR_SESSION_ABBREVIATIONS`, and `ABBR_REGULAR_USER_ABBREVIATIONS` has the form `ABBREVIATION=EXPANSION`.The expansion value is quoted. Scripters will probably want to remove one level of quotes, using the [Q modifier](http://zsh.sourceforge.net/Doc/Release/Expansion.html#Modifiers) (e.g. `for v in ${(Qv)ABBR_REGULAR_USER_ABBREVIATIONS}...`).

### Storage and manual editing

User abbreviations live in a plain text file which you can edit directly, share, keep in version control, etc. Abbreviations in this file are loaded when each new session is opened; non-`abbr` commands will be ignored and then excised from the file.

zsh-abbr automatically keeps the user abbreviations storage file alphabetized, with all global user abbreviations before the first regular user abbreviation.

Every time an `abbr` command is run, the session's updates its user abbreviatons with the latest from the user abbreviations file. This should add no appreciable time, but you prefer it can be turned off by setting `ABBR_AUTOLOAD=0`.

To refresh the user abbreviations from the user abbreviation, run `abbr load` (or any other `abbr` command).

### Bindings

By default

- <kbd>Space</kbd> expands abbreviations
- <kbd>Ctrl</kbd><kbd>Space</kbd> is a normal space
- <kbd>Enter</kbd> expands and accepts abbreviations

(In incremental search mode, <kbd>Space</kbd> is a normal space and <kbd>Ctrl</kbd><kbd>Space</kbd> expands abbreviations.)

There are three available widgets:

Widget | Behavior | Default binding
---|---|---
`abbr-expand` | If following an abbreviation, expands it.<br>Replaces deprecated `_abbr_expand_widget` | Not bound
`abbr-expand-and-accept` | If following an abbreviation, expands it; then accepts the line.<br>Replaces deprecated `_abbr_expand_and_accept` | <kbd>Enter</kbd>
`abbr-expand-and-space` | If following an abbreviation, expands it; then adds a space<br>Replaces deprecated `_abbr_expand_and_space` | <kbd>Space</kbd>

In the following example, additional bindings are added such that <kbd>Ctrl</kbd><kbd>e</kbd> expands abbreviations without adding a trailing space and <kbd>Ctrl</kbd><kbd>a</kbd> has the same behavior as <kbd>Space</kbd>.

```shell
% cat ~/.zshrc
# -- snip --
bindkey "^E" abbr-expand
bindkey "^A" abbr-expand-and-space
# -- snip --
```

To prevent the creation of the default bindings, set `ABBR_DEFAULT_BINDINGS` to `0` before initializing zsh-abbr. In the following example, <kbd>Ctrl</kbd><kbd>Space</kbd> expands abbreviations and <kbd>Space</kbd> is not bound to any zsh-abbr widget.

```shell
% cat ~/.zshrc
# -- snip --
ABBR_DEFAULT_BINDINGS=0
bindkey "^ " abbr-expand-and-space
# -- snip --
# load zsh-abbr
# -- snip --
```

### Highlighting

[fast-syntax-highlighting](https://github.com/zdharma/fast-syntax-highlighting) users see [#24](https://github.com/olets/zsh-abbr/issues/24).

To highlight user abbreviations that will expand, [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) users can add these lines to `.zshrc` *below* where zsh-abbr is loaded.

Replace `<styles for global abbreviations>` with a [zsh character highlighting](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Character-Highlighting) string (start at "The available types of highlighting are the following."). For example `fg=blue`, `fg=blue,bg=red,bold`, etc.

Linux:

```shell
ZSH_HIGHLIGHT_REGEXP+=('^[[:blank:][:space:]]*('${(j:|:)${(k)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' <styles for regular abbreviations>)
ZSH_HIGHLIGHT_REGEXP+=('\<('${(j:|:)${(k)ABBR_GLOBAL_USER_ABBREVIATIONS}}')$' <styles for global abbreviations>)
```

macOS:

```shell
ZSH_HIGHLIGHT_REGEXP=('^[[:blank:][:space:]]*('${(j:|:)${(k)ABBR_REGULAR_USER_ABBREVIATIONS}}')$' <styles for regular abbreviations>)
ZSH_HIGHLIGHT_REGEXP+=('[[:<:]]('${(j:|:)${(k)ABBR_GLOBAL_USER_ABBREVIATIONS}}')$' <styles for global abbreviations>)
```

### vi mode compatibility

Switching to vi mode —with plain old `bindkey -v` or with plugin vi/Vim mode plugin that calls `bindkey -v` — will wipe out the keybindings zsh-abbr's interactive behavior relies on. If you use vi mode, enable it before initializing zsh-abbr. For example, the simplest `.zshrc` for a zinit user would be

```shell
bindkey -v
zinit light olets/zsh-abbr
```

## macOS System Text Substitutions

The following snippet will make your global macOS text substitutions available in the shell.

```shell
for substitution in ${(f)"$(defaults read ~/Library/Preferences/.GlobalPreferences.plist NSUserDictionaryReplacementItems | plutil -convert json -o - - | jq -r 'to_entries[] | "\(.value.replace)=\(.value.with)"')"}; do
  abbr add [options] "$substitution"
done
```
## Performance

zsh-abbr will not affect time between prompts. The following is the impact of zsh-abbr on time to start a new session, profiled with `zprof` and `zinit light olets/zsh-abbr`.

Machine | Initialization overhead | Time per user abbreviation
---|---|---
macOS 10.15 on early-2015 MacBook Pro (2.9 GHz Intel Core i5, 16 GB), zsh 5.8, zinit 3.1, iTerm2 3.3.12 | Approx. 120ms | Approx. 1ms
macOS 11.2.1 on 2020 MacBook Pro (M1, 16 GB), zsh 5.8, zinit 3.7, iTerm 3.4.4 | Approx. 40ms | Under 1ms


## Uninstalling

Delete the session data storage directory

```shell
% rm -rf $ABBR_TMPDIR
```

If you want to delete the user abbreviations file,

```shell
% rm $ABBR_USER_ABBREVIATIONS_FILE
```

If you haven't customized `$ABBR_USER_ABBREVIATIONS_FILE`, you will probably want to delete its parent directory

```shell
# see if there's anything in there
% ls $ABBR_USER_ABBREVIATIONS_FILE:h
# IF you want to delete it
% rm -rf $ABBR_USER_ABBREVIATIONS_FILE:h
```

Then follow the standard uninstallation procedure for your installation method. This is typically the reverse of what you did to install.

## Changelog

See the [CHANGELOG](CHANGELOG.md) file.

## Roadmap

See the [ROADMAP](ROADMAP.md) file.

## Contributing

Thanks for your interest. Contributions are welcome!

> Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Check the [Issues](https://github.com/olets/zsh-abbr/issues) to see if your topic has been discussed before or if it is being worked on. You may also want to check the roadmap (see above).

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

The test suite uses [zsh-test-runner](https://github.com/olets/zsh-test-runner). Run with test suite with `. ./tests/abbr.ztr`.

## License

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:cc="http://creativecommons.org/ns#" class="license-text"><a rel="cc:attributionURL" property="dct:title" href="https://www.github.com/olets/zsh-abbr">zsh-abbr</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://www.github.com/olets">Henry Bley-Vroman</a> is licensed under <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0">CC BY-NC-SA 4.0</a> with a human rights condition from <a href="https://firstdonoharm.dev/version/2/1/license.html">Hippocratic License 2.1</a>. Persons interested in using or adapting this work for commercial purposes should contact the author.</p>

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" title="Creative Commons-licensed" /><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" title="Creative Commons: Attribution" /><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" title="Creative Commons: NonCommercial"/><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" title="Creative Commons: ShareAlike" />

For the full text of the license, see the [LICENSE](LICENSE) file.
