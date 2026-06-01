# NmapReconFlow — Learnings

## Architecture Decisions

### L001: Bash modularization via `source`
Splitting a monolithic shell script into `lib/*.sh` modules sourced at startup works well for organization but creates a flat namespace. All functions and globals share scope. This is acceptable for a tool of this size (~2000 lines) but means variable naming discipline is critical.

### L002: `eval` is still needed for constructed nmap commands
The `nmapProgressBar()` function receives nmap commands as strings because it needs to parse `-oN <file>` to find the output filename. This forces `eval` usage. Alternative: pass the output file as a separate argument and construct the command inside the function.

### L003: Subshell isolation vs global state
Campaign mode runs each target in a subshell for isolation, but `main()` was designed for single-target mode where globals are set progressively (header sets nmapType, portScan sets commonPorts, etc.). The subshell approach requires either: (a) exporting all globals, (b) re-initializing inside the subshell, or (c) restructuring main() to be self-contained.

### L004: Process tree management in bash
`kill -TERM $pid` only kills the immediate process. For tools that spawn children (nmap NSE scripts, ffuf threads), you need process group kills: `kill -TERM -$pid` (note the negative PID). This requires starting the child in its own process group with `set -m` or `setsid`.

### L005: Date arithmetic pitfall
`date '+%H:%M:%S'` produces zero-padded hours like `08` which awk interprets as octal (and `08` is invalid octal). Always use `date +%s` (epoch seconds) for arithmetic. The original nmapAutomator had this same bug.

## Cross-Platform Pitfalls

### L006: macOS ships bash 3.2
Apple licenses bash under GPLv2 and refuses to ship GPLv3 (bash 4+). Associative arrays, nameref (`local -n`), and `wait -n` all require bash 4+. Either: document the requirement, check at startup, or avoid these features.

### L007: `sed -i` is the #1 cross-platform trap
GNU sed: `sed -i 's/foo/bar/' file`
BSD sed: `sed -i '' 's/foo/bar/' file`
Always use the `sed_inplace()` wrapper.

### L008: Ping timeout flag
Linux `ping -W 1` = 1 second timeout. macOS `ping -t 1` = 1 second timeout. Both use seconds with the value `1`, so the current implementation is correct despite confusing flag names.

## Testing Observations

### L009: No nmap available in CI/container environments
The tool can't be functionally tested without nmap installed. Unit tests should mock nmap output files and test parsing/reporting functions independently.

### L010: Progress bar requires a TTY
The progress dashboard uses ANSI escape sequences that break in piped/redirected output. The `IS_TTY` check handles this but makes automated testing of UI functions difficult.
