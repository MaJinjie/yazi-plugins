#!/usr/bin/zsh

export TEMP
export -UT RG_ARGS rg_args 

TEMP=$(mktemp -u)
trap 'rm -rf $TEMP' EXIT

rg_args=( "--column" "--line-number" "--no-heading" "--color=always" "--smart-case" ${(Q)${(z)1}} )

TRANSFORMER='
  local left right
  local rg_pat fzf_pat
  local -UT RG_ARGS rg_args

  if [[ $FZF_QUERY =~ ^(.*)\ --\ (.*)$ ]]; then
    left=$match[1]
    right=$match[2]
  else
    left=$FZF_QUERY
  fi

  if [[ $left =~ ([^[:space:]]+)(.*) ]]; then
    rg_pat=$match[1]
    fzf_pat=$match[2]
  fi

  if [[ -n $right ]]; then
    rg_args+=( ${(z)right} )
  fi

  if ! [[ -r $TEMP && "$rg_pat $RG_ARGS" == $(<$TEMP) ]]; then
    echo "$rg_pat $RG_ARGS" > $TEMP
    printf "reload:sleep 0.1; command rg %q %s || true" "$rg_pat" "$rg_args"
  fi
  echo "+search:$fzf_pat"
'

:|fzf \
  --disabled \
  --delimiter ':' \
  --multi \
  --ansi \
  --style=full \
  --height=100% \
  --expect=enter,alt-enter \
  --with-nth '{1..3} {4..}' \
  --accept-nth '{1..3}' \
  --preview='bat --color=always --number --highlight-line {2} -- {1}' \
  --preview-window='up,35%,+{2}/2' \
  --bind='focus:transform-preview-label:((FZF_POS)) && echo \ {1}\ ' \
  --bind="change:transform:$TRANSFORMER" \
  ${(Q)${(z)2}}

# echo "\n====================" >> debug.log
# echo query:$FZF_QUERY >> debug.log
# echo left:$left >> debug.log
# echo right:$right >> debug.log
# echo rg_pat:$rg_pat >> debug.log
# echo fzf_pat:$fzf_pat >> debug.log
# echo rg_args:$#rg_args:$rg_args >> debug.log
