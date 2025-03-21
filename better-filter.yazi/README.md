A More Powerful Yazi File Filter Plugin.

## Features

- Continuous filtering
- Use `/` to trigger and enter the first priority directory (search downward from the cursor first, then from the top to the cursor)
- Highlight matching text
- Automatically toggle hidden files + automatically restore configuration after filtering ends

## Installation

```sh
ya pack -a MaJinjie/plugins:better-filter
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = "f"
run = "plugin better-filter"
desc = "better filter"
```
