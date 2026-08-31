#!/usr/bin/env bash

# =============================================================================
# colors.sh
#
# ANSI terminal colors, formatting, and color helpers.
#
# Usage:
#   source "./constants/colors.sh"
#
#   printf '%sHello%s\n' "$FG_GREEN" "$RESET"
#   printf '%sOrange%s\n' "$(ansi_fg_hex '#ff8800')" "$RESET"
#
# =============================================================================


# =============================================================================
# ANSI / SGR primitives
# =============================================================================

readonly ESC=$'\033'
readonly CSI="${ESC}["

# Reset
readonly RESET="${CSI}0m"
readonly RESET_FG="${CSI}39m"
readonly RESET_BG="${CSI}49m"

# Text attributes
readonly BOLD="${CSI}1m"
readonly DIM="${CSI}2m"
readonly ITALIC="${CSI}3m"
readonly UNDERLINE="${CSI}4m"
readonly BLINK="${CSI}5m"
readonly RAPID_BLINK="${CSI}6m"
readonly REVERSE="${CSI}7m"
readonly HIDDEN="${CSI}8m"
readonly STRIKETHROUGH="${CSI}9m"

# Attribute resets
readonly NORMAL="${CSI}22m"
readonly NO_ITALIC="${CSI}23m"
readonly NO_UNDERLINE="${CSI}24m"
readonly NO_BLINK="${CSI}25m"
readonly NO_REVERSE="${CSI}27m"
readonly NO_HIDDEN="${CSI}28m"
readonly NO_STRIKETHROUGH="${CSI}29m"


# =============================================================================
# Standard 8 foreground colors
#
# 30-37
# =============================================================================

readonly FG_BLACK="${CSI}30m"
readonly FG_RED="${CSI}31m"
readonly FG_GREEN="${CSI}32m"
readonly FG_YELLOW="${CSI}33m"
readonly FG_BLUE="${CSI}34m"
readonly FG_MAGENTA="${CSI}35m"
readonly FG_CYAN="${CSI}36m"
readonly FG_WHITE="${CSI}37m"


# =============================================================================
# Standard 8 background colors
#
# 40-47
# =============================================================================

readonly BG_BLACK="${CSI}40m"
readonly BG_RED="${CSI}41m"
readonly BG_GREEN="${CSI}42m"
readonly BG_YELLOW="${CSI}43m"
readonly BG_BLUE="${CSI}44m"
readonly BG_MAGENTA="${CSI}45m"
readonly BG_CYAN="${CSI}46m"
readonly BG_WHITE="${CSI}47m"


# =============================================================================
# Bright / high-intensity foreground colors
#
# 90-97
# =============================================================================

readonly FG_BRIGHT_BLACK="${CSI}90m"
readonly FG_BRIGHT_RED="${CSI}91m"
readonly FG_BRIGHT_GREEN="${CSI}92m"
readonly FG_BRIGHT_YELLOW="${CSI}93m"
readonly FG_BRIGHT_BLUE="${CSI}94m"
readonly FG_BRIGHT_MAGENTA="${CSI}95m"
readonly FG_BRIGHT_CYAN="${CSI}96m"
readonly FG_BRIGHT_WHITE="${CSI}97m"


# =============================================================================
# Bright / high-intensity backgrounds
#
# 100-107
# =============================================================================

readonly BG_BRIGHT_BLACK="${CSI}100m"
readonly BG_BRIGHT_RED="${CSI}101m"
readonly BG_BRIGHT_GREEN="${CSI}102m"
readonly BG_BRIGHT_YELLOW="${CSI}103m"
readonly BG_BRIGHT_BLUE="${CSI}104m"
readonly BG_BRIGHT_MAGENTA="${CSI}105m"
readonly BG_BRIGHT_CYAN="${CSI}106m"
readonly BG_BRIGHT_WHITE="${CSI}107m"


# =============================================================================
# Semantic colors
#
# Prefer these in application code instead of FG_RED etc.
# This allows the visual theme to be changed in one place.
# =============================================================================

readonly COLOR_INFO="${FG_CYAN}"
readonly COLOR_SUCCESS="${FG_GREEN}"
readonly COLOR_WARNING="${FG_YELLOW}"
readonly COLOR_ERROR="${FG_RED}"
readonly COLOR_DEBUG="${FG_BRIGHT_BLACK}"
readonly COLOR_TRACE="${FG_BRIGHT_BLACK}"

readonly COLOR_TITLE="${FG_BRIGHT_CYAN}"
readonly COLOR_COMMAND="${FG_BRIGHT_BLUE}"
readonly COLOR_PATH="${FG_BRIGHT_CYAN}"
readonly COLOR_VALUE="${FG_BRIGHT_WHITE}"
readonly COLOR_MUTED="${FG_BRIGHT_BLACK}"

readonly COLOR_TIMESTAMP="${FG_BRIGHT_BLACK}"
readonly COLOR_SEPARATOR="${FG_BRIGHT_BLACK}"


# =============================================================================
# Semantic styles
# =============================================================================

readonly STYLE_INFO="${FG_CYAN}"
readonly STYLE_SUCCESS="${FG_GREEN}${BOLD}"
readonly STYLE_WARNING="${FG_YELLOW}${BOLD}"
readonly STYLE_ERROR="${FG_RED}${BOLD}"
readonly STYLE_DEBUG="${FG_BRIGHT_BLACK}"
readonly STYLE_TITLE="${FG_BRIGHT_CYAN}${BOLD}"
readonly STYLE_COMMAND="${FG_BRIGHT_BLUE}"
readonly STYLE_MUTED="${DIM}"


# =============================================================================
# 256-color helpers
#
# Foreground:
#   ESC[38;5;N m
#
# Background:
#   ESC[48;5;N m
#
# N = 0..255
# =============================================================================

ansi_fg256() {
    printf '%s' "${CSI}38;5;${1}m"
}

ansi_bg256() {
    printf '%s' "${CSI}48;5;${1}m"
}


# =============================================================================
# 24-bit / TrueColor helpers
#
# Foreground:
#   ESC[38;2;R;G;Bm
#
# Background:
#   ESC[48;2;R;G;Bm
# =============================================================================

ansi_fg_rgb() {
    printf '%s' "${CSI}38;2;${1};${2};${3}m"
}

ansi_bg_rgb() {
    printf '%s' "${CSI}48;2;${1};${2};${3}m"
}


# HEX helpers
#
# Example:
#   printf '%sHello%s\n' "$(ansi_fg_hex '#ff8800')" "$RESET"
#

ansi_fg_hex() {
    local hex="${1#\#}"

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    ansi_fg_rgb "$r" "$g" "$b"
}

ansi_bg_hex() {
    local hex="${1#\#}"

    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    ansi_bg_rgb "$r" "$g" "$b"
}


# =============================================================================
# Common 256-color aliases
#
# These are intentionally semantic rather than trying to name every one of
# the 256 palette entries.
# =============================================================================

readonly FG_GRAY="${CSI}38;5;245m"
readonly FG_DARK_GRAY="${CSI}38;5;240m"
readonly FG_LIGHT_GRAY="${CSI}38;5;250m"

readonly FG_ORANGE="${CSI}38;5;208m"
readonly FG_PINK="${CSI}38;5;213m"
readonly FG_PURPLE="${CSI}38;5;135m"
readonly FG_TEAL="${CSI}38;5;37m"
readonly FG_LIME="${CSI}38;5;118m"

readonly FG_LIGHT_BLUE="${CSI}38;5;117m"
readonly FG_LIGHT_CYAN="${CSI}38;5;159m"
readonly FG_LIGHT_GREEN="${CSI}38;5;120m"
readonly FG_LIGHT_YELLOW="${CSI}38;5;228m"
readonly FG_LIGHT_RED="${CSI}38;5;210m"
readonly FG_LIGHT_MAGENTA="${CSI}38;5;219m"

readonly BG_GRAY="${CSI}48;5;245m"
readonly BG_DARK_GRAY="${CSI}48;5;240m"
readonly BG_LIGHT_GRAY="${CSI}48;5;250m"

readonly BG_ORANGE="${CSI}48;5;208m"
readonly BG_PURPLE="${CSI}48;5;135m"
readonly BG_TEAL="${CSI}48;5;37m"


# =============================================================================
# Terminal capability detection
# =============================================================================

terminal_supports_color() {
    [[ -t 1 ]] || return 1

    [[ "${NO_COLOR:-}" == "" ]] || return 1
    [[ "${TERM:-}" != "dumb" ]] || return 1

    return 0
}

terminal_supports_256() {
    [[ "${TERM:-}" == *256color* ]] && return 0

    [[ "${COLORTERM:-}" == "truecolor" ]] && return 0
    [[ "${COLORTERM:-}" == "24bit" ]] && return 0

    return 1
}

terminal_supports_truecolor() {
    [[ "${COLORTERM:-}" == "truecolor" ]] && return 0
    [[ "${COLORTERM:-}" == "24bit" ]] && return 0

    return 1
}


# =============================================================================
# Disable colors automatically when output is not interactive
#
# This is important for:
#
#   ./script.sh > output.log
#   ./script.sh | tee output.log
#   CI/CD
#   Docker logs
# =============================================================================

disable_colors() {
    readonly RESET=""
    readonly RESET_FG=""
    readonly RESET_BG=""

    readonly BOLD=""
    readonly DIM=""
    readonly ITALIC=""
    readonly UNDERLINE=""
    readonly BLINK=""
    readonly RAPID_BLINK=""
    readonly REVERSE=""
    readonly HIDDEN=""
    readonly STRIKETHROUGH=""

    readonly NORMAL=""
    readonly NO_ITALIC=""
    readonly NO_UNDERLINE=""
    readonly NO_BLINK=""
    readonly NO_REVERSE=""
    readonly NO_HIDDEN=""
    readonly NO_STRIKETHROUGH=""

    readonly FG_BLACK=""
    readonly FG_RED=""
    readonly FG_GREEN=""
    readonly FG_YELLOW=""
    readonly FG_BLUE=""
    readonly FG_MAGENTA=""
    readonly FG_CYAN=""
    readonly FG_WHITE=""

    readonly FG_BRIGHT_BLACK=""
    readonly FG_BRIGHT_RED=""
    readonly FG_BRIGHT_GREEN=""
    readonly FG_BRIGHT_YELLOW=""
    readonly FG_BRIGHT_BLUE=""
    readonly FG_BRIGHT_MAGENTA=""
    readonly FG_BRIGHT_CYAN=""
    readonly FG_BRIGHT_WHITE=""

    readonly BG_BLACK=""
    readonly BG_RED=""
    readonly BG_GREEN=""
    readonly BG_YELLOW=""
    readonly BG_BLUE=""
    readonly BG_MAGENTA=""
    readonly BG_CYAN=""
    readonly BG_WHITE=""

    readonly BG_BRIGHT_BLACK=""
    readonly BG_BRIGHT_RED=""
    readonly BG_BRIGHT_GREEN=""
    readonly BG_BRIGHT_YELLOW=""
    readonly BG_BRIGHT_BLUE=""
    readonly BG_BRIGHT_MAGENTA=""
    readonly BG_BRIGHT_CYAN=""
    readonly BG_BRIGHT_WHITE=""

    readonly COLOR_INFO=""
    readonly COLOR_SUCCESS=""
    readonly COLOR_WARNING=""
    readonly COLOR_ERROR=""
    readonly COLOR_DEBUG=""
    readonly COLOR_TRACE=""
}


# Automatically disable ANSI when stdout isn't a terminal.
if ! terminal_supports_color; then
    disable_colors
fi
