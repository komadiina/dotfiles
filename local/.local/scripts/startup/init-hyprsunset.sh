#!/bin/bash

alias nighton="hyprctl hyprsunset temperature 3000"
alias nightoff="hyprctl hyprsunset temperature 6300"

night() {
  TEMP=$1
  hyprctl hyprsunset temperature "$TEMP"
}

