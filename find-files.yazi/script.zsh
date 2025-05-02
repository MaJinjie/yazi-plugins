#!/usr/bin/zsh

command fd --color=always ${(Q)${(z)1}} |
  fzf \
    --multi \
    --ansi \
    --style=full \
    --scheme=path \
    --height=30% \
    --min-height=15 \
    --expect=enter,alt-enter \
    --preview='
      r={}; r=${~r}; \
      ([ -f $r ] && bat --color=always --number $r) || 
      ([ -d $r ] && ls $r | less) || 
      (echo $r 2> /dev/null | head -200)
    ' \
    --bind='focus:transform-preview-label:((FZF_POS)) && echo \ {}\ ' ${(Q)${(z)2}}
