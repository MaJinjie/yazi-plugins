<!--toc:start-->

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
<!--toc:end-->

This is the English version of the README. For Chinese, please see [中文](README_zh.md).

This is a plugin that uses a zsh script to run the fd + fzf command for text searching.

## Features

- Horizontal layout similar to Telescope: preview/input/list

- Supports multi-selection

- Enter: Opens the selected file(s) with the EDITOR

- Alt+Enter: Sets the floating cursor in yazi to the first file

## Requirements

- fd

- fzf 0.60.3

- yazi 25.2.26

## Installation

```sh
ya pack -a MaJinjie/yazi-plugins:find-files
```

## Usage

Add this to your ~/.config/yazi/keymap.toml:

```toml
[manager]
prepend_keymap = [
  { on = ["<Space>", "f"], run = "plugin find-files", desc = "Find Files" },
  # Due to an issue with yazi, parameter passing may not work correctly
  { on = ["<Space>", "F"], run = "plugin find-files -- --interactive", desc = "Find Files" },
  # Another way to correctly pass arguments is: plugin find-files -- [fd-arg ..]
]
```
