<p align="center">
  <img src="assets/ansible-logo.png" alt="Ansible Infrastructure Automation" width="200"/>
</p>

<h1 align="center">Ansible Infrastructure Automation</h1>

<p align="center">
  <strong>Infrastructure as Code — Deploiement AD, monitoring, securite, serveurs et automatisation IT enterprise</strong>
</p>

<p align="center">
  <a href="https://www.ansible.com"><img src="https://img.shields.io/badge/Ansible-2.15%2B-%23EE0000?style=for-the-badge&logo=ansible" alt="Ansible 2.15+"/></a>
  <a href=""><img src="https://img.shields.io/badge/IaC-Enabled-%2300599C?style=for-the-badge" alt="IaC Enabled"/></a>
  <a href="https://www.python.org"><img src="https://img.shields.io/badge/Python-3.9%2B-%233776AB?style=for-the-badge&logo=python" alt="Python 3.9+"/></a>
  <a href=""><img src="https://img.shields.io/badge/Security-Hardened-%2300C853?style=for-the-badge" alt="Security Hardened"/></a>
  <a href=""><img src="https://img.shields.io/badge/License-MIT-%23FFAB00?style=for-the-badge" alt="License MIT"/></a>
</p>

---

## Description

**Ansible Infrastructure Automation** est un projet d'Infrastructure as Code (IaC) complet et professionnel conçu pour automatiser le deploiement, la configuration, la securisation et la supervision d'une infrastructure IT enterprise.

Ce projet permet de deployer et gerer l'ensemble des composants d'un systeme d'information moderne :

- **Controleurs de domaine** Active Directory (via Samba AD DC)
- **Serveurs web** Nginx/Apache avec load balancing
- **Serveurs de bases de donnees** PostgreSQL / MySQL
- **Supervision** centralisee (Zabbix, Prometheus, Grafana)
- **Hardening** de securite conforme aux recommandations ANSSI / CIS Benchmarks
- **Sauvegardes** automatisees et chiffrees
- **Validation** de conformite et health checks

> Developpe avec une approche DevOps et les bonnes pratiques d'ingenierie d'infrastructure.

## Architecture

```

                          ANSIBLE CONTROL NODE
             playbooks/  |  roles/  |  inventory/  |  ansible.cfg
                  |            |            |            |
     +------------+-----+ +----+----+ +----+----+ +----+----+
     |   DOMAIN        | |   WEB   | |   DB    | | MONITOR |
     |   CONTROL       | | SERVERS | | SERVERS | |   ING   |
     |                 | |         | |         | |         |
     | AD / DNS / DHCP | | Nginx   | |PostgreSQ| | Zabbix  |
     | Samba / Kerberos| | Apache  | | MySQL   | |Prometheus|
     | KDC             | | PHP     | | Replic. | | Grafana |
     +-----------------+ +---------+ +---------+ +---------+
                                           +---------+
                                           | BACKUP  |
                                           | SERVERS |
                                           |         |
                                           | Borg    |
                                           | Rsync   |
                                           | Chiffr. |
                                           +---------+
```

## Fonctionnalites

| Fonctionnalite | Description |
|---|---|
| **Infrastructure as Code** | Declaratif, reproductible, versionne (Git) |
| **Securite Automatisee** | Hardening SSH, firewall, fail2ban, auditd, sysctl, CIS benchmarks |
| **Conformite Continue** | Verifications automatiques, rapports de conformite, remediation |
| **Deploiement AD** | Configuration complete de controleurs de domaine Samba AD |
| **Supervision Centralisee** | Agents Zabbix, Prometheus node_exporter, shipping de logs |
| **Sauvegardes Automatisees** | Backup chiffres avec retention, rotation et verification |
| **Multi-Environnements** | Inventaires separees production / staging |

## Requirements

| Technologie | Version |
|---|---|
| Ansible | >= 2.15 |
| Python | >= 3.9 |
| Systemes cibles | Debian 12 / Ubuntu 22.04+ / Rocky Linux 9+ / RHEL 9+ |
| Acces SSH | Cles SSH configurees pour l'utilisateur ansible-admin |
| Privileges | Sudo / become sur les noeuds cibles |

## Installation Rapide

```bash
# Cloner le depot
git clone https://github.com/razafimandimby-IT/ansible-infra-automation.git
cd ansible-infra-automation

# Installer les collections et roles requis
ansible-galaxy collection install -r requirements.yml

# Verifier la configuration
ansible all -i inventory/production/hosts.ini --list-hosts

# Tester la connectivite
ansible all -i inventory/production/hosts.ini -m ping

# Deployer l'infrastructure complete
ansible-playbook playbooks/site.yml

# Deployer un composant specifique
ansible-playbook playbooks/05-security-baseline.yml -l web_servers
```

## Utilisation des Playbooks

| Playbook | Cible | Description |
|---|---|---|
| `01-domain-controller.yml` | domain_controllers | Installation AD DC (Samba), DNS, DHCP |
| `02-web-server.yml` | web_servers | Deploiement Nginx/Apache, PHP, certificats SSL |
| `03-database-server.yml` | database_servers | Installation PostgreSQL/MySQL, replication, backup |
| `04-monitoring.yml` | monitoring | Deploiement Zabbix agent, Prometheus, Grafana |
| `05-security-baseline.yml` | all | Hardening complet (SSH, firewall, auditd, sysctl) |
| `06-backup-client.yml` | all | Sauvegardes automatisees et chiffrees |
| `99-healthcheck.yml` | all | Validation post-deploiement et diagnostics |

### Exemples de commandes

```bash
# Deployer un controleur de domaine
ansible-playbook playbooks/01-domain-controller.yml -i inventory/production/hosts.ini

# Appliquer le hardening de securite
ansible-playbook playbooks/05-security-baseline.yml -i inventory/production/hosts.ini

# Deployer les agents de monitoring
ansible-playbook playbooks/04-monitoring.yml -i inventory/production/hosts.ini -l web_servers

# Executer le health check complet
ansible-playbook playbooks/99-healthcheck.yml -i inventory/production/hosts.ini -v

# Deployer avec des variables customisees
ansible-playbook playbooks/02-web-server.yml -e "nginx_port=8080 ssl_enabled=true"
```

## Structure du Projet

```
ansible-infra-automation/
├── ansible.cfg              # Configuration Ansible
├── requirements.yml         # Dependances (collections, roles)
├── inventory/               # Inventaires et variables
│   ├── production/          # Environnement de production
│   │   ├── hosts.ini        # Definition des hotes
│   │   └── group_vars/      # Variables par groupe
│   └── staging/             # Environnement de staging
├── playbooks/               # Playbooks de deploiement
│   ├── site.yml             # Playbook maitre
│   ├── 01-domain-controller.yml
│   ├── 02-web-server.yml
│   ├── 03-database-server.yml
│   ├── 04-monitoring.yml
│   ├── 05-security-baseline.yml
│   ├── 06-backup-client.yml
│   └── 99-healthcheck.yml
├── roles/                   # Roles Ansible
│   ├── common/              # Configuration commune
│   ├── domain_controller/   # Active Directory
│   ├── web_server/          # Serveurs web
│   ├── database_server/     # Bases de donnees
│   ├── security_hardening/  # Hardening
│   ├── monitoring_agent/    # Agents de supervision
│   └── backup_client/       # Clients de sauvegarde
├── docs/                    # Documentation
│   ├── ARCHITECTURE.md
│   ├── GETTING-STARTED.md
│   └── PLAYBOOKS.md
└── scripts/                 # Scripts utilitaires
    ├── bootstrap-ansible.sh
    └── encrypt-vault.sh
```

## Securite

- Tout le trafic SSH est configure avec des algorithmes modernes (ed25519, aes256-gcm)
- Les mots de passe et secrets sont chiffres avec Ansible Vault
- Le firewall est configure en mode restrictif (deny by default)
- Les serveurs sont hardenises selon les recommandations CIS Level 2
- Les sauvegardes sont chiffrees en transit et au repos
- Les logs sont centralises et analyses automatiquement

## Auteur

**Louis Denis RAZAFIMANDIMBY**
- Infrastructure & DevOps Engineer
- GitHub: [razafimandimby-IT](https://github.com/razafimandimby-IT)

## Licence

Ce projet est distribue sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus d'informations.