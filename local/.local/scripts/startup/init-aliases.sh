#!/bin/bash

export LC_ALL="en_US.UTF-8"
alias nv="nvim ."

# shellcheck shell=bash
eval "$(zoxide init --cmd cd zsh)"
eval "$(atuin init zsh)"
eval "$(pay-respects zsh --alias)"
alias ls="eza --group-directories-first --icons --git"
alias ll="eza --group-directories-first -la --icons --git"
alias lt="eza --group-directories-first -T --git-ignore"
alias cat='bat'
alias dbe="distrobox enter"
