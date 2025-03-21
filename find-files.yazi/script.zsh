#!/usr/bin/zsh

command fd -tf --color=always "$@" |
  fzf \
    --multi \
    --ansi \
    --style=full \
    --scheme=path \
    --height=30% \
    --min-height=15 \
    --expect=enter,alt-enter \
    --preview='bat --color=always --number {}' \
    --bind='focus:transform-preview-label:((FZF_POS)) && echo \ {}\ '
