# zsh-abbr ![GitHub release (latest by date)](https://img.shields.io/github/v/release/olets/zsh-abbr)

**zsh-abbr** is the zsh manager for **auto-expanding abbreviations** - text that when written in a terminal is replaced with other (typically longer) text. Inspired by fish shell.

For example, abbreviate `git checkout` as `co` (or even `c` or anything else). Type `co`<kbd>Space</kbd> and the `co` **turns into** `git checkout`. Abbreviate `git checkout main` as `cm`. Type `cm`<kbd>Enter</kbd> and the `cm` **turns into and runs** `git checkout main`. Don't want an abbreviation to expand? Use <kbd>Ctrl</kbd><kbd>Space</kbd> instead of <kbd>Space</kbd>, and `;`<kbd>Enter</kbd> instead of <kbd>Enter</kbd>.

Why? Like aliases, abbreviations **save keystrokes**. Unlike aliases, abbreviations can leave you with a **transparently understandable command history** ready for using on a different computer or sharing with a colleague. And where aliases can let you forget the full command, abbreviations may **help you learn** the full command even as you type the shortened version.

Like **zsh's `alias`**, zsh-abbr supports **"regular"** (i.e. command-position) and **"global"** (anywhere on the line) abbreviations. Like **fish's `abbr`**, zsh-abbr supports **interactive creation** of persistent abbreviations which are immediately available in all terminal sessions. Abbreviations automatically **sync to a file**, ready for your dotfile management.

Run `abbr help` for documentation; if the package is installed with Homebrew, `man abbr` is also available.

## Documentation

📖 See the guide at https://zsh-abbr.olets.dev/

v5 is a major release. It makes changes that will require some users to update their configurations. Details are in the [migration guide](https://zsh-abbr.olets.dev/migrating-between-versions).

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

The test suite uses [zsh-test-runner](https://github.com/olets/zsh-test-runner) v2.x. See [tests/README.md](tests/README.md) for instructions on running the test suite.

### Sponsoring

Love zsh-abbr? I'm happy to be able to provide it for free. If you are moved to turn appreciation into action, I invite you to make a donation to one of the organizations listed below (to be listed as a financial contributor, send me a receipt via email or [Reddit DM](https://www.reddit.com/user/olets)). Thank you!

- [O‘ahu Water Protectors](https://oahuwaterprotectors.org/) a coalition of organizers and concerned community members fighting for safe, clean water on Oʻahu. Currently focused on the Red Hill Bulk Fuel Storage Facility crisis (see Sierra Club of Hawaii's [explainer](https://sierraclubhawaii.org/redhill)).
- [Hoʻoulu ʻĀina](https://hoouluaina.org/) is a 100-acre nature preserve nestled in the back of Kali hi valley on the island of Oʻahu which seeks to provide people of our ahupuaʻa and beyond the freedom to make connections and build meaningful relationships with the ʻāina, each other and ourselves.
- [Ol Pejeta Conservancy](https://www.olpejetaconservancy.org/) are caretakers of the land, safeguarding endangered species and ensuring the openness and accessibility of conservation for all. They empower their people to think the same way and embrace new approaches to conservation, and provide natural wilderness experiences, backed up by scientifically credible conservation and genuine interactions with wildlife.
- [Southern Utah Wilderness Alliance (SUWA)](https://suwa.org/) the only non-partisan, non-profit organization working full time to defend Utah’s redrock wilderness from oil and gas development, unnecessary road construction, rampant off-road vehicle use, and other threats to Utah’s wilderness-quality lands.

## Community

This project uses all-contributors to recognize its community. The key to the emojis is on the [all-contributors website](https://allcontributors.org/docs/en/emoji-key).

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/knu"><img src="https://avatars.githubusercontent.com/u/10236?v=4?s=100" width="100px;" alt="Akinori MUSHA"/><br /><sub><b>Akinori MUSHA</b></sub></a><br /><a href="#code-knu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://researchgate.net/profile/Alwin_Wang"><img src="https://avatars.githubusercontent.com/u/16846521?v=4?s=100" width="100px;" alt="Alwin Wang"/><br /><sub><b>Alwin Wang</b></sub></a><br /><a href="#code-alwinw" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://berninghoff.eu"><img src="https://avatars.githubusercontent.com/u/7356251?v=4?s=100" width="100px;" alt="Daniel Berninghoff"/><br /><sub><b>Daniel Berninghoff</b></sub></a><br /><a href="#code-burneyy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://olets.dev"><img src="https://avatars.githubusercontent.com/u/3282350?v=4?s=100" width="100px;" alt="Henry Bley-Vroman"/><br /><sub><b>Henry Bley-Vroman</b></sub></a><br /><a href="#doc-olets" title="Documentation">📖</a> <a href="#design-olets" title="Design">🎨</a> <a href="#question-olets" title="Answering Questions">💬</a> <a href="#tool-olets" title="Tools">🔧</a> <a href="#example-olets" title="Examples">💡</a> <a href="#ideas-olets" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-olets" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#test-olets" title="Tests">⚠️</a> <a href="#maintenance-olets" title="Maintenance">🚧</a> <a href="#review-olets" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/henrebotha"><img src="https://avatars.githubusercontent.com/u/5593874?v=4?s=100" width="100px;" alt="Henré Botha"/><br /><sub><b>Henré Botha</b></sub></a><br /><a href="#code-henrebotha" title="Code">💻</a> <a href="#ideas-henrebotha" title="Ideas, Planning, & Feedback">🤔</a> <a href="#financial-henrebotha" title="Financial">💵</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://lucaslarson.net"><img src="https://avatars.githubusercontent.com/u/91468?v=4?s=100" width="100px;" alt="Lucas Larson"/><br /><sub><b>Lucas Larson</b></sub></a><br /><a href="#bug-LucasLarson" title="Bug reports">🐛</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.stefanhojer.de/"><img src="https://avatars.githubusercontent.com/u/436889?v=4?s=100" width="100px;" alt="Stefan Hojer"/><br /><sub><b>Stefan Hojer</b></sub></a><br /><a href="#code-hojerst" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

<a href="https://www.github.com/olets/zsh-abbr">zsh-abbr</a> by <a href="https://www.github.com/olets">Henry Bley-Vroman</a> is licensed under a license which is the unmodified text of <a href="https://creativecommons.org/licenses/by-nc-sa/4.0">CC BY-NC-SA 4.0</a> and the unmodified text of a <a href="https://firstdonoharm.dev/build?modules=eco,extr,media,mil,sv,usta">Hippocratic License 3</a>. It is not affiliated with Creative Commons or the Organization for Ethical Source.

Human-readable summary of (and not a substitute for) the [LICENSE](LICENSE) file:

You are free to

- Share — copy and redistribute the material in any medium or format
- Adapt — remix, transform, and build upon the material

Under the following terms

- Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- Non-commercial — You may not use the material for commercial purposes.
- Ethics - You must abide by the ethical standards specified in the Hippocratic License 3 with Ecocide, Extractive Industries, US Tariff Act, Mass Surveillance, Military Activities, and Media modules.
- Preserve terms — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
- No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.

## Acknowledgments

- The human-readable license summary is based on https://creativecommons.org/licenses/by-nc-sa/4.0. The ethics point was added.