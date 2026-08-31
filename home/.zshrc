export ZSH="$HOME/.oh-my-zsh"
export UTILSCRIPTS_DIR="$HOME/.local/scripts"
DISABLE_MAGIC_FUNCTIONS="true"
plugins=(git)

source $ZSH/oh-my-zsh.sh
export PATH="$PATH:/home/ogg/.local/bin"
export PATH="$PATH:/home/ogg/.cargo/bin"

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

setopt PROMPT_SUBST
PROMPT='[%F{green}%*%f] %n in %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f> '

. $UTILSCRIPTS_DIR/startup/init-aliases.sh
. $UTILSCRIPTS_DIR/startup/init-hyprsunset.sh
. $UTILSCRIPTS_DIR/log.sh

# home / end / delete (in case omz didn't catch them)
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}"  end-of-line
bindkey "${terminfo[kdch1]}" delete-char

# word-wise nav + delete
bindkey '^[[1;5C' forward-word       # ctrl+right
bindkey '^[[1;5D' backward-word      # ctrl+left
bindkey '^H'      backward-kill-word # ctrl+backspace
bindkey '^[[3;5~' kill-word          # ctrl+delete

[[ -f ~/.profile ]] && . ~/.profile
