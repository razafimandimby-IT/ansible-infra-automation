# Guide de Demarrage Rapide

## Prerequis

### Sur le poste de controle (Control Node)

```bash
# Systeme d'exploitation
# Debian 12, Ubuntu 22.04+, Rocky Linux 9+, ou WSL sur Windows

# Installer Python 3.9+ et pip
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

# Installer Ansible
python3 -m pip install --user ansible-core>=2.15
ansible --version

# Cloner le depot
git clone https://github.com/razafimandimby-IT/ansible-infra-automation.git
cd ansible-infra-automation

# Installer les collections et roles
ansible-galaxy collection install -r requirements.yml
ansible-galaxy role install -r requirements.yml
```

### Configuration SSH

```bash
# Generer une cle SSH (si pas deja fait)
ssh-keygen -t ed25519 -a 100 -f ~/.ssh/ansible-admin

# Copier la cle sur chaque serveur cible
ssh-copy-id -i ~/.ssh/ansible-admin ansible-admin@<server-ip>

# Verifier la connexion
ssh -i ~/.ssh/ansible-admin ansible-admin@<server-ip>
```

### Configuration reseau

- Les serveurs cibles doivent etre accessibles via SSH depuis le poste de controle
- Les serveurs doivent avoir Python 3 installe
- L'utilisateur ansible-admin doit avoir les privileges sudo sans mot de passe

## Verification de l'inventaire

```bash
# Lister les hotes
ansible all -i inventory/production/hosts.ini --list-hosts

# Tester la connectivite
ansible all -i inventory/production/hosts.ini -m ping

# Recuperer les facts d'un hote
ansible web01.example.internal -i inventory/production/hosts.ini -m setup
```

## Personnalisation des variables

1. Copier `inventory/production/group_vars/all.yml` et adapter les valeurs
2. Configurer les mots de passe avec Ansible Vault:

```bash
ansible-vault create inventory/production/group_vars/vault.yml
```

Exemple de contenu vault:
```yaml
vault_dc_admin_password: "VotreMotDePasseAD"
vault_db_admin_password: "VotreMotDePasseDB"
vault_grafana_admin_password: "VotreMotDePasseGrafana"
```

3. Modifier `inventory/production/hosts.ini` avec vos adresses IP et noms d'hotes

## Deploiement progressif

### Etape 1: Configuration de base et securite

```bash
# Appliquer la configuration commune
ansible-playbook playbooks/site.yml --tags common

# Appliquer le hardening de securite
ansible-playbook playbooks/05-security-baseline.yml
```

### Etape 2: Domain Controller

```bash
# Deployer le controleur de domaine
ansible-playbook playbooks/01-domain-controller.yml -l dc01
```

### Etape 3: Serveurs web

```bash
# Deployer les serveurs web
ansible-playbook playbooks/02-web-server.yml
```

### Etape 4: Bases de donnees

```bash
# Deployer les serveurs de bases de donnees
ansible-playbook playbooks/03-database-server.yml -l db01-primary
ansible-playbook playbooks/03-database-server.yml -l db02-standby
```

### Etape 5: Monitoring

```bash
# Deployer la supervision
ansible-playbook playbooks/04-monitoring.yml
```

### Etape 6: Sauvegardes

```bash
# Configurer les sauvegardes
ansible-playbook playbooks/06-backup-client.yml
```

### Etape 7: Validation

```bash
# Executer le health check complet
ansible-playbook playbooks/99-healthcheck.yml -v
```

## Deploiement complet

```bash
# Deploiement de l'infrastructure complete
ansible-playbook playbooks/site.yml
```

## Commandes utiles

```bash
# Mode check (dry-run)
ansible-playbook playbooks/site.yml --check

# Deploiement avec etape specifique
ansible-playbook playbooks/site.yml --tags security

# Ignorer une etape
ansible-playbook playbooks/site.yml --skip-tags backup

# Limiter a un groupe d'hotes
ansible-playbook playbooks/04-monitoring.yml -l web_servers

# Avec des variables supplementaires
ansible-playbook playbooks/02-web-server.yml -e "nginx_port=8080 ssl_enabled=true"

# Avec mot de passe vault
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## Securite

```bash
# Chiffrer un fichier de variables
ansible-vault encrypt inventory/production/group_vars/vault.yml

# Editer un fichier chiffre
ansible-vault edit inventory/production/group_vars/vault.yml

# Visualiser un fichier chiffre
ansible-vault view inventory/production/group_vars/vault.yml
```

## Dépannage

```bash
# Mode verbose (niveau 1-4)
ansible-playbook playbooks/site.yml -v
ansible-playbook playbooks/site.yml -vvv

# Tester un module sur un hote
ansible web01 -m ansible.builtin.command -a "uptime"

# Generer les facts pour debug
ansible web01 -m ansible.builtin.setup > /tmp/web01-facts.json

# Verifier la syntaxe d'un playbook
ansible-playbook playbooks/site.yml --syntax-check
```

## Prochaines etapes

1. Configurer les certificats SSL via Certbot
2. Mettre en place le pipeline CI/CD (GitHub Actions)
3. Deployer le monitoring Grafana avec les dashboards
4. Configurer les alertes (email, Slack, PagerDuty)
5. Executer les tests de securite reguliers