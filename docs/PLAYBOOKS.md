# Documentation des Playbooks

## Playbook principal

### site.yml

Playbook maitre orchestre le deploiement complet en 8 phases. Execute tous les roles dans l'ordre approprie avec les dependances gerees automatiquement.

```bash
# Deploiement complet
ansible-playbook playbooks/site.yml

# Deploiement avec etape specifique
ansible-playbook playbooks/site.yml --tags security

# Deploiement sur un groupe specifique
ansible-playbook playbooks/site.yml --limit web_servers
```

**Phases:**
| Phase | Nom | Cible |
|---|---|---|
| 1 | common | all |
| 2 | security_hardening | all |
| 3 | domain_controller | domain_controllers |
| 4 | web_server | web_servers |
| 5 | database_server | database_servers |
| 6 | monitoring_agent | monitoring |
| 7 | backup_client | all |
| 8 | healthcheck | all |

---

## Playbooks individuels

### 01-domain-controller.yml

Configure un controleur de domaine Samba Active Directory avec DNS interne, Kerberos KDC, et support DHCP.

**Taches principales:**
- Installation Samba AD DC, Kerberos, Winbind
- Provisionnement du domaine Active Directory
- Configuration des forwarders DNS
- Ouverture des ports firewall pour AD
- Verification Kerberos et DNS

```bash
ansible-playbook playbooks/01-domain-controller.yml
ansible-playbook playbooks/01-domain-controller.yml --limit dc01
```

### 02-web-server.yml

Deploie des serveurs web Nginx avec PHP-FPM, SSL/TLS, et optimise pour les applications.

**Taches principales:**
- Installation Nginx et PHP-FPM
- Configuration vhost HTTP/HTTPS
- Generation Diffie-Hellman params
- Optimisation PHP (OPcache, pool settings)
- Configuration UFW pour HTTP/HTTPS
- Installation Certbot

```bash
ansible-playbook playbooks/02-web-server.yml
ansible-playbook playbooks/02-web-server.yml -e "nginx_port=8080"
```

### 03-database-server.yml

Installe et configure PostgreSQL avec replication, tuning performance, et securisation.

**Taches principales:**
- Installation PostgreSQL
- Tuning performance (shared_buffers, work_mem, etc.)
- Configuration replication streaming
- Creation des bases et utilisateurs
- Configuration PgBouncer
- Kernel parameters pour DB
- Log rotation

```bash
ansible-playbook playbooks/03-database-server.yml
ansible-playbook playbooks/03-database-server.yml --limit db01-primary
```

### 04-monitoring.yml

Deploie les agents de supervision (Zabbix, Prometheus) et configure le shipping des logs.

**Taches principales:**
- Installation Zabbix agent 2
- Configuration TLS pour Zabbix
- Installation Prometheus node_exporter
- Service systemd node_exporter
- Configuration rsyslog pour log shipping
- Shipping TLS ou non-TLS

```bash
ansible-playbook playbooks/04-monitoring.yml
ansible-playbook playbooks/04-monitoring.yml --limit web_servers
```

### 05-security-baseline.yml

Applique un hardening de securite complet conforme aux CIS Benchmarks niveau 2.

**Taches principales:** Voir role security_hardening (50+ taches couvrant SSH, firewall, fail2ban, auditd, sysctl, PAM, mises a jour, services, etc.)

```bash
ansible-playbook playbooks/05-security-baseline.yml
ansible-playbook playbooks/05-security-baseline.yml -t ssh
ansible-playbook playbooks/05-security-baseline.yml --skip-tags firewall
```

### 06-backup-client.yml

Configure des sauvegardes automatisees et chiffrees avec rotation et verification.

**Taches principales:**
- Installation BorgBackup et outils associes
- Creation utilisateur backup
- Generation cle SSH
- Deploiement script de backup
- Configuration cron (quotidien, hebdomadaire, verification mensuelle)
- Logrotate pour logs de backup

```bash
ansible-playbook playbooks/06-backup-client.yml
```

### 99-healthcheck.yml

Effectue une validation comprehensive de l'infrastructure post-deploiement.

**Verifications incluses:**
- Connectivite (ping, DNS, NTP, gateway)
- Services (SSH, cron, rsyslog, nginx, postgresql, samba)
- Disques (utilisation, inodes)
- Memoire et ressources (RAM, swap, load, processes)
- Securite (firewall, fail2ban, auditd, SSH config, SUID)
- Certificats SSL
- Mises a jour disponibles
- Ports et services reseau
- Generation rapport de conformite

```bash
ansible-playbook playbooks/99-healthcheck.yml
ansible-playbook playbooks/99-healthcheck.yml -v
ansible-playbook playbooks/99-healthcheck.yml --limit web_servers
```

## Tags disponibles

| Tag | Description |
|---|---|
| `common` | Configuration de base commune |
| `security` | Hardening de securite |
| `ssh` | Configuration SSH uniquement |
| `firewall` | Configuration pare-feu |
| `fail2ban` | Configuration fail2ban |
| `auditd` | Configuration auditd |
| `sysctl` | Parametres noyau |
| `domain_controller` | Controleur de domaine |
| `web` | Serveur web |
| `database` | Base de donnees |
| `postgresql` | PostgreSQL uniquement |
| `monitoring` | Supervision |
| `zabbix` | Agent Zabbix |
| `prometheus` | Prometheus node_exporter |
| `backup` | Sauvegardes |
| `verify` | Verification post-deploiement |
| `report` | Generation rapports |