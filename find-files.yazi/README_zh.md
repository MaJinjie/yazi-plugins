<!--toc:start-->

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
<!--toc:end-->

这是一个使用zsh脚本，运行fd + fzf命令查找文本的一个插件。

## Features

- 类似与telescope的水平布局 input/list|preview
- 支持多选
- enter: 使用`EDITOR` 打开
- alt-enter: 设置yazi的悬浮光标为第一个文件

## Requirements

- rg
- fzf 0.60.3
- yazi 25.2.26

## Installation

```sh
ya pack -a MaJinjie/yazi-plugins:find-files
```

## Usage

添加到 `~/.config/yazi/keymap.toml`:

```toml
[manager]
prepend_keymap = [
  { on = ["<Space>", "f"], run = "plugin find-files", desc = "Find Files" },
  # 由于yazi的问题，该参数的传递未必正确
  { on = ["<Space>", "F"], run = "plugin find-files -- --interactive", desc = "Find Files" },
  # 另一种正确传递参数的方式是 plugin find-files -- [fd-arg ..]
]
```
