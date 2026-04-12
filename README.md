# 🚀 Terraform Azure — Project A

> Déploiement d'une infrastructure Linux sécurisée sur Azure via Infrastructure as Code (IaC) avec Terraform.

![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-7B42BC?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-AzureRM-0078D4?logo=microsoftazure)
![OS](https://img.shields.io/badge/OS-Ubuntu%2022.04%20LTS-E95420?logo=ubuntu)
![Status](https://img.shields.io/badge/Status-In%20Progress-yellow)

---

## 📋 Table des matières

- [Vue d'ensemble](#-vue-densemble)
- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Structure du projet](#-structure-du-projet)
- [Variables](#-variables)
- [Déploiement](#-déploiement)
- [Monitoring](#-monitoring)
- [Sécurité](#-sécurité)
- [Lessons Learned](#-lessons-learned)

---

## 🌐 Vue d'ensemble

Ce projet déploie une infrastructure Azure complète et sécurisée pour héberger une machine virtuelle Linux avec supervision intégrée. Il illustre les bonnes pratiques de l'IaC : séparation des responsabilités par fichier, gestion des dépendances explicites, et usage d'une identité managée pour l'authentification sans secret.

**Région de déploiement :** `Spain Central`  
**Environnement :** `dev`  
**Naming convention :** `<type>-<project>-<env>-<region>-<index>`

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Group                           │
│                rg-projectA-dev-spain-001                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                Virtual Network (VNet)                │   │
│  │                  10.0.0.0/16                         │   │
│  │                                                      │   │
│  │   ┌──────────────┐    ┌───────────────────────────┐  │   │
│  │   │   Subnet VM  │    │     Subnet Bastion        │  │   │
│  │   │ 10.0.0.0/24  │    │      10.0.1.0/24          │  │   │
│  │   │              │    │                           │  │   │
│  │   │  ┌────────┐  │    │  ┌─────────────────────┐  │  │   │
│  │   │  │  VM    │  │    │  │   Azure Bastion     │  │  │   │
│  │   │  │ Linux  │◄─┼────┼──│  (accès SSH sécurisé│  │  │   │
│  │   │  │Ubuntu  │  │    │  │   sans IP publique) │  │  │   │
│  │   │  └───┬────┘  │    │  └─────────────────────┘  │  │   │
│  │   │      │ NSG   │    └───────────────────────────┘  │   │
│  │   └──────┼───────┘                                   │   │
│  └──────────┼────────────────────────────────────────── ┘   │
│             │                                               │
│  ┌──────────▼──────────┐   ┌─────────────────────────────┐  │
│  │   Data Disk (HDD)   │   │     Storage Account         │  │
│  │  (disque additionel)│   │   (réception des logs)      │  │
│  └─────────────────────┘   └────────────┬────────────────┘  │
│                                         │                   │
│  ┌──────────────────────────────────────▼────────────────┐  │
│  │                     Monitoring                        │  │
│  │  User Assigned Identity → AMA Agent → DCR → Blob      │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Ressources déployées

| Ressource | Nom | Description |
|---|---|---|
| Resource Group | `rg-projectA-dev-spain-001` | Conteneur de toutes les ressources |
| Virtual Network | configurable via variable | VNet `10.0.0.0/16` avec 2 subnets |
| Subnet VM | `snet-subnet` | `10.0.0.0/24` pour la VM |
| Subnet Bastion | auto | `10.0.1.0/24` pour Azure Bastion |
| Network Security Group | `NSG-dev-spain-001` | Règle SSH (port 22) uniquement |
| Public IP | `public-IP-spain-001` | IP pour Azure Bastion |
| Linux VM | `vm-linux-dev-spain-001` | Ubuntu 22.04 LTS — Standard_D2s_v3 |
| Data Disk | — | Disque additionnel attaché à la VM |
| Bastion | — | Accès SSH sécurisé sans exposition directe |
| Storage Account | `stprojectadevspain` | Réception des logs / syslog |
| User Assigned Identity | `uai-projectA-dev-spain-001` | Identité managée pour AMA |
| Data Collection Rule | `linux-vm-rule` | Collecte des syslog Linux |
| VM Extension (AMA) | `Linux-agent` | Azure Monitor Agent |

---

## ✅ Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.0`
- [Azure CLI](https://learn.microsoft.com/fr-fr/cli/azure/install-azure-cli) installé et configuré
- Un compte Azure avec une **souscription active**
- Une paire de clés SSH générée localement

```bash
# Authentification Azure
az login

# Générer une paire de clés SSH si nécessaire
ssh-keygen -t rsa -b 4096 -f ~/.ssh/admin_ssh
```

---

## 📁 Structure du projet

```
terraform-azure-projectA/
│
├── provider.tf                  # Configuration du provider AzureRM
├── variables.tf                 # Déclaration de toutes les variables
│
├── resource_group.tf            # Groupe de ressources Azure
├── virtual_network.tf           # VNet
├── subnets.tf                   # Subnets (VM + Bastion)
├── network_security_group.tf    # NSG + règles de sécurité
├── Public_IP.tf                 # Adresse IP publique (Bastion)
│
├── linux_virtual_machine.tf     # VM Linux + NIC + extension AMA
├── disk.tf                      # Disque de données additionnel
├── bastion.tf                   # Azure Bastion Host
│
├── storage_account.tf           # Compte de stockage + container syslog
├── identity.tf                  # User Assigned Managed Identity
├── monitor.tf                   # DCR + association DCR-VM
│
├── .gitignore
└── .terraform.lock.hcl
```

---

## ⚙️ Variables

Toutes les variables sont définies dans `variables.tf`. Les variables sans valeur par défaut **doivent** être fournies au déploiement.

| Variable | Type | Défaut | Description |
|---|---|---|---|
| `resource_group_name` | `string` | `rg-projectA-dev-spain-001` | Nom du Resource Group |
| `virtual_network_name` | `string` | — | Nom du VNet **(requis)** |
| `location_name` | `string` | `Spain central` | Région Azure |
| `subscription_id` | `string` | — | ID de la souscription Azure **(requis)** |
| `username` | `string` | — | Nom d'utilisateur admin de la VM **(requis)** |
| `vm-size` | `string` | `Standard_D2s_v3` | Taille de la VM |
| `address_space` | `set(string)` | `["10.0.0.0/16"]` | Plage d'adresses du VNet |
| `address_prefixes` | `list(string)` | `["10.0.0.0/24","10.0.1.0/24"]` | Sous-réseaux |
| `source_image_reference` | `map(string)` | Ubuntu 22.04 LTS | Image de la VM |
| `os_disk` | `map(string)` | ReadWrite / Standard_LRS | Configuration du disque OS |
| `tags` | `map(string)` | `project=projectA, env=dev` | Tags Azure |

Créer un fichier `terraform.tfvars` (non commité) pour les valeurs sensibles :

```hcl
# terraform.tfvars — NE PAS COMMITER
subscription_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
username             = "adminuser"
virtual_network_name = "vnet-projectA-dev-spain-001"
```

---

## 🚀 Déploiement

```bash
# 1. Initialiser Terraform (téléchargement des providers)
terraform init

# 2. Vérifier le plan de déploiement
terraform plan

# 3. Appliquer l'infrastructure
terraform apply

# 4. Détruire l'infrastructure (si nécessaire)
terraform destroy
```

---

## 📊 Monitoring

L'agent **Azure Monitor Agent (AMA)** est installé via une extension VM. Il collecte les syslog Linux et les envoie vers le Storage Account via une **Data Collection Rule (DCR)**.

### Composants du monitoring

```
VM (AMA Extension)
    │
    ▼
Data Collection Rule (linux-vm-rule)
    │  data_sources: syslog { facility=*, level=* }
    │  stream: Microsoft-Syslog
    ▼
Storage Account → Container "syslog"
```

### Chaîne de permissions (RBAC)

```
User Assigned Identity
    ├── Storage Blob Data Contributor  → Storage Account  (écriture des logs)
    └── Monitoring Contributor         → VM               (accès monitoring)
```

### Vérifier l'état de l'agent sur la VM

```bash
# Statut du service
systemctl status azuremonitoragent

# Logs en temps réel
journalctl -u azuremonitoragent -f

# Erreurs internes de l'agent
tail -f /var/opt/microsoft/azuremonitoragent/log/mdsd.err

# Générer un event syslog de test
logger -p syslog.info "Test AMA monitoring message"
```

---

## 🔒 Sécurité

- **Accès SSH** : via Azure Bastion uniquement — aucune exposition directe de la VM sur Internet
- **Authentification VM** : clé SSH uniquement (pas de mot de passe)
- **Identité managée** : User Assigned Identity — aucune clé ou secret stocké dans le code
- **NSG** : seul le port 22 est autorisé en entrée
- **Secrets** : `subscription_id` et `username` exclus du dépôt via `.gitignore` + `terraform.tfvars`

---

## 📚 Lessons Learned

### Séparation subnet / VNet
Définir `azurerm_subnet` séparément de `azurerm_virtual_network` évite les conflits de type *"Resource already exists"* — Terraform tenterait sinon de créer deux fois le même objet.

### Disponibilité des SKUs par région
Certaines régions comme `uksouth` peuvent avoir des restrictions de quota sur certaines tailles de VM (ex: `Standard_B1s`). La variable `vm-size` permet de basculer rapidement vers une série disponible (`Standard_D2s_v3` en `spaincentral`).

### Ordre des dépendances avec `depends_on`
L'extension AMA doit démarrer **après** la création des role assignments, sinon l'agent tente de s'authentifier sans avoir les droits. Sans `depends_on`, Terraform peut paralléliser ces opérations et provoquer un échec silencieux.

### Compatibilité stream / destination dans les DCR
`Microsoft-Syslog` n'est **pas compatible** avec `storage_blob_direct`. Ce stream requiert une destination `log_analytics`. Pour envoyer vers un Blob Storage, il faut utiliser un stream custom.

| Stream | log_analytics | storage_blob_direct |
|---|---|---|
| `Microsoft-Syslog` | ✅ | ❌ |
| `Microsoft-Perf` | ✅ | ❌ |
| `Microsoft-Event` | ✅ | ✅ |
| Custom streams | ✅ | ✅ |

---

## 📎 Références

- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Monitor Agent — Documentation](https://learn.microsoft.com/fr-fr/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Data Collection Rules](https://learn.microsoft.com/fr-fr/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Azure Bastion](https://learn.microsoft.com/fr-fr/azure/bastion/bastion-overview)
