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

### TimescaleDB
Pour installer TimescaleDB et le configurer pour fonctionner avec Prometheus, suivez ces étapes :

Sur la machine B, vous pouvez installer TimescaleDB en suivant les instructions fournies dans leur documentation officielle. Voici comment vous pouvez procéder :

1. **Installer TimescaleDB** :

   ```bash
   sudo su - 
   apt update
   apt install gnupg postgresql-common apt-transport-https lsb-release wget
   /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
   echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list
   wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
   apt update
   apt install timescaledb-2-postgresql-14
   ```

2. **Initialiser TimescaleDB** :

   Après l'installation, vous devez initialiser TimescaleDB sur votre cluster PostgreSQL. Vous pouvez le faire en exécutant la commande suivante :

   ```bash
   sudo timescaledb-tune
   ```

#### Configurer TimescaleDB pour Prometheus :

Une fois que TimescaleDB est installé, vous devez créer une base de données dans laquelle Prometheus peut écrire ses données. Voici comment vous pouvez procéder :

1. **Connectez-vous à PostgreSQL** :

   ```bash
   systemctl restart postgresql
   sudo -u postgres psql
   ```

2. **Créez une base de données** :

   ```sql
   CREATE DATABASE prometheus_data;
   ```

3. **Créez un utilisateur et attribuez-lui des privilèges sur la base de données** :

  ```psql
  \c prometheus_data
  ```

   ```sql
   CREATE EXTENSION IF NOT EXISTS timescaledb;
   CREATE USER prometheus_user WITH PASSWORD 'votre_mot_de_passe';
   GRANT ALL PRIVILEGES ON DATABASE prometheus_data TO prometheus_user;
   ```

4. **Sortez de PostgreSQL** :

   ```sql
   \q
   ```

#### Configuration de `remote_write` dans Prometheus :

Sur la machine A, modifiez votre fichier `prometheus.yml` pour inclure `remote_write` avec les détails de votre base de données TimescaleDB.

```yaml
remote_write:
  - url: "http://machine_b_ip:port/write"
```

Assurez-vous de remplacer `"http://prometheus_user:prometheus@192.168.1.218:5432/write""` par l'URL réelle de l'endpoint d'écriture distant de votre base de données TimescaleDB.

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
