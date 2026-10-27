# Homebrew Tap

Personal Homebrew tap for [@agh](https://github.com/agh).

## Usage

```bash
brew tap agh/tap
brew install agh/tap/cwtch
brew install --cask agh/tap/insta360-wave-controller
```

This is an unofficial third-party tap. Formulae and casks are executable Ruby, so
Homebrew asks you to trust the tap before loading it: installing by fully qualified
name trusts only that package, while `brew trust agh/tap` trusts the whole tap,
including anything added later. Some casks run vendor installers with administrator
privileges; the table says which.

Self-updating apps keep themselves current, so `brew upgrade` skips them unless you
pass `--greedy`.

## Formulae

| Formula | Description |
|---------|-------------|
| `cwtch` | Manage Claude Code profiles and synchronize configuration from Git ([agh/cwtch](https://github.com/agh/cwtch)) |

## Casks

| Cask | Description |
|------|-------------|
| `insta360-wave-controller` | Insta360's desktop app for its Wave speakerphones; runs Insta360's installer and updates itself ([insta360.com](https://www.insta360.com/download/insta360-wave)) |
| `lg-switch` | LG's monitor controls and screen layouts. LG's installer also adds fonts, helpers in `/usr/local/switch`, a launch agent and a login item, which the cask's uninstall removes ([lg.com](https://www.lg.com/us/support/monitors)) |

Work Louder's Input configurator, formerly `input` here, is in Homebrew as
`work-louder-input`.

## Maintenance

Every pull request runs `brew style`, `brew readall`, `brew audit --strict --online`
and livecheck, installs and tests each formula, and installs then zaps each cask,
failing if anything the cask declares survives. A daily job fails when a package is
outdated; bump it with `brew bump --tap=agh/tap --open-pr`. Renovate updates the
formulae and the pinned GitHub Actions.

## License

[MIT](LICENSE), covering the definitions in this repository; packaged software keeps
its own license.
