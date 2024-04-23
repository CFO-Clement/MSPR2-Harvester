# Guide d'installation de TimescaleDB avec Prometheus

Ce guide vous explique comment installer TimescaleDB et le configurer pour travailler avec Prometheus.

## Installation de TimescaleDB

### Prérequis

1. Ouvrez une session en tant que superutilisateur :
   ```bash
   sudo su -
   ```

2. Mettez à jour les paquets disponibles et installez les dépendances nécessaires :
   ```bash
   apt update
   apt install gnupg postgresql-common apt-transport-https lsb-release wget
   /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
   ```

3. Ajoutez le dépôt TimescaleDB à votre système :
   ```bash
   echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list
   wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
   apt update
   apt install timescaledb-2-postgresql-12
   ```

### Initialisation

Initialisez TimescaleDB sur votre cluster PostgreSQL :
```bash
sudo timescaledb-tune --quiet --yes
```

## Configuration de TimescaleDB pour Prometheus

### Configuration de la base de données

1. Redémarrez PostgreSQL et connectez-vous :
   ```bash
   systemctl restart postgresql
   sudo -u postgres psql
   ```

2. Créez la base de données pour Prometheus :
   ```sql
   CREATE DATABASE prometheus_data;
   ```

3. Configurez le mot de passe pour l'utilisateur `postgres` et préparez la base de données :
   ```psql
   \password postgres
   \c prometheus_data
   CREATE EXTENSION IF NOT EXISTS timescaledb;
   \q
   ```

### Modification des configurations réseau

1. Ouvrez le fichier `pg_hba.conf` avec un éditeur de texte pour permettre les connexions de n'importe quelle adresse IP :
   ```bash
   sudo vim /etc/postgresql/12/main/pg_hba.conf
   # Ajoutez à la fin du fichier :
   host all all 0.0.0.0/0 md5
   ```

2. Modifiez `postgresql.conf` pour écouter sur toutes les interfaces :
   ```bash
   sudo vim /etc/postgresql/12/main/postgresql.conf
   # Changez ou décommentez la ligne :
   listen_addresses = '*'
   ```

3. Redémarrez PostgreSQL pour appliquer les modifications :
   ```bash
   sudo systemctl restart postgresql
   ```

## Installation de l'adaptateur Prometheus

1. Préparez votre environnement pour l'installation de l'adaptateur :
   ```bash
   export PATH="/usr/lib/postgresql/12/bin:$PATH"
   sudo apt install make libpq-dev build-essential postgresql-server-dev-12
   git clone https://github.com/timescale/pg_prometheus
   cd pg_prometheus
   make
   make install
   ```

2. Configurez `postgresql.conf` pour charger les extensions nécessaires et redémarrez PostgreSQL :
   ```bash
   # Ajoutez dans le fichier /etc/postgresql/12/main/postgresql.conf :
   shared_preload_libraries = 'timescaledb,pg_prometheus'
   systemctl restart postgresql
   ```

3. Créez la table nécessaire dans la base de données :
   ```bash
   sudo -u postgres psql
   \c prometheus_data
   CREATE EXTENSION pg_prometheus;
   SELECT create_prometheus_table('metrics');
   \q
   ```

4. Installez et lancez l'adaptateur Prometheus :
   ```bash
   wget https://github.com/timescale/prometheus-postgresql-adapter/releases/download/v0.6.0/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz
   tar -xf prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz
   ./prometheus-postgresql-adapter -pg-host=localhost -pg-port=5432 -pg-user=postgres -pg-password=password -pg-database=prometheus_data -web-listen-address=:9201
   ```

Ce guide devrait vous aider à configurer TimescaleDB et Prometheus de manière efficace et sécurisée.