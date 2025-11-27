# Contributing

Thanks for your interest. Contributions are welcome!

> Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Check the [Issues](https://github.com/olets/zsh-abbr/issues) to see if your topic has been discussed before or if it is being worked on. You may also want to check the roadmap (see above). Discussing in an Issue before opening a Pull Request means future contributors only have to search in one place.

This project includes a Git [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules). Passing `--recurse-submodules` when `git clone`ing is recommended.

This project loosely follows the [Angular commit message guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md). This helps with searchability and with the changelog, which is generated automatically and touched up by hand only if necessary. Use the commit message format `<type>(<scope>): <subject>`, where `<type>` is **feat** for new or changed behavior, **fix** for fixes, **docs** for documentation, **style** for under the hood changes related to for example zshisms, **refactor** for other refactors, **test** for tests, or **chore** chore for general maintenance (this will be used primarily by maintainers not contributors, for example for version bumps), etc. `<scope>` is more loosely defined. Look at the [commit history](https://github.com/olets/zsh-abbr/commits/master) for ideas.

The test suite uses [zsh-test-runner](https://github.com/olets/zsh-test-runner). Run with test suite with

```shell
. ./tests/abbr.ztr
```

## Maintainers

To cut a new release:

1. Check out the `main` branch.
1. Update all instances of the version number in [`zsh-abbr.zsh`](zsh-abbr.zsh).
1. Update all instances of the release date in [`zsh-abbr.zsh`](zsh-abbr.zsh).
1. Update all instances of the version number in [`man/man1/abbr.1`](man/man1/abbr.1).
1. Update all instances of the release date in [`man/man1/abbr.1`](man/man1/abbr.1).
1. Update all instances of the version number in [`completions/_abbr`](completions/_abbr).
1. Run `bin/changelog`.
1. Update the first line of [`CHANGELOG.md`](CHANGELOG.md): add the new version number twice:
    ```
    # [<HERE>](…vPrevious...v<AND HERE>) (…)
    ```
1. Commit `CHANGELOG.md`, `zsh-abbr.zsh`, `man/man1/abbr.1`, and `completions/_abbr`.
    ```shell
    git commit -i CHANGELOG.md completions/_abbr man/man1/abbr.1 zsh-abbr.zsh -m "feat(release): bump to v%ABBR_CURSOR%, update changelog"
    ```
1. Create a signed commit with the version number, prefixed with `v`.
    ```shell
    git tag -s v%ABBR_CURSOR% -m v%ABBR_CURSOR%
    ```
1. If possible to fast-forward `next` to `main`, do so. If it isn't, rebase/merge/etc as needed to have `next` fork off the tip of `main`.
1. Fast-forward the major-version branch (e.g. branch `v5`) to `main`.
1. Push `main`, the tag, `next`, the major version branch, and any branches rewritten in the process of bringing `next` up to `main`.
1. Create an archive at the tag:
    ```shell
    git archive --prefix=%ABBR_CURSOR%/ -o %ABBR_CURSOR%.tar.gz %ABBR_CURSOR% # replace cursor with `v`-prefixed tag name
    ```
1. Get the archive's SHA. On macOS as of this writing you can
    ```shell
    openssl sha256 %ABBR_CURSOR%.tar.gz
    ```
1. In GitHub, publish a new release at https://github.com/olets/zsh-abbr/releases/new
  1. Copy the previous release's release notes.
  1. Update the CHANGELOG link URL.
  1. Update the version.
  1. Update the archive SHA.
  1. Attach the `tar.gz` archive.
  1. A GitHub Actions workflow will automatically update the Homebrew formula.
