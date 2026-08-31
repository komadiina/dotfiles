#!/usr/bin/env bash

# =============================================================================
# log.sh
#
# Logging helpers for terminal output.
#
# Usage:
#   source "./log.sh"
#
#   log_info "Starting service"
#   log_success "Service started"
#   log_warn "Configuration missing"
#   log_error "Service failed"
#
# =============================================================================

SCRIPT_DIR="${UTILSCRIPTS_DIR:-$HOME/.local/scripts}"

source "${SCRIPT_DIR}/constants/colors.sh"
source "${SCRIPT_DIR}/constants/symbols.sh"
source "${SCRIPT_DIR}/constants/cursor.sh"


# =============================================================================
# Log prefixes
# =============================================================================

log_prefix() {
    local color="$1"
    local symbol="$2"
    local level="$3"

    printf '%s[%s %s]%s' \
        "$color" \
        "$symbol" \
        "$level" \
        "$RESET"
}


# =============================================================================
# Logging functions
# =============================================================================

log_info() {
    printf '%s %s\n' \
        "$(log_prefix "$COLOR_INFO" "$SYMBOL_INFO" "INFO")" \
        "$*"
}

log_success() {
    printf '%s %s\n' \
        "$(log_prefix "$COLOR_SUCCESS" "$SYMBOL_SUCCESS" "OK")" \
        "$*"
}

log_warn() {
    printf '%s %s\n' \
        "$(log_prefix "$COLOR_WARNING" "$SYMBOL_WARNING" "WARN")" \
        "$*"
}

log_error() {
    printf '%s %s\n' \
        "$(log_prefix "$COLOR_ERROR" "$SYMBOL_ERROR" "ERROR")" \
        "$*" >&2
}

log_debug() {
    [[ "${DEBUG:-0}" == "1" ]] || return 0

    printf '%s %s\n' \
        "$(log_prefix "$COLOR_DEBUG" "$SYMBOL_DEBUG" "DEBUG")" \
        "$*"
}

log_trace() {
    [[ "${TRACE:-0}" == "1" ]] || return 0

    printf '%s %s\n' \
        "$(log_prefix "$COLOR_TRACE" "$SYMBOL_TRACE" "TRACE")" \
        "$*"
}


# =============================================================================
# Section / heading helpers
# =============================================================================

log_section() {
    printf '\n%s%s %s%s\n' \
        "$STYLE_TITLE" \
        "$SYMBOL_DIAMOND" \
        "$*" \
        "$RESET"
}

log_step() {
    printf '%s%s%s %s\n' \
        "$COLOR_COMMAND" \
        "$SYMBOL_ARROW" \
        "$RESET" \
        "$*"
}

log_item() {
    printf '  %s%s%s %s\n' \
        "$COLOR_MUTED" \
        "$SYMBOL_BULLET" \
        "$RESET" \
        "$*"
}


# =============================================================================
# Key/value output
# =============================================================================

log_kv() {
    local key="$1"
    local value="$2"

    printf '  %s%-20s%s %s%s%s\n' \
        "$COLOR_MUTED" \
        "$key:" \
        "$RESET" \
        "$COLOR_VALUE" \
        "$value" \
        "$RESET"
}


# =============================================================================
# Command execution helper
#
# Runs a command, prints it, and reports success/failure.
# =============================================================================

run_cmd() {
    log_step "$*"

    if "$@"; then
        log_success "Command completed"
        return 0
    else
        local rc=$?
        log_error "Command failed (exit code: ${rc})"
        return "$rc"
    fi
}
