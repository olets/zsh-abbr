## zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr) ![All Contributors badge](https://img.shields.io/github/all-contributors/olets/zsh-abbr?color=3b3999)

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

_Looking for the documentation site's source? See <https://github.com/olets/zsh-abbr-docs>_

Thanks for your interest. Contributions are welcome!

> Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Check the [Issues](https://github.com/olets/zsh-abbr/issues) to see if your topic has been discussed before or if it is being worked on. You may also want to check the roadmap (see above).

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

The test suite uses [zsh-test-runner](https://github.com/olets/zsh-test-runner). Run with test suite with `. ./tests/abbr.ztr`.

### Sponsoring

Love zsh-abbr? I'm happy to be able to provide it for free. If you are moved to turn appreciatation into action, I invite you to make a donation to one of the organizations listed below (to be listed as a financial contributor, send me a reciept via email or [Reddit DM](https://www.reddit.com/user/olets)). Thank you!

- [O‘ahu Water Protectors](https://oahuwaterprotectors.org/) a coalition of organizers and concerned community members fighting for safe, clean water on Oʻahu. Currently focused on the Red Hill Bulk Fuel Storage Facility crisis (see Siera Club of Hawaii's [explainer](https://sierraclubhawaii.org/redhill)).
- [Hoʻoulu ʻĀina](https://hoouluaina.org/) is a 100-acre nature preserve nestled in the back of Kalihi valley on the island of Oʻahu which seeks to provide people of our ahupuaʻa and beyond the freedom to make connections and build meaningful relationships with the ʻāina, each other and ourselves.
- [Ol Pejeta Conservancy]() are caretakers of the land, safeguarding endangered species and ensuring the openness and accessibility of conservation for all. They empower their people to think the same way and embrace new approaches to conservation, and  provide natural wilderness experiences, backed up by scientifically credible conservation and genuine interactions with wildlife.
- [Southern Utah Wilderness Alliance (SUWA)](https://suwa.org/) the only non-partisan, non-profit organization working full time to defend Utah’s redrock wilderness from oil and gas development, unnecessary road construction, rampant off-road vehicle use, and other threats to Utah’s wilderness-quality lands.

## Contributors

This project uses [all-contributors](https://allcontributors.org). See its [emoji key](https://allcontributors.org/docs/en/emoji-key).

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

<p xmlns:dct="http://purl.org/dc/terms/" xmlns:cc="http://creativecommons.org/ns#" class="license-text"><a rel="cc:attributionURL" property="dct:title" href="https://www.github.com/olets/zsh-abbr">zsh-abbr</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="https://www.github.com/olets">Henry Bley-Vroman</a> is licensed under <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0">CC BY-NC-SA 4.0</a> plus <a rel="license" href="https://firstdonoharm.dev">Hippocratic License 3</a> and stipulations inspired by the <a rel="license" href="https://skysedge.com/opensource/index.html">Sky's Edge Open Source License</a>. Persons interested in using or adapting this work for commercial purposes should contact the author.</p>

Lay summary: The license requires that reusers give credit to the creator. It allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, for noncommercial purposes only. If others modify or adapt the material, they must license the modified material under identical terms.  The license prohibits the use of software to violate human rights. The license requires that derivative products differ substantially different from what they build off of. The license requires that derivative products be released under names which cannot be mistaken for the work they derive from. (If the lay summary is at odds with the full license, the full license is considered the source of truth.)

For more information on ethical licenses, see the [Organization for Ethical Source](https://ethicalsource.dev).

<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" title="Creative Commons-licensed" /> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" title="Creative Commons: Attribution" /> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" title="Creative Commons: NonCommercial"/> <img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" title="Creative Commons: ShareAlike" />

For the full text of the license, see the [LICENSE](LICENSE) file.
