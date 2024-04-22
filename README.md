# L'Harvester (Client)

**Objectif** : Collecter des métriques de manière efficace et sécurisée depuis les machines clientes.

## Étapes de développement :

1. **Installation de Prometheus Node Exporter** :
   - Installer Node Exporter sur chaque machine cliente.
   - Configurer Node Exporter pour qu'il expose les métriques de la machine.

2. **Configuration de Prometheus pour la collecte des données** :
   - Installer et configurer Prometheus sur un serveur central.
   - Ajouter des configurations à Prometheus pour découvrir les clients et collecter les métriques via Node Exporter.

3. **Implémentation de la télémaintenance avec Shellinabox** :
   - Installer Shellinabox (Client) sur le serveur où tourne le Nester.

## Clients Prometheus
```
Harvester/
│
├── ansible/
│   ├── roles/
│   │   ├── prometheus/
│   │   │   ├── tasks/
│   │   │   │   ├── main.yml      # Tâches pour installer et configurer Prometheus
│   │   │   ├── handlers/
│   │   │   │   ├── main.yml      # Handlers pour redémarrer Prometheus après configuration
│   │   │   ├── templates/
│   │   │   │   ├── prometheus.yml.j2  # Template pour prometheus.yml
│   │   │   ├── defaults/
│   │   │   │   ├── main.yml      # Valeurs par défaut pour les variables
│   │   │   ├── vars/
│   │   │   │   ├── main.yml      # Variables spécifiques à l'environnement
│   │   │   └── meta/
│   │   │       └── main.yml      # Dépendances de rôle, si nécessaire
│   │   └── clients/
│   │       ├── tasks/
│   │       │   ├── main.yml      # Tâches pour configurer les clients Prometheus
│   ├── playbook.yml
│   └── hosts                    # Inventaire Ansible
│
└── README.md
```
Simplification -> On manque de temps pour faire ca bien ->
## Clients Prometheus
```
prometheus_ansible/
│
├── files/
│   └── prometheus.yml
├── playbook.yml
└── setup.sh
```
