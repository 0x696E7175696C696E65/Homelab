# [`ubuntu-lxc.sh`](https://github.com/0x696E7175696C696E65/Homelab/blob/main/Proxmox/lxc%20scripts/ubuntu-lxc.sh)

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
