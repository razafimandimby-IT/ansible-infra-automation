#!/bin/bash
# ============================================================
# Ansible Vault Helper — Encrypt and manage secrets
# ============================================================
# Usage:
#   ./scripts/encrypt-vault.sh create       # Create new vault file
#   ./scripts/encrypt-vault.sh edit         # Edit existing vault
#   ./scripts/encrypt-vault.sh view         # View vault contents
#   ./scripts/encrypt-vault.sh encrypt <file>  # Encrypt a file
#   ./scripts/encrypt-vault.sh decrypt <file>  # Decrypt a file
#   ./scripts/encrypt-vault.sh key          # Generate vault password file
# ============================================================

set -euo pipefail

VAULT_DIR="inventory/production/group_vars"
VAULT_FILE="$VAULT_DIR/vault.yml"
VAULT_PASSWORD_FILE="${ANSIBLE_VAULT_PASSWORD_FILE:-.vault_pass}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 {create|edit|view|encrypt|decrypt|key}"
    echo ""
    echo "Commands:"
    echo "  create              Create a new vault file"
    echo "  edit                Edit the vault file"
    echo "  view                View vault contents"
    echo "  encrypt <file>      Encrypt an existing file"
    echo "  decrypt <file>      Decrypt an encrypted file"
    echo "  key                 Generate a vault password file"
    exit 1
}

case "${1:-help}" in
    create)
        if [ -f "$VAULT_FILE" ]; then
            echo -e "${YELLOW}Vault file already exists: $VAULT_FILE${NC}"
            echo -e "Use '$0 edit' to modify it."
            exit 1
        fi
        echo -e "${GREEN}Creating vault file: $VAULT_FILE${NC}"
        echo -e "${YELLOW}Enter your secrets (Ctrl+D to save):${NC}"
        cat > /tmp/vault-content.yml
        ansible-vault encrypt --vault-id "$VAULT_PASSWORD_FILE" /tmp/vault-content.yml
        mv /tmp/vault-content.yml "$VAULT_FILE"
        echo -e "${GREEN}Vault file created: $VAULT_FILE${NC}"
        ;;
    edit)
        if [ ! -f "$VAULT_FILE" ]; then
            echo -e "${RED}Vault file not found: $VAULT_FILE${NC}"
            echo -e "Use '$0 create' to create one."
            exit 1
        fi
        ansible-vault edit --vault-id "$VAULT_PASSWORD_FILE" "$VAULT_FILE"
        ;;
    view)
        if [ ! -f "$VAULT_FILE" ]; then
            echo -e "${RED}Vault file not found: $VAULT_FILE${NC}"
            exit 1
        fi
        ansible-vault view --vault-id "$VAULT_PASSWORD_FILE" "$VAULT_FILE"
        ;;
    encrypt)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Usage: $0 encrypt <file>${NC}"
            exit 1
        fi
        if [ ! -f "$2" ]; then
            echo -e "${RED}File not found: $2${NC}"
            exit 1
        fi
        ansible-vault encrypt --vault-id "$VAULT_PASSWORD_FILE" "$2"
        echo -e "${GREEN}File encrypted: $2${NC}"
        ;;
    decrypt)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Usage: $0 decrypt <file>${NC}"
            exit 1
        fi
        if [ ! -f "$2" ]; then
            echo -e "${RED}File not found: $2${NC}"
            exit 1
        fi
        ansible-vault decrypt --vault-id "$VAULT_PASSWORD_FILE" "$2"
        echo -e "${GREEN}File decrypted: $2${NC}"
        ;;
    key)
        if [ -f "$VAULT_PASSWORD_FILE" ]; then
            echo -e "${YELLOW}Vault password file already exists: $VAULT_PASSWORD_FILE${NC}"
            exit 1
        fi
        echo -e "${GREEN}Generating vault password file: $VAULT_PASSWORD_FILE${NC}"
        openssl rand -base64 64 > "$VAULT_PASSWORD_FILE"
        chmod 0400 "$VAULT_PASSWORD_FILE"
        echo -e "${GREEN}Vault password file created: $VAULT_PASSWORD_FILE${NC}"
        echo -e "${YELLOW}IMPORTANT: Keep this file safe and back it up securely!${NC}"
        echo -e "${YELLOW}Never commit this file to version control!${NC}"
        ;;
    help|*)
        usage
        ;;
esac