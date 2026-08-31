#!/usr/bin/env bash

# =============================================================================
# cursor.sh
#
# Cursor movement and terminal screen controls.
#
# Usage:
#   source "./constants/cursor.sh"
#
#   printf '%s' "$CURSOR_HIDE"
#   # ... do work ...
#   printf '%s' "$CURSOR_SHOW"
#
# =============================================================================


# Requires ESC and CSI from colors.sh
: "${ESC:=$'\033'}"
: "${CSI:="${ESC}["}"


# =============================================================================
# Cursor / terminal controls
# =============================================================================

readonly CURSOR_HIDE="${CSI}?25l"
readonly CURSOR_SHOW="${CSI}?25h"

readonly CURSOR_HOME="${CSI}H"
readonly CURSOR_CLEAR="${CSI}2J"
readonly CURSOR_CLEAR_LINE="${CSI}2K"

readonly CURSOR_SAVE="${ESC}7"
readonly CURSOR_RESTORE="${ESC}8"

readonly SCREEN_ALT_ENABLE="${CSI}?1049h"
readonly SCREEN_ALT_DISABLE="${CSI}?1049l"
