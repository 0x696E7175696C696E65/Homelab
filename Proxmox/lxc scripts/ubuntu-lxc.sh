#!/bin/bash
# ================================================================
#  pve-ubuntu-setup.sh
#  Proxmox Ubuntu First Time Setup Tool
#  Target : Ubuntu 22.04 / 24.04 LXC or VM
#  Installs: system deps · Docker CE · Compose V2 · aliases
#
#  Usage: sudo bash pve-ubuntu-setup.sh
# ================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────
R='\033[0m'   B='\033[1m'   D='\033[2m'
GRN='\033[1;32m'  CYN='\033[1;36m'  MGT='\033[1;35m'
YLW='\033[0;33m'  RED='\033[0;31m'  BLU='\033[0;34m'

# ── Logging ───────────────────────────────────────────────────────
LOG=/tmp/pve-ubuntu-setup.log
> "$LOG"

# ── Spinner ───────────────────────────────────────────────────────
_PID=""
_SP=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

_spin() {
  local i=0
  while true; do
    printf "\r  ${CYN}${_SP[$i]}${R}  ${D}$1${R}"
    i=$(( (i+1) % 10 ))
    sleep 0.07
    done
}

_stop() {
  [ -n "$_PID" ] && { kill "$_PID" 2>/dev/null; wait "$_PID" 2>/dev/null || true; _PID=""; }
}

ok()   { _stop; printf "\r  ${GRN}✓${R}  %-52s${D}done${R}\n"     "$1"; }
fail() { _stop; printf "\r  ${RED}✗${R}  %-52s${RED}failed${R}\n"  "$1"; echo -e "\n  ${D}→ $LOG${R}\n"; exit 1; }
skip() {        printf   "  ${BLU}–${R}  %-52s${D}skipped${R}\n"   "$1"; }
warn() { _stop; printf "\r  ${YLW}!${R}  %-52s${YLW}warning${R}\n" "$1"; }

run() {
  local label="$1"; shift
  _spin "$label" & _PID=$!; disown "$_PID"
  if "$@" >> "$LOG" 2>&1; then ok "$label"; else fail "$label"; fi
}

section() {
  echo ""
  echo -e "  ${MGT}${B}$1${R}"
  echo -e "  ${D}$(printf '%.0s─' {1..56})${R}"
}

# ── Guards ────────────────────────────────────────────────────────
[[ "$EUID" -ne 0 ]]        && echo -e "  ${RED}✗${R}  Run as root." && exit 1
[[ ! -f /etc/os-release ]] && echo -e "  ${RED}✗${R}  Cannot detect OS." && exit 1

source /etc/os-release
[[ "$ID" != "ubuntu" ]] && echo -e "  ${RED}✗${R}  Ubuntu only (detected: $ID)." && exit 1

# ── Banner ────────────────────────────────────────────────────────
clear
echo ""
echo -e "  ${CYN}${B}┌──────────────────────────────────────────────────────┐${R}"
echo -e "  ${CYN}${B}│${R}  ${B}Proxmox Ubuntu First Time Setup Tool${R}                 ${CYN}${B}│${R}"
echo -e "  ${CYN}${B}│${R}  ${D}Ubuntu 22.04 / 24.04  ·  Docker CE + Compose V2${R}     ${CYN}${B}│${R}"
echo -e "  ${CYN}${B}└──────────────────────────────────────────────────────┘${R}"
echo ""
echo -e "  ${GRN}✓${R}  ${B}$PRETTY_NAME${R}  ${D}($VERSION_CODENAME)${R}"
echo ""

# ── Timezone ──────────────────────────────────────────────────────
TZ_CURRENT=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
echo -e "  ${D}Current timezone: $TZ_CURRENT${R}"
read -rp "  New timezone (Enter to keep): " TZ_INPUT
echo ""

if [[ -n "$TZ_INPUT" ]]; then
  if timedatectl set-timezone "$TZ_INPUT" 2>/dev/null; then
    echo -e "  ${GRN}✓${R}  Timezone → ${B}$TZ_INPUT${R}"
    TZ_CURRENT="$TZ_INPUT"
    else
      echo -e "  ${YLW}!${R}  Invalid timezone — keeping ${B}$TZ_CURRENT${R}"
      fi
      else
        echo -e "  ${BLU}–${R}  Keeping ${B}$TZ_CURRENT${R}"
        fi
        
        # ── System ────────────────────────────────────────────────────────
        section "System"
        
        run "Refreshing package index" \
        apt-get update -qq
        
        run "Upgrading installed packages" \
        bash -c 'DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold"'
        
        # ── Dependencies ──────────────────────────────────────────────────
        section "Dependencies"
        
        PKGS=(
          ca-certificates curl wget gnupg lsb-release
          apt-transport-https software-properties-common
          zip unzip tar gzip bzip2 xz-utils p7zip-full
          net-tools iputils-ping dnsutils nmap traceroute
          openssh-client openssl
          htop btop ncdu tree lsof psmisc procps sysstat iotop
          git nano vim jq make build-essential python3 python3-pip
          cron logrotate rsync sqlite3 acl
        )
        
        run "Installing ${#PKGS[@]} packages" \
        bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq ${PKGS[*]}"
        
        # ── Docker ────────────────────────────────────────────────────────
        section "Docker"
        
        run "Removing legacy Docker packages" \
        bash -c 'apt-get remove -y -qq \
        docker.io docker-doc docker-compose docker-compose-v2 \
        podman-docker containerd runc 2>/dev/null || true'
        
        run "Adding Docker GPG key" \
        bash -c 'install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc'
        
        run "Adding Docker repository" \
        bash -c "echo \"deb [arch=\$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable\" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null && \
apt-get update -qq"

run "Installing Docker CE + Compose V2 + Buildkit" \
bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
docker-ce docker-ce-cli containerd.io \
docker-buildx-plugin docker-compose-plugin'

run "Enabling Docker service" \
systemctl enable docker --now

# ── Configuration ─────────────────────────────────────────────────
section "Configuration"

run "Configuring Docker daemon (log rotation + Buildkit)" \
bash -c 'cat > /etc/docker/daemon.json <<'"'"'EOF'"'"'
{
"log-driver": "json-file",
"log-opts": { "max-size": "10m", "max-file": "3" },
"features": { "buildkit": true }
}
EOF
systemctl restart docker'

if systemd-detect-virt --container >> "$LOG" 2>&1; then
  run "Applying LXC cgroup v2 Docker fix" \
  bash -c 'mkdir -p /etc/systemd/system/docker.service.d && \
  printf "[Service]\nExecStartPre=\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock\n" \
  > /etc/systemd/system/docker.service.d/override.conf && \
  systemctl daemon-reload && systemctl restart docker'
  else
    skip "LXC cgroup v2 fix (bare metal — not needed)"
    fi
    
    run "Creating /opt/stacks directory layout" \
    mkdir -p /opt/stacks/{data,config,logs}
    
    run "Writing Docker logrotate config" \
    bash -c 'cat > /etc/logrotate.d/docker <<'"'"'EOF'"'"'
    /var/lib/docker/containers/*/*.log {
    rotate 3
    daily
    compress
    missingok
    delaycompress
    copytruncate
    }
    EOF'
    
    run "Scheduling weekly Docker prune" \
    bash -c 'printf "#!/bin/bash\ndocker system prune -f --filter \"until=168h\" >> /var/log/docker-prune.log 2>&1\n" \
    > /etc/cron.weekly/docker-prune && chmod +x /etc/cron.weekly/docker-prune'
    
    run "Installing Docker CLI aliases" \
    bash -c 'cat > /etc/profile.d/homelab.sh <<'"'"'EOF'"'"'
    # Homelab Docker aliases — loaded automatically on login
    alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    alias dlog='docker logs -f'
    alias dex='docker exec -it'
    alias dup='docker compose up -d'
    alias ddown='docker compose down'
    alias dpull='docker compose pull'
    alias drestart='docker compose restart'
    alias dstats='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
    alias dclear='docker system prune -f'
    EOF
    chmod +x /etc/profile.d/homelab.sh'
    
    # ── Summary ───────────────────────────────────────────────────────
    HOST=$(hostname)
    IP=$(hostname -I 2>/dev/null | awk '{print $1}')
    DV=$(docker --version       | grep -oP '\d+\.\d+\.\d+' | head -1)
    CV=$(docker compose version | grep -oP '\d+\.\d+\.\d+' | head -1)
    
    echo ""
    echo -e "  ${CYN}${B}┌──────────────────────────────────────────────────────┐${R}"
    echo -e "  ${CYN}${B}│${R}               ${GRN}${B}Setup complete — ready to use ✓${R}        ${CYN}${B}│${R}"
    echo -e "  ${CYN}${B}└──────────────────────────────────────────────────────┘${R}"
    echo ""
    printf  "  ${D}%-14s${R}  ${B}%s${R}\n"        "Hostname"   "$HOST"
    printf  "  ${D}%-14s${R}  %s\n"                "OS"         "$PRETTY_NAME"
    printf  "  ${D}%-14s${R}  %s\n"                "Timezone"   "$TZ_CURRENT"
    printf  "  ${D}%-14s${R}  ${CYN}${B}%s${R}\n"  "IP"         "$IP"
    printf  "  ${D}%-14s${R}  Docker v%s  ·  Compose v%s\n" "Runtime" "$DV" "$CV"
    printf  "  ${D}%-14s${R}  /opt/stacks\n"       "Stacks dir"
    echo ""
    echo -e "  ${D}Aliases active on next login, or load now:${R}"
    echo -e "  ${CYN}source /etc/profile.d/homelab.sh${R}"
    echo -e "  ${D}Full install log: $LOG${R}"
    echo ""
