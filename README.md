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

##

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
