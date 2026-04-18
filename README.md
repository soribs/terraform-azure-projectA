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
**Environnement :** `prod`  
**Naming convention :** `<type>-<project>-<env>-<region>-<index>`

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         Resource Group                               │
│                     rg-projectA-prod-spain-001                        │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐    │
│  │                   Virtual Network (VNet)                     │    │
│  │                       10.0.0.0/16                            │    │
│  │                                                              │    │
│  │  ┌─────────────────┐  ┌──────────────────┐  ┌─────────────┐  │    │
│  │  │   Subnet VM     │  │  Subnet Bastion  │  │ NAT Subnet  │  │    │
│  │  │  10.0.0.0/24    │  │  10.0.1.0/24     │  │ 10.0.2.0/24 │  │    │
│  │  │                 │  │                  │  └─────────────┘  │    │
│  │  │  ┌───────────┐  │  │  ┌────────────┐  │                   │    │
│  │  │  │  VM Linux │  │  │  │   Azure    │  │                   │    │ 
│  │  │  │ Ubuntu    │◄─┼──┼──│   Bastion  │  │                   │    │ 
│  │  │  │ (no PIP)  │  │  │  │            │  │                   │    │ 
│  │  │  └─────┬─────┘  │  │  └────────────┘  │                   │    │
│  │  │  NSG   │        │  └──────────────────┘                   │    │
│  │  └────────┼────────┘                                         │    │
│  └───────────┼──────────────────────────────────────────────────┘    │
│              │ (sortie internet)                                     │
│              ▼                                                       │
│  ┌───────────────────────┐                                           │
│  │     NAT Gateway       │ ←── Public IP : 158.158.32.68             │
│  │  (outbound internet)  │                                           │
│  └───────────────────────┘                                           │
│                                                                      │
│  ┌──────────────────────┐   ┌──────────────────────────────────────┐ │
│  │   Data Disk (HDD)    │   │          Storage Account             │ │
│  │  (disque additionnel)│   │       (réception des logs)           │ │
│  └──────────────────────┘   └────────────────┬─────────────────────┘ │
│                                              │                       │
│  ┌───────────────────────────────────────────▼───────────────────┐   │
│  │                        Monitoring                             │   │
│  │     User Assigned Identity → AMA Agent → DCR → Blob           │   │
│  └───────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

### Flux réseau

```
[Entrée SSH]      Internet → Azure Bastion (PIP) → VM (IP privée uniquement)
[Sortie internet] VM → NAT Gateway (158.158.32.68) → Internet
```

### Ressources déployées

| Ressource | Nom | Description |
|---|---|---|
| Resource Group | `rg-projectA-prod-spain-001` | Conteneur de toutes les ressources |
| Virtual Network | configurable via variable | VNet `10.0.0.0/16` avec 3 subnets |
| Subnet VM | `snet-subnet` | `10.0.0.0/24` — héberge la VM |
| Subnet Bastion | `AzureBastionSubnet` | `10.0.1.0/24` — réservé Azure Bastion |
| Subnet NAT | `nat-subnet-projectA-prod-spain-001` | `10.0.2.0/24` — dédié NAT Gateway |
| NSG | `NSG-prod-spain-001` | Attaché au subnet VM |
| Public IP Bastion | `public-IP-spain-001` | IP d'entrée pour Azure Bastion uniquement |
| Public IP NAT | `Nat-Gateway-PIP` | `158.158.32.68` — IP de sortie internet |
| NAT Gateway | `NatGateway` | Sortie internet centralisée et sécurisée |
| Linux VM | `vm-linux-prod-spain-001` | Ubuntu 22.04 LTS — Standard_D2s_v3 — sans IP publique directe |
| Data Disk | — | Disque additionnel attaché à la VM |
| Azure Bastion | — | Accès SSH sécurisé sans exposition directe |
| Storage Account | `stprojectaprodspain` | Réception des logs / syslog |
| User Assigned Identity | `uai-projectA-prod-spain-001` | Identité managée pour AMA |
| Data Collection Rule | `linux-vm-rule` | Collecte des syslog Linux |
| VM Extension (AMA) | `Linux-agent` | Azure Monitor Agent v2.15+ |

---

## ✅ Prérequis

- [Terraform](https://prodeloper.hashicorp.com/terraform/install) `>= 1.0`
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
├── virtual_network.tf           # VNet (dns_servers = [] → Azure DNS)
├── subnets.tf                   # Subnets VM + Bastion + NAT
├── network_security_group.tf    # NSG + règles de sécurité
├── Public_IP.tf                 # IP publique Bastion + IP publique NAT Gateway
│
├── nat_gateway.tf               # NAT Gateway + associations subnet + IP
├── linux_virtual_machine.tf     # VM Linux + NIC (sans IP publique) + extension AMA
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
| `resource_group_name` | `string` | `rg-projectA-prod-spain-001` | Nom du Resource Group |
| `virtual_network_name` | `string` | — | Nom du VNet **(requis)** |
| `location_name` | `string` | `Spain central` | Région Azure |
| `subscription_id` | `string` | — | ID de la souscription Azure **(requis)** |
| `username` | `string` | — | Nom d'utilisateur admin de la VM **(requis)** |
| `vm-size` | `string` | `Standard_D2s_v3` | Taille de la VM |
| `address_space` | `set(string)` | `["10.0.0.0/16"]` | Plage d'adresses du VNet |
| `address_prefixes` | `list(string)` | `["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24"]` | Sous-réseaux (VM, Bastion, NAT) |
| `dns_servers` | `set(string)` | `[]` | DNS du VNet — vide = Azure DNS `168.63.129.16` |
| `source_image_reference` | `map(string)` | Ubuntu 22.04 LTS | Image de la VM |
| `os_disk` | `map(string)` | ReadWrite / Standard_LRS | Configuration du disque OS |
| `tags` | `map(string)` | `project=projectA, env=prod` | Tags Azure |

Créer un fichier `terraform.tfvars` (non commité) pour les valeurs sensibles :

```hcl
# terraform.tfvars — NE PAS COMMITER
subscription_id      = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
username             = "adminuser"
virtual_network_name = "vnet-projectA-prod-spain-001"
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

### Vérifier la connectivité internet depuis la VM

Après déploiement, connecte-toi via Azure Bastion et teste :

```bash
# Vérifier l'IP de sortie (doit afficher l'IP du NAT Gateway)
curl ifconfig.me

# Test DNS + HTTP
curl https://google.com

# Vérifier le DNS utilisé par la VM
resolvectl status | grep "DNS Servers"
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

> ⚠️ Le `depends_on` sur l'extension AMA garantit que les role assignments sont créés **avant** que l'agent démarre, évitant tout échec d'authentification silencieux.

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

- **Accès SSH** : via Azure Bastion uniquement — aucune IP publique directe sur la VM
- **Sortie internet** : via NAT Gateway — IP de sortie fixe et traçable (`158.158.32.68`)
- **Authentification VM** : clé SSH uniquement (pas de mot de passe)
- **Identité managée** : User Assigned Identity — aucune clé ou secret dans le code
- **NSG** : attaché au subnet VM, règles outbound Azure par défaut conservées
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

### Public IP sur NIC vs NAT Gateway
Azure applique une **priorité stricte** pour le trafic sortant : une Public IP directement attachée à la NIC écrase le NAT Gateway. La VM n'avait aucun accès internet malgré un NAT Gateway correctement configuré.

```
Priorité Azure (outbound) :
1. Public IP sur la NIC        ← écrase tout le reste ❌
2. Load Balancer outbound rule
3. NAT Gateway                 ← jamais atteint si #1 existe
4. SNAT éphémère Azure
```

**Règle :** la NIC de la VM ne doit **jamais** avoir de Public IP quand un NAT Gateway gère la sortie internet. La `public_ip_address_id` doit être supprimée du bloc `ip_configuration` de la NIC.

### DNS custom inexistants = perte totale de résolution de noms
Définir des `dns_servers` dans le VNet avec des IPs inexistantes (`10.0.0.4`, `10.0.0.5`) bloque toute résolution DNS, même si le routage internet fonctionne parfaitement.

Symptôme trompeur : `ping 8.8.8.8` échoue (ICMP souvent bloqué) mais `curl http://142.250.185.46` fonctionne → le routage est OK, c'est uniquement le DNS qui est cassé.

```hcl
# ✅ Toujours laisser vide pour utiliser le DNS Azure (168.63.129.16)
variable "dns_servers" {
  type    = set(string)
  default = []
}
```

### `address_prefixes` : attention aux index de liste
Chaque subnet référence un index de `address_prefixes`. Si la liste contient moins d'entrées que de subnets, Terraform déploie un subnet avec une plage `null` sans erreur explicite.

```hcl
# ✅ 3 subnets = 3 entrées obligatoires
default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
```

---

## 📎 Références

- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure NAT Gateway](https://learn.microsoft.com/fr-fr/azure/nat-gateway/nat-overview)
- [Azure Monitor Agent](https://learn.microsoft.com/fr-fr/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [Data Collection Rules](https://learn.microsoft.com/fr-fr/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Azure Bastion](https://learn.microsoft.com/fr-fr/azure/bastion/bastion-overview)
- [Azure DNS par défaut (168.63.129.16)](https://learn.microsoft.com/fr-fr/azure/virtual-network/what-is-ip-address-168-63-129-16)
