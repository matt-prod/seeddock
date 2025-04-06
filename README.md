# SeedDock

SeedDock est un installeur d’infrastructure minimaliste et modulaire, basé sur Ansible et Docker, conçu pour poser les fondations d’un environnement d’hébergement personnel ou professionnel.

## Fonctionnalités

- Installation automatique de Git, Docker, et Ansible
- Configuration d’un conteneur `traefik` avec certificat autosigné
- Déploiement de SeedDock Manager (SDM) pour la suite de la configuration via interface web
- Utilisation d’un fichier `vault` chiffré (Ansible Vault) pour stocker les informations sensibles
- Reprise automatique de l’installation après reconnexion SSH

## Installation rapide

```bash
bash <(curl -sSL https://raw.githubusercontent.com/matt-prod/seeddock/main/install.sh)
```

## Structure

- `install.sh` : script initial à lancer sur une machine Debian/Ubuntu fraîche
- `seeddock.sh` : script de gestion d'étapes d’installation
- `includes/` : fonctions, variables, templates Ansible
- `SDM/` : configuration Ansible et inventaire du manager

## Roadmap

- [x] Bootstrap automatique
- [x] Certificat autosigné
- [x] Déploiement de SDM
- [ ] Intégration complète du domaine et DNS
- [ ] Catalogue d’apps installables via Ansible

## Licence

SeedDock est distribué sous licence [GNU GPLv3](LICENSE), avec une clause additionnelle interdisant tout usage commercial sans autorisation écrite préalable de l’auteur.

> Toute réutilisation dans un projet commercial, SaaS, hébergement ou service à but lucratif est interdite sans consentement explicite.
