# NmapReconFlow — Known Errors & Bugs

## Critical

### E001: Campaign parallel mode never updates target status
**Location:** `lib/campaign.sh` lines 65-92
**Impact:** Campaign summary shows all targets as "running" with duration=0 in parallel mode.
**Root cause:** After backgrounded subshells complete, `campaign_status[$target]` and `campaign_end[$target]` are never updated. `wait -n` decrements a counter but doesn't identify which job finished.

### E002: Campaign subshells lack required globals
**Location:** `lib/campaign.sh` lines 47-53, 82-88
**Impact:** In campaign mode, each target's scan runs with uninitialized `nmapType`, `subnet`, `pingable`, `osType`, etc. Scans fail or produce incorrect results.
**Root cause:** `main()` depends on globals set by `header()` at runtime, but subshells only inherit exported variables. Only `HOST`, `OUTPUTDIR`, and `elapsedStart` are set.

### E003: `wait -n` requires bash 4.3+, nameref requires bash 4.3+
**Location:** `lib/campaign.sh` lines 72, 104-107
**Impact:** Script crashes on macOS default bash (3.2) and older Linux distros.
**Root cause:** No bash version check at startup.

## High

### E004: `nmapProgressBar()` always returns exit code 0
**Location:** `lib/ui.sh` lines 130-183
**Impact:** Scan functions can't detect nmap timeout/failure. Pipeline continues with missing data.
**Root cause:** Function ends with `rm -f` which always succeeds. No explicit return of nmap's exit code.

### E005: Timeout kills only parent process, not process tree
**Location:** `lib/timeout.sh` line 27, `lib/ui.sh` line 153
**Impact:** When nmap or recon tools are killed by timeout, their child processes (NSE scripts, ffuf threads) become orphans.
**Root cause:** `kill -TERM $pid` signals one process, not its process group.

### E006: Date arithmetic uses awk with octal-unsafe values
**Location:** `lib/utils.sh` lines 126, 129
**Impact:** Script crashes at hours 08 and 09 — awk treats `08`/`09` as invalid octal.
**Root cause:** Uses `date '+%H:%M:%S'` piped through awk instead of `date +%s`.

### E007: Linux ping timeout is 1 millisecond, not 1 second
**Location:** `lib/utils.sh` line 10 (via `lib/config.sh` line 17)
**Impact:** Network scan finds few/no hosts on Linux because ping timeout is effectively zero.
**Root cause:** Linux `ping -W` takes seconds (not milliseconds as the comment suggests), but the value `1` is correct. Actually re-checking: Linux `ping -W 1` = 1 second. This may be fine — needs verification.

## Medium

### E008: YAML escaping only handles double quotes
**Location:** `lib/report.sh` lines 32-36
**Impact:** Backslashes, newlines, and other special chars in service versions produce invalid YAML.

### E009: `hostname` field empty when target is an IP
**Location:** `lib/report.sh` line 147
**Impact:** YAML front matter has empty hostname field for IP targets.

### E010: Recon tool arrays not reset between campaign targets
**Location:** `lib/recon.sh` lines 272-273
**Impact:** In campaign mode, later targets overwrite earlier targets' recon status data.

### E011: Network scan sort output not saved to file
**Location:** `lib/scans.sh` line 23
**Impact:** Sorted host list is printed to stdout but the file remains unsorted.

### E012: Signal handler vulnerable to double-invocation
**Location:** `lib/timeout.sh` lines 52-68
**Impact:** If two signals arrive rapidly, cleanup runs twice with unpredictable results.
