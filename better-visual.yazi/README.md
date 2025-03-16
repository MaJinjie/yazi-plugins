This is a Yazi plugin that implements a visual mode switch similar to Vim.

## Installation

```sh
ya pack -a MaJinjie/yazi-plugins:better-visual
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[manager]
prepend_keymap = [
  { on = "<Esc>", run = "plugin better-visual escape", desc = "Exit visual mode, clear selected, or cancel search" },
  { on = "v", run = "plugin better-visual select", desc = "Enter visual mode (selection mode)" },
  { on = "V", run = "plugin better-visual unset", desc = "Enter visual mode (unset mode)" },
]
```
