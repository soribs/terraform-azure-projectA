# Azure Infrastructure Deployment with Terraform 🚀

Ce projet déploie une infrastructure Linux complète et sécurisée sur Azure en utilisant **Terraform**. Il illustre les principes de l'Infrastructure as Code (IaC) : reproductibilité, sécurité et modularité.

## 🏗️ Architecture du Projet

L'infrastructure déployée comprend les composants suivants :
* **Resource Group** : Conteneur logique pour toutes les ressources.
* **Networking** : 
    * Un Réseau Virtuel (VNet) et un Subnet dédié.
    * Une Adresse IP Publique pour l'accès externe.
* **Sécurité (NSG)** : Un Network Security Group configuré pour autoriser uniquement les flux **SSH (Port 22)**.
* **Compute** : Une machine virtuelle **Ubuntu 22.04 LTS** (Série D2s_v3) avec authentification par clé SSH.



## 🛠️ Prérequis

* Un compte **Azure** avec une souscription active.
* **Terraform** installé (v1.0+).
* **Azure CLI** installé et configuré (`az login`).
* Une paire de clés SSH générée localement (`~/.ssh/admin_ssh.pub`).

## 🚀 Utilisation

1. **Initialiser le projet** (téléchargement des providers Azure) :
   ```bash
   terraform init

🔍 Dépannage & Retours d'expérience (Lessons Learned)
Pendant le développement, j'ai rencontré et résolu des défis techniques qui ont enrichi ma compréhension de Terraform et Azure :

Conflits de ressources (State Management) : J'ai appris l'importance de séparer la définition du azurerm_subnet du bloc azurerm_virtual_network. 
Une double définition provoque des erreurs de type "Resource already exists" car Terraform tente de créer deux fois le même objet API.

Disponibilité des SKUs (Quotas Azure) : Certaines régions (comme uksouth) peuvent avoir des restrictions sur certaines tailles de VM (Standard_B1s). 
J'ai adapté le code pour permettre un basculement rapide vers spaincentral ou changer de série (ex: Standard_D2s_v3) via les variables.

Chaînage de dépendances : La mise en place de l'IP Publique nécessite un ordre précis : Création de l'IP -> Association à la NIC -> Création de la VM. Terraform gère cela via l'arbre de dépendances des IDs de ressources.
