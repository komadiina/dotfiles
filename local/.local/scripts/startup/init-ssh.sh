#!/bin/bash

source "${UTILSCRIPTS_DIR:-$HOME/.local/scripts}/load-creds.sh" || return 1

eval "$(ssh-agent)" >&/dev/null

load-ssh-vfz () {
  ssh-add -d "$SSH_KEY_CX"
  ssh-add "$SSH_KEY_VFZ"

  echo "gh: $(ssh -T git@github.com)"
  echo "gl: $(ssh -T git@gitlab.com)"
}

load-ssh-cx () {
  ssh-add -d "$SSH_KEY_VFZ"
  ssh-add "$SSH_KEY_CX"

  echo "gh: $(ssh -T git@github.com)"
  echo "gl: $(ssh -T git@gitlab.com)"
}
