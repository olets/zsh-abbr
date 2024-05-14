# Tests

Requires [zsh-test-runner](https://github.com/olets/zsh-test-runner) v2.x.

To run the test suite in the current shell,

```shell
. tests/index.ztr.zsh
```

To run a single command's tests in the current shell,

```shell
. tests/index.ztr.zsh <command> # e.g. `. tests/index.ztr.zsh add`
```

To run the test suite in a subshell,

```shell
ztr_path=$ZTR_PATH zsh tests/index.ztr.zsh && abbr load
```

To run a single command's tests in a subshell,

```shell
ztr_path=$ZTR_PATH zsh tests/index.ztr.zsh <command> && abbr load
# e.g. `ztr_path=$ZTR_PATH zsh tests/index.ztr.zsh add && abbr load`
```
