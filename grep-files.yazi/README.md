<!--toc:start-->

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
<!--toc:end-->

This is the English version of the README. For Chinese, please see [中文](README_zh.md).

This is a plugin that uses a zsh script to run the rg + fzf command for text searching.

## Features

- Vertical layout similar to Telescope: preview/input/list

- Input format: <rg-pattern> [fzf-pattern ...] [-- [rg-arg ...]]

- During execution, the rg-pattern is placed before rg-args. If positional arguments (non-option arguments) are passed, they are treated as search paths.

  For example: local -- -tlua search_directory -> rg local -tlua search_directory

- Supports multi-selection

- Enter: Opens the selected file(s) with the EDITOR

- Alt+Enter: Sets the floating cursor in yazi to the first file

## Requirements

- rg (ripgrep)

- fzf 0.60.3

- yazi 25.2.26

## Installation

```sh
ya pack -a MaJinjie/yazi-plugins:grep-files
```

## Usage

Add this to your ~/.config/yazi/keymap.toml:

```toml
[manager]
prepend_keymap = [
  { on = ["<Space>", "s"], run = "plugin grep-files", desc = "Grep Files" },
  # Due to an issue with yazi, parameter passing may not work correctly
  { on = ["<Space>", "S"], run = "plugin grep-files -- --interactive", desc = "Grep Files" },
  # Another way to correctly pass arguments is: plugin grep-files -- [rg-arg ..]
  # If mixed, the latter will be appended to the former
]
```
