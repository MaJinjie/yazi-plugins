<!--toc:start-->

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
<!--toc:end-->

这是一个使用zsh脚本，运行rg + fzf命令查找文本的一个插件。

## Features

- 类似与telescope的垂直布局 preview/input/list
- 输入格式为：`<rg-pattern> [fzf-pattern ...] [-- [rg-arg ...]]`

  在执行时，我将`rg-pattern` 放到了`rg-args` 前，如果传入位置参数（非选项参数）则视为搜索路径。
  例如：`local -- -tlua search_directory` -> `rg local -tlua search_directory`

- 支持多选

- enter: 使用`EDITOR` 打开
- alt-enter: 设置yazi的悬浮光标为第一个文件

## Requirements

- rg
- fzf 0.60.3
- yazi 25.2.26

## Installation

```sh
ya pack -a MaJinjie/yazi-plugins:grep-files
```

## Usage

添加到你的 `~/.config/yazi/keymap.toml`:

```toml
[manager]
prepend_keymap = [
  { on = ["<Space>", "s"], run = "plugin grep-files", desc = "Grep Files" },
  # 由于yazi的问题，该参数的传递未必正确
  { on = ["<Space>", "S"], run = "plugin grep-files -- --interactive", desc = "Grep Files" },
  # 另一种正确传递参数的方式是 plugin grep-files -- [rg-arg ..]
  # 若混合使用，后者会被追加在前者后面
]
```
