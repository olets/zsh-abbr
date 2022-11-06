## zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr) ![All Contributors badge](https://img.shields.io/github/all-contributors/olets/all-contributors-test?color=3b3999)

**abbr** is the zsh manager for **auto-expanding abbreviations** - text that when written in a terminal is replaced with other (typically longer) text. Inspired by fish shell.

For example, abbreviate `git checkout` as `co` (or even `c` or anything else). Type `co`<kbd>Space</kbd> and the `co` **turns into** `git checkout`. Abbreviate `git checkout main` as `cm`. Type `cm`<kbd>Enter</kbd> and the `cm` **turns into and runs** `git checkout main`. Don't want an abbreviation to expand? Use <kbd>Ctrl</kbd><kbd>Space</kbd> instead of <kbd>Space</kbd>, and `;`<kbd>Enter</kbd> instead of <kbd>Enter</kbd>.

Why? Like aliases, abbreviations **save keystrokes**. Unlike aliases, abbreviations can leave you with a **transparently understandable command history** ready for using on a different computer or sharing with a colleague. And where aliases can let you forget the full command, abbreviations may **help you learn** the full command even as you type the shortened version.

Like **zsh's `alias`**, zsh-abbr supports **"regular"** (i.e. command-position) and **"global"** (anywhere on the line) abbreviations. Like **fish's `abbr`**, zsh-abbr supports **interactive creation** of persistent abbreviations which are immediately available in all terminal sessions. Abbreviations automatically **sync to a file**, ready for your dotfile management.

Run `abbr help` for documentation; if the package is installed with Homebrew, `man abbr` is also available.

## Documentation

📖 See the guide at https://zsh-abbr.olets.dev/

## Changelog

See the [CHANGELOG](CHANGELOG.md) file.

## Roadmap

See the [ROADMAP](ROADMAP.md) file.

## Contributing

_Looking for the documentation site's source? See <https://github.com/olets/zsh-abbr-docs>

Thanks for your interest. Contributions are welcome!

> Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Check the [Issues](https://github.com/olets/zsh-abbr/issues) to see if your topic has been discussed before or if it is being worked on. You may also want to check the roadmap (see above).

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

The test suite uses [zsh-test-runner](https://github.com/olets/zsh-test-runner). Run with test suite with `. ./tests/abbr.ztr`.

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:cc="http://creativecommons.org/ns#" class="license-text"><a rel="cc:attributionURL" property="dct:title" href="https://www.github.com/olets/zsh-abbr">zsh-abbr</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://www.github.com/olets">Henry Bley-Vroman</a> is licensed under <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0">CC BY-NC-SA 4.0</a> plus <a href="https://firstdonoharm.dev/version/2/1/license.html">Hippocratic License 3</a>. Persons interested in using or adapting this work for commercial purposes should contact the author.</p>

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" title="Creative Commons-licensed" /> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" title="Creative Commons: Attribution" /> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" title="Creative Commons: NonCommercial"/> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" title="Creative Commons: ShareAlike" />

For the full text of the license, see the [LICENSE](LICENSE) file.
