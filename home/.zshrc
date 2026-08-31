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

. $UTILSCRIPTS_DIR/startup/init-ssh.sh
. $UTILSCRIPTS_DIR/startup/init-aliases.sh
. $UTILSCRIPTS_DIR/startup/init-hyprsunset.sh
. $UTILSCRIPTS_DIR/log.sh
[[ -f ~/.profile ]] && . ~/.profile
