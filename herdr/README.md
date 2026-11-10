# herdr

megan's [herdr](https://herdr.dev) config. lucy's lives in
[jds_config_omarchy/herdr](https://github.com/jsheffie/jds_config_omarchy/tree/master/herdr).

## Keymap

Both machines use herdr's built-in default bindings with one change:
`prefix = "ctrl+space"`. The only other bindings are `prefix+f` and
`prefix+shift+f`, which open the herdr-file-viewer plugin. `herdr --default-config`
prints every default (`copy_mode = "prefix+["` is a default too, though that
listing leaves it out).

`herdr --remote lucy` uses **this** file's keybindings, not lucy's, because
remote attach defaults to `--remote-keybindings local`. With identical `[keys]`
blocks, the same keys do the same thing on lucy's own keyboard and from megan.
If you change one, change the other.

The theme and notification settings are megan-only.

## Install

```sh
make -C herdr install   # validates with `herdr config check`, shows the diff, asks, backs up
make -C herdr plugins   # installs herdr-file-viewer at the pinned commit (idempotent)
```

Then reload. **No restart needed**, and panes and agents keep running:

```sh
herdr server reload-config                     # default session
herdr --session personal server reload-config  # each other running session
```

Or press the reload binding inside herdr: `<prefix> shift+r`. In a
`herdr --remote lucy` window, that in-UI reload is what refreshes this file's
keybindings, plus lucy's server config.

## Archive

`archive/2026-11-09-megan.config.toml` is the config from before the sync
(`ctrl+b` prefix). lucy's old tmux-style config and both versions'
`herdr --default-config` output are in jds_config_omarchy's `herdr/archive/`.
Background: #7.
