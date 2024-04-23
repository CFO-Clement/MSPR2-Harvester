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

#### Configuration de `remote_write` dans Prometheus :

Sur la machine A, modifiez votre fichier `prometheus.yml` pour inclure `remote_write` avec les détails de votre base de données TimescaleDB.

```yaml
remote_write:
  - url: "http://posgres:password@192.168.122.20:9201/write"
```

Assurez-vous de remplacer `http://posgres:password@192.168.122.20:9201/write` par l'URL réelle de l'endpoint d'écriture distant de votre base de données TimescaleDB.

#### Redémarrez Prometheus :

Après avoir modifié `prometheus.yml`, redémarrez le service Prometheus pour appliquer les modifications.

```bash
sudo systemctl restart prometheus
```

Une fois cela fait, Prometheus commencera à écrire des données dans votre base de données TimescaleDB sur la machine B. Vous pouvez maintenant configurer Grafana sur la machine C pour visualiser ces données en utilisant TimescaleDB comme source de données.

#### Pour verifier:
```bash
sudo systemctl status prometheus
sudo journalctl -u prometheus
```
interface prometheus sur `http://localhost:9090`

#TODO
Pour le moment, la remplate de config de prometheus es override car ca marche pas
Variabilier le playbook prometheus (meme sur le job_name pour pouvoir identifier les nodes)
