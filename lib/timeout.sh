#!/usr/bin/env bash
# NmapReconFlow - Timeout management and signal handling

declare -A CHILD_PIDS=()

# Run a command with a wall-clock timeout
# Usage: run_with_timeout <timeout_seconds> <label> <command...>
# Returns: 0 on success, 124 on timeout, or the command's exit code
run_with_timeout() {
    local timeout_secs="$1"
    local label="$2"
    shift 2

    if [ "$timeout_secs" -le 0 ]; then
        "$@"
        return $?
    fi

    "$@" &
    local child_pid=$!
    CHILD_PIDS["$child_pid"]=1

    (
        sleep "$timeout_secs"
        if kill -0 "$child_pid" 2>/dev/null; then
            log_warning "${label} exceeded timeout (${timeout_secs}s). Sending SIGTERM..."
            kill -TERM "$child_pid" 2>/dev/null
            sleep 5
            if kill -0 "$child_pid" 2>/dev/null; then
                log_warning "${label} did not respond to SIGTERM. Sending SIGKILL..."
                kill -KILL "$child_pid" 2>/dev/null
            fi
        fi
    ) &
    local watchdog_pid=$!

    wait "$child_pid" 2>/dev/null
    local exit_code=$?

    kill "$watchdog_pid" 2>/dev/null
    wait "$watchdog_pid" 2>/dev/null

    unset CHILD_PIDS["$child_pid"]

    if [ $exit_code -eq 137 ] || [ $exit_code -eq 143 ]; then
        log_warning "${label} was killed after ${timeout_secs}s timeout"
        return 124
    fi
    return $exit_code
}

cleanup_and_exit() {
    printf "\n${RED}Interrupted. Cleaning up background processes...${NC}\n" >&2
    for pid in "${!CHILD_PIDS[@]}"; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -TERM "$pid" 2>/dev/null
        fi
    done
    sleep 2
    for pid in "${!CHILD_PIDS[@]}"; do
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill -KILL "$pid" 2>/dev/null
        fi
    done
    rm -f nmap/*.tmp 2>/dev/null
    printf "${YELLOW}Cleanup complete.${NC}\n" >&2
    exit 130
}

install_signal_handlers() {
    trap 'cleanup_and_exit' INT TERM
}
