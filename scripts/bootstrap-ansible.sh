#!/bin/bash
# ============================================================
# Bootstrap Ansible Control Node
# ============================================================
# Automates the setup of an Ansible control node on a fresh
# Debian/Ubuntu or Rocky Linux/RHEL system.
# ============================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/razafimandimby-IT/ansible-infra-automation/main/scripts/bootstrap-ansible.sh | bash
#   # OR
#   wget -qO- https://raw.githubusercontent.com/razafimandimby-IT/ansible-infra-automation/main/scripts/bootstrap-ansible.sh | bash
# ============================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# Configuration
ANSIBLE_USER="${ANSIBLE_USER:-ansible-admin}"
ANSIBLE_VERSION="${ANSIBLE_VERSION:-stable-2.15}"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
REPO_URL="https://github.com/razafimandimby-IT/ansible-infra-automation.git"
SSH_KEY_TYPE="ed25519"

log "Starting Ansible Control Node bootstrap..."

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    error "Cannot detect OS. Exiting."
    exit 1
fi

log "Detected OS: $OS $VERSION"

# System update and Python installation
case "$OS" in
    debian|ubuntu)
        log "Updating package index..."
        apt-get update -qq

        log "Installing system dependencies..."
        apt-get install -y -qq \
            python3 \
            python3-pip \
            python3-venv \
            git \
            curl \
            wget \
            ca-certificates \
            gnupg \
            lsb-release \
            software-properties-common

        # Install pip if missing
        if ! command -v pip3 &> /dev/null; then
            apt-get install -y -qq python3-pip
        fi
        ;;
    rocky|rhel|centos|almalinux)
        log "Installing system dependencies..."
        dnf install -y epel-release || true
        dnf install -y \
            python3 \
            python3-pip \
            python3-devel \
            git \
            curl \
            wget \
            ca-certificates

        # Enable CRB/Powertools for Rocky Linux 9+
        dnf config-manager --set-enabled crb 2>/dev/null || \
        dnf config-manager --set-enabled powertools 2>/dev/null || true
        ;;
    *)
        error "Unsupported OS: $OS"
        exit 1
        ;;
esac

log "Installing Ansible..."
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install ansible-core ansible-lint

# Verify installation
log "Verifying Ansible installation..."
ansible --version || {
    warn "Ansible not in PATH, attempting to fix..."
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    ansible --version || error "Ansible installation failed"
}

# Create Ansible user
if ! id "$ANSIBLE_USER" &>/dev/null; then
    log "Creating Ansible user: $ANSIBLE_USER..."
    useradd -m -s /bin/bash -G sudo "$ANSIBLE_USER"
    echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$ANSIBLE_USER
    chmod 0440 /etc/sudoers.d/$ANSIBLE_USER
fi

# Generate SSH key for Ansible user
if [ ! -f "/home/$ANSIBLE_USER/.ssh/id_$SSH_KEY_TYPE" ]; then
    log "Generating SSH key ($SSH_KEY_TYPE) for $ANSIBLE_USER..."
    sudo -u "$ANSIBLE_USER" mkdir -p "/home/$ANSIBLE_USER/.ssh"
    sudo -u "$ANSIBLE_USER" ssh-keygen -t "$SSH_KEY_TYPE" -a 100 \
        -f "/home/$ANSIBLE_USER/.ssh/id_$SSH_KEY_TYPE" \
        -N "" -C "$ANSIBLE_USER@ansible-control-node"
    sudo -u "$ANSIBLE_USER" cp "/home/$ANSIBLE_USER/.ssh/id_$SSH_KEY_TYPE.pub" \
        "/home/$ANSIBLE_USER/.ssh/authorized_keys"
    chmod 600 "/home/$ANSIBLE_USER/.ssh/authorized_keys"
fi

# Clone repository
log "Cloning Ansible Infrastructure Automation repository..."
if [ -d "/opt/ansible-infra-automation" ]; then
    warn "Repository already exists. Updating..."
    cd /opt/ansible-infra-automation && git pull
else
    git clone "$REPO_URL" /opt/ansible-infra-automation
fi

# Install Ansible collections
log "Installing Ansible collections..."
cd /opt/ansible-infra-automation
ansible-galaxy collection install -r requirements.yml

log "Installing Ansible roles..."
ansible-galaxy role install -r requirements.yml

# Final configuration
cat > /home/$ANSIBLE_USER/.ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = /opt/ansible-infra-automation/inventory/production/hosts.ini
EOF

chown "$ANSIBLE_USER:$ANSIBLE_USER" "/home/$ANSIBLE_USER/.ansible.cfg"

echo ""
log "============================================"
log " Ansible Control Node Bootstrap Complete"
log "============================================"
echo ""
log "Ansible user:     $ANSIBLE_USER"
log "Repository:       /opt/ansible-infra-automation"
log "Ansible version:  $(ansible --version 2>/dev/null | head -1)"
log "SSH public key:   /home/$ANSIBLE_USER/.ssh/id_$SSH_KEY_TYPE.pub"
echo ""
log "Next steps:"
echo "  1. Copy SSH public key to target servers:"
echo "     ssh-copy-id $ANSIBLE_USER@<target-server>"
echo ""
echo "  2. Test connectivity:"
echo "     ansible all -i /opt/ansible-infra-automation/inventory/production/hosts.ini -m ping"
echo ""
echo "  3. Run the deployment:"
echo "     cd /opt/ansible-infra-automation && ansible-playbook playbooks/site.yml"
echo ""