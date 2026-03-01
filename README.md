<div align="center">

<br/>

```
██╗  ██╗ ██████╗ ███╗   ███╗███████╗██╗      █████╗ ██████╗
██║  ██║██╔═══██╗████╗ ████║██╔════╝██║     ██╔══██╗██╔══██╗
███████║██║   ██║██╔████╔██║█████╗  ██║     ███████║██████╔╝
██╔══██║██║   ██║██║╚██╔╝██║██╔══╝  ██║     ██╔══██║██╔══██╗
██║  ██║╚██████╔╝██║ ╚═╝ ██║███████╗███████╗██║  ██║██████╔╝
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝
```

**A curated collection of scripts, configs, and compose files for self-hosted infrastructure.**

<br/>

![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=flat-square&logo=proxmox&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=flat-square&logo=ubuntu&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-121011?style=flat-square&logo=gnu-bash&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-6366f1?style=flat-square)

<br/>

</div>

---

## Overview

This repository is a living collection of automation scripts, Docker Compose stacks, and configuration tools built for a self-hosted Proxmox homelab. Everything here is designed to be clean, minimal, and production-ready — no bloat, no hand-holding.

Scripts are organized by category and platform. Each one is documented with usage instructions, requirements, and what it actually does under the hood.

---

## Repository Structure

```
Homelab/
├── Proxmox/
│   └── lxc scripts/
│       └── ubuntu-lxc.sh       # Ubuntu LXC/VM first-time setup
├── compose/                     # Coming soon
│   └── ...
└── README.md
```

---

## Proxmox

Scripts for provisioning and configuring Proxmox LXC containers and VMs.

<br/>

### [`ubuntu-lxc.sh`](https://github.com/0x696E7175696C696E65/Homelab/blob/main/Proxmox/lxc%20scripts/ubuntu-lxc.sh)

**Proxmox Ubuntu First Time Setup Tool**

A first-run provisioning script for fresh Ubuntu 22.04 / 24.04 LXC containers and VMs on Proxmox. Handles everything from system updates to a fully configured Docker environment in a single command — with a clean progress UI and zero verbose garbage output.

**What it does:**

| Step | Description |
|------|-------------|
| System | Full `apt` update + upgrade with conflict-safe config handling |
| Dependencies | Installs 33+ essential packages (networking, compression, dev tools, monitoring) |
| Docker | Removes legacy installs, adds official Docker repo, installs CE + Compose V2 + Buildkit |
| LXC Fix | Auto-detects Proxmox LXC environment and applies cgroup v2 Docker compatibility fix |
| Configuration | Log rotation (10MB × 3), weekly prune cron, `/opt/stacks` layout, Buildkit enabled |
| Aliases | Installs Docker CLI shortcuts to `/etc/profile.d/homelab.sh` |

**Aliases installed:**

```bash
dps        # list containers with status and ports
dup        # docker compose up -d
ddown      # docker compose down
dlog       # follow container logs
dstats     # cpu + memory usage per container
dclear     # prune unused images, volumes, networks
```

**Requirements:**
- Ubuntu 22.04 or 24.04
- Root or sudo access
- Run **inside the LXC / VM** — not on your local machine

**Usage:**

```bash
# On your Proxmox LXC or VM — as root
bash ubuntu-lxc.sh
```

```bash
# Transfer from your machine first if needed
scp ubuntu-lxc.sh root@<lxc-ip>:/root/
ssh root@<lxc-ip> "bash ubuntu-lxc.sh"
```

After setup, load aliases in the current session:
```bash
source /etc/profile.d/homelab.sh
```

Full install log is always saved to `/tmp/pve-ubuntu-setup.log`.

---

## Coming Soon

| Category | Description |
|----------|-------------|
| `compose/` | Docker Compose stacks for self-hosted services |
| `Proxmox/` | Additional LXC provisioning scripts |

---

## Notes

- All scripts are tested on **Proxmox VE 9.x** with **Ubuntu 24.04 LTS** LXC containers
- Scripts redirect all package manager output to a log file — the terminal only shows progress
- If a step fails, the log path is printed so you can debug without re-running everything

---

<div align="center">

<br/>

`self-hosted` &nbsp;·&nbsp; `proxmox` &nbsp;·&nbsp; `docker` &nbsp;·&nbsp; `homelab` &nbsp;·&nbsp; `ubuntu` &nbsp;·&nbsp; `lxc`

<br/>

</div>
