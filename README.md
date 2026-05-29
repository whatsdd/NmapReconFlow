# NmapReconFlow

Automated reconnaissance workflow. Fire and forget.

*Based on [nmapAutomator](https://github.com/21y4d/nmapAutomator) by @21y4d*

## What's New

NmapReconFlow is a major overhaul of nmapAutomator with these improvements:

- **Timeout protection** — every scan and recon tool has a configurable wall-clock timeout. No more hanging nikto/gobuster sessions. Stuck scans are killed and the pipeline moves on.
- **Autopilot mode** (`-a`) — run the entire pipeline unattended, zero prompts.
- **Multi-target campaigns** (`-f targets.txt`) — give it a file of IPs and forget. Sequential by default, parallel with `-P N`.
- **Progress dashboard** — real-time status of each scan phase with elapsed time.
- **Summary report** — generates `summary.md` with YAML front matter (AI/tool readable) and markdown body (human readable). Includes port discovery timeline and finding confidence levels.
- **Signal handling** — Ctrl+C cleans up all background processes. No more orphaned nmap jobs.
- **Cross-platform** — works on macOS, Kali Linux, and Ubuntu.
- **Configurable** — rate limits, timeouts, wordlist paths, tool preferences via config file.

## Features

### Scan Types
| Type | Description | Time |
|------|-------------|------|
| Network | Discover live hosts on the network | ~15 seconds |
| Port | Find all open ports | ~15 seconds |
| Script | Version detection + NSE scripts on found ports | ~5 minutes |
| Full | All 65535 ports + script scan on new ports | ~5-10 minutes |
| UDP | UDP port scan (requires sudo) | ~5 minutes |
| Vulns | CVE detection + vulnerability scripts | ~5-15 minutes |
| Recon | Auto-recommend and run service-specific recon tools | varies |
| All | Run everything | ~20-30 minutes |

### Autopilot Mode
```bash
./nmapReconFlow.sh -H 10.10.10.10 -t All -a
```
Runs all scans unattended. Stuck tools are killed after their timeout (default 10 minutes for recon tools). The pipeline continues automatically.

### Multi-Target Campaigns
```bash
# targets.txt: one IP or hostname per line, # for comments
./nmapReconFlow.sh -f targets.txt -t All -a

# Parallel (2 targets at a time)
./nmapReconFlow.sh -f targets.txt -t All -a -P 2
```
Each target gets its own output directory. A campaign summary is generated at the end.

### Summary Report
After scanning, `summary.md` is generated with:
- **YAML front matter**: structured data for AI tools and scripts (ports, services, vulns, timing)
- **Open ports table** with service versions and discovery source
- **Port discovery timeline**: which scan found which ports
- **Vulnerability findings** with confidence levels (confirmed/probable/potential)
- **Recon tool output** (truncated, with timeout status)
- **Scan phase summary** with durations

### Configuration
Copy `nmapReconFlow.conf.example` to `./nmapReconFlow.conf` or `~/.nmapReconFlow.conf`:
```bash
cp nmapReconFlow.conf.example nmapReconFlow.conf
```
Configurable: timeouts, nmap rate limits, wordlist paths, tool skip lists, parallelism, report options.

## Requirements

- **bash** 4.3+ (for associative arrays and `wait -n`)
- **nmap**
- **Recommended**: [ffuf](https://github.com/ffuf/ffuf) or [gobuster](https://github.com/OJ/gobuster)

Other recon tools (installed automatically on Kali, install as needed on other distros):

| Tool | Tool | Tool | Tool | Tool |
|:----:|:----:|:----:|:----:|:----:|
| [nmap-vulners](https://github.com/vulnersCom/nmap-vulners) | [sslscan](https://github.com/rbsec/sslscan) | [nikto](https://github.com/sullo/nikto) | [joomscan](https://github.com/rezasp/joomscan) | [wpscan](https://github.com/wpscanteam/wpscan) |
| [droopescan](https://github.com/droope/droopescan) | [smbmap](https://github.com/ShawnDEvans/smbmap) | [enum4linux](https://github.com/portcullislabs/enum4linux) | [dnsrecon](https://github.com/darkoperator/dnsrecon) | [odat](https://github.com/quentinhardy/odat) |
| [smtp-user-enum](https://github.com/pentestmonkey/smtp-user-enum) | snmp-check | snmpwalk | ldapsearch | |

Missing tools are automatically detected and skipped with a warning.

## Installation

```bash
git clone https://github.com/whatsdd/NmapReconFlow.git
cd NmapReconFlow
chmod +x nmapReconFlow.sh
sudo ln -s "$(pwd)/nmapReconFlow.sh" /usr/local/bin/nmapReconFlow
```

### macOS
```bash
brew install nmap
# Install recon tools as needed
```

### Kali / Ubuntu
```bash
sudo apt update && sudo apt install nmap ffuf -y
```

## Usage

```
./nmapReconFlow.sh -h

Usage: nmapReconFlow.sh -H/--host <TARGET-IP> -t/--type <TYPE>
       nmapReconFlow.sh -f/--file <TARGETS-FILE> -t/--type <TYPE>

Required:
  -H, --host <TARGET>       Target IP or hostname
  -f, --file <FILE>         File with targets (one per line)
  -t, --type <TYPE>         Scan type

Optional:
  -a, --autopilot           Run unattended, no prompts
  -d, --dns <DNS>           Custom DNS server
  -o, --output <DIR>        Output directory
  -s, --static-nmap <PATH>  Path to static nmap binary
  -r, --remote              Remote mode (limited scans)
  -c, --config <FILE>       Config file path
  -P, --parallel <N>        Campaign parallelism (default: 1)
  --no-report               Skip summary.md generation
  -v, --version             Print version
```

### Examples
```bash
# Single target, all scans, autopilot
./nmapReconFlow.sh -H 10.10.10.10 -t All -a

# Quick port scan
./nmapReconFlow.sh -H 10.10.10.10 -t Port

# Recon with custom DNS
./nmapReconFlow.sh -H academy.htb -t Recon -d 1.1.1.1

# Multi-target campaign
./nmapReconFlow.sh -f targets.txt -t All -a

# Custom config and output dir
./nmapReconFlow.sh -H 10.10.10.10 -t All -a -c custom.conf -o results/
```

### Legacy Compatibility
The old `nmapAutomator.sh` flags still work. `Quick` maps to `Port`, `Basic` maps to `Script`.

## Output Structure
```
target_ip/
  nmap/
    Port_target.nmap
    Script_target.nmap
    Full_target.nmap
    UDP_target.nmap
    CVEs_target.nmap
    Vulns_target.nmap
    Recon_target.nmap
  recon/
    nikto_target_80.txt
    ffuf_target_80.txt
    ...
  summary.md                    # Human + AI readable report
  nmapReconFlow_target_All.txt  # Full console output
```

## Contributing

Pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)
