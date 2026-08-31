#!/usr/bin/env bash

# =============================================================================
# symbols.sh
#
# Unicode symbols and ASCII fallbacks for terminal output.
#
# Usage:
#   source "./constants/symbols.sh"
#
#   printf '%s Done\n' "$SYMBOL_SUCCESS"
#
# =============================================================================


# =============================================================================
# Symbols
#
# Symbols are kept separate from colors so that the same logging code can
# easily be switched to ASCII-only mode.
# =============================================================================

readonly SYMBOL_INFO="ℹ"
readonly SYMBOL_SUCCESS="✔"
readonly SYMBOL_WARNING="⚠"
readonly SYMBOL_ERROR="✖"
readonly SYMBOL_DEBUG="·"
readonly SYMBOL_TRACE="→"

readonly SYMBOL_ARROW="→"
readonly SYMBOL_ARROW_RIGHT="➜"
readonly SYMBOL_ARROW_LONG="⟶"

readonly SYMBOL_BULLET="•"
readonly SYMBOL_DOT="·"
readonly SYMBOL_POINTER="❯"

readonly SYMBOL_PLUS="+"
readonly SYMBOL_MINUS="−"

readonly SYMBOL_CHECK="✓"
readonly SYMBOL_CROSS="✗"

readonly SYMBOL_STAR="★"
readonly SYMBOL_DIAMOND="◆"

readonly SYMBOL_UP="↑"
readonly SYMBOL_DOWN="↓"

readonly SYMBOL_ELLIPSIS="…"
readonly SYMBOL_PIPE="│"
readonly SYMBOL_DASH="─"


# =============================================================================
# ASCII fallback symbols
#
# Useful for CI, dumb terminals, log files, SSH environments, etc.
# =============================================================================

readonly ASCII_INFO="i"
readonly ASCII_SUCCESS="+"
readonly ASCII_WARNING="!"
readonly ASCII_ERROR="x"
readonly ASCII_DEBUG="."
readonly ASCII_TRACE=">"

readonly ASCII_ARROW=">"
readonly ASCII_BULLET="*"
readonly ASCII_POINTER=">"

readonly ASCII_CHECK="[OK]"
readonly ASCII_CROSS="[FAIL]"
