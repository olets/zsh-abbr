# Releasing

The process for cutting new releases.

1. Checkout `main`
1. Run
    ```shell
    conventional-changelog -p angular -i CHANGELOG.md -s
    ```
    Requires [conventional-changelog-cli](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages/conventional-changelog-cli)
1. Update `./man/man1/abbr.1`: bump date and version at top.
1. Update `./zsh-abbr.zsh`: bump version at top, and date and version in `_abbr()`
1. Commit with message (replacing `<VERSION>` with the version)
    ```
    chore(bump): bump to v<VERSION>, update changelog
    ```
1. Tag the release. Run (replacing `<TAG>` with the tag, `v`-prefixed semver)
    ```shell
    git tag <TAG>
    ```
1. Update overall trunk branches. Run
    ```shell
    git push
    git merge main
    git push
    ```
1. Update the appropriate version trunk branch. Run for example (before the v5 release)
    ```shell
    git checkout v4
    git merge main
    git push
    ```
1. If appropriate, update other version trunks.
    - If the change is made in v4, run
        ```shell
        git checkout v5
        git merge --no-ff v4
        git checkout --ours .
        git checkout v4 -- <relevant files>
        # manually copy over v4 CHANGELOG change into v5, marking it as "From v4.…"
        git commit
        git push
        ```
1. Push the tag. Run (replacing `<TAG>` with the tag)
    ```shell
    git push origin <TAG>
    ```
1. On GitHub cut a new release at the tag. Use the form of existing release notes, replacing the version number, SHA, and CHANGELOG URL. The appropriate formula will automatically update.
1. If the change is to a prerelease, update the Homebrew formula's HEAD branch. Run
    ```shell
    git checkout next
    git merge <VERSION TRUNK BRANCH> # e.g. git merge v5
    ```
