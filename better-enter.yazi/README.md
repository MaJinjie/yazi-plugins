A customizable enter plugin.

## Installation

```sh
ya pack -a MaJinjie/plugins:better-enter
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = "l"
run = "plugin better-enter"
desc = "better enter"
```
