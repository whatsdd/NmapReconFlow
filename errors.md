# NmapReconFlow — Known Errors & Bugs

## Critical

### ~~E001: Campaign parallel mode never updates target status~~ FIXED
PID-to-target mapping with individual `wait $pid` for status collection.

### ~~E002: Campaign subshells lack required globals~~ FIXED
`run_single_target()` explicitly initializes all globals before calling `main()`.

### ~~E003: `wait -n` requires bash 4.3+, nameref requires bash 4.3+~~ FIXED
Bash 4.3+ version check added at startup with clear error message.

## High

### ~~E004: `nmapProgressBar()` always returns exit code 0~~ FIXED
Now tracks `nmap_rc` and `timed_out` flag, returns 124 on timeout or nmap's actual exit code.

### ~~E005: Timeout kills only parent process, not process tree~~ FIXED
`run_with_timeout()` now uses `setsid` + `_kill_tree()` (process group kill). `nmapProgressBar` timeout also uses `_kill_tree()`. `cleanup_and_exit` uses process group kills.

### ~~E006: Date arithmetic uses awk with octal-unsafe values~~ FIXED
All `date '+%H:%M:%S'` arithmetic replaced with `date +%s` (epoch seconds).

### E007: Linux ping timeout — verified not a bug
Linux `ping -W 1` = 1 second timeout. macOS `ping -t 1` = 1 second. Both correct.

## Medium

### ~~E008: YAML escaping only handles double quotes~~ FIXED
`yaml_escape()` now escapes backslashes first, then double quotes, then newlines. All string fields quoted.

### ~~E009: `hostname` field empty when target is an IP~~ FIXED
Falls back to `${HOST}` when `urlIP` is empty.

### ~~E010: Recon tool arrays not reset between campaign targets~~ FIXED
`run_single_target()` resets `RECON_TOOL_STATUS` and `RECON_TOOL_DURATION` per target.

### ~~E011: Network scan sort output not saved to file~~ FIXED
Uses `sort -o` to write back to the same file, then `cat` to display.

### ~~E012: Signal handler vulnerable to double-invocation~~ FIXED
`_CLEANUP_RUNNING` guard prevents re-entrant execution.
