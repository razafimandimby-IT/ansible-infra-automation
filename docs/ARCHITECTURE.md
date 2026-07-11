# Architecture Technique

## Vue d'ensemble

L'architecture de ce projet suit le modele **Infrastructure as Code (IaC)** en utilisant Ansible comme moteur d'automatisation. Chaque composant de l'infrastructure est defini de maniere declarative dans des playbooks et roles Ansible, versionnes dans Git, et deployes de maniere reproductible.

## Diagramme d'architecture

```
+----------------------------------------------------------------------------------+
|                         ANSIBLE CONTROL NODE                                     |
|                    (Linux / WSL / CI/CD Runner)                                  |
|                                                                                  |
|  +------------------+  +------------------+  +-------------------------------+  |
|  |   ansible.cfg    |  |   playbooks/     |  |   roles/                     |  |
|  |   inventory/     |  |   site.yml       |  |   +-- common                 |  |
|  |   requirements   |  |   01-*.yml       |  |   +-- domain_controller      |  |
|  +------------------+  |   02-*.yml       |  |   +-- web_server             |  |
|                        |   03-*.yml       |  |   +-- database_server        |  |
|                        |   04-*.yml       |  |   +-- security_hardening     |  |
|                        |   05-*.yml       |  |   +-- monitoring_agent       |  |
|                        |   06-*.yml       |  |   +-- backup_client          |  |
|                        |   99-*.yml       |  +-------------------------------+  |
|                        +------------------+                                     |
+-----------------------------------------|----------------------------------------+
                                          | SSH (port 22)
                                          | Public key authentication
                                          |
         +--------------------------------+--------------------------------+
         |                                |                                |
         v                                v                                v
+------------------+          +------------------+          +------------------+
|  DMZ / PUBLIC    |          |  APPLICATION     |          |  DATA / STORAGE  |
|                  |          |                  |          |                  |
| [loadbalancers]  |          | [web_servers]    |          | [database_servers]|
|  - HAProxy       |          |  - Nginx         |          |  - PostgreSQL    |
|  - Keepalived    |          |  - PHP-FPM       |          |  - MySQL/MariaDB |
|                  |          |  - Certbot/SSL   |          |  - Replication   |
+------------------+          |  - Application   |          |  - PgBouncer     |
                              +------------------+          |  - Barman        |
                                                             +------------------+
         +------------------+          +------------------+
         |  IDENTITY        |          |  OBSERVABILITY   |
         |                  |          |                  |
         |[domain_controllers]         | [monitoring]     |
         |  - Samba AD DC   |          |  - Zabbix        |
         |  - DNS           |          |  - Prometheus    |
         |  - Kerberos KDC  |          |  - Grafana       |
         |  - LDAP          |          |  - Log shipping  |
         +------------------+          +------------------+

         +------------------+
         |  BACKUP          |
         |                  |
         | [backup_servers] |
         |  - Borg repo     |
         |  - Rsync target  |
         |  - Retention     |
         +------------------+
```

## Flux de deploiement

```
1. Preparation
   ├── Inventaire (inventory/)
   ├── Variables (group_vars/)
   ├── Collections (requirements.yml)
   └── Configuration Ansible (ansible.cfg)

2. Executions
   ├── Phase 1: common          → Configuration de base (NTP, DNS, users, packages)
   ├── Phase 2: security        → Hardening CIS (SSH, firewall, auditd, sysctl)
   ├── Phase 3: domain          → Active Directory (Samba AD DC, DNS, KDC)
   ├── Phase 4: web             → Serveurs web (Nginx, PHP-FPM, SSL)
   ├── Phase 5: database        → Bases de donnees (PostgreSQL, replication)
   ├── Phase 6: monitoring      → Supervision (Zabbix, Prometheus, logs)
   ├── Phase 7: backup          → Sauvegardes automatisees et chiffrees
   └── Phase 8: validation      → Health checks et rapports de conformite

3. Maintenance continue
   ├── Mise a jour securisee automatique (unattended-upgrades)
   ├── Verification integrite fichiers (AIDE)
   ├── Scan securite hebdomadaire (RKhunter, Chkrootkit)
   ├── Rotation des logs (logrotate)
   ├── Sauvegardes quotidiennes (BorgBackup)
   └── Rapports de conformite (Logwatch)
```

## Environnements

### Production
- Reseau: 192.168.0.0/16
- Domaine: example.internal
- Haute disponibilite: DC x2, Web x3, DB avec replication
- Securite maximale: CIS Level 2 hardening

### Staging
- Reseau: 10.0.0.0/16
- Domaine: staging.example.internal
- Taille reduite: DC x1, Web x2, DB x1
- Securite allegee pour debug

## Securite

### Defense en profondeur

1. **Perimetre**: Firewall (UFW) avec regles restrictives
2. **Reseau**: Kernel hardening (sysctl), TCP SYN cookies, ICMP filtering
3. **Acces**: SSH avec cles Ed25519, PAM, fail2ban, auditd
4. **Systeme**: AppArmor, AIDE, SUID/SGID monitoring
5. **Donnees**: Chiffrement des sauvegardes, TLS pour les bases de donnees
6. **Supervision**: Logs centralises, alertes, rapports automatiques

### Conformite

- CIS Benchmarks Level 2
- Recommandations ANSSI
- Securite defensive (deny by default)
- Journalisation exhaustive (auditd)