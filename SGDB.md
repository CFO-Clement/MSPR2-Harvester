TimescaleDB
Pour installer TimescaleDB et le configurer pour fonctionner avec Prometheus, suivez ces étapes :

1. **Installer TimescaleDB** :

   ```bash
   sudo su -

   apt update

   apt install gnupg postgresql-common apt-transport-https lsb-release wget

   /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

   echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list

   wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -

   apt update

   apt install timescaledb-2-postgresql-12
   ```

2. **Initialiser TimescaleDB** :

   Après l'installation, vous devez initialiser TimescaleDB sur votre cluster PostgreSQL. Vous pouvez le faire en exécutant la commande suivante :

   ```bash
   sudo timescaledb-tune --quiet --yes
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
mettre password en mdp pour postgres

  ```psql
  \password postgres 
  \c prometheus_data
  ```

   ```sql
   CREATE EXTENSION IF NOT EXISTS timescaledb;
   ```

4. **Sortez de PostgreSQL** :

   ```sql
   \q
   ```

Pour configurer PostgreSQL afin qu'il accepte les connexions de n'importe quelle adresse IP, vous devez modifier le fichier `pg_hba.conf` en ajoutant une ligne spécifique. Voici comment procéder :

1. **Ouvrez le fichier `pg_hba.conf`** :
   - Utilisez un éditeur de texte pour ouvrir le fichier. Sous Debian, vous pouvez utiliser `nano` ou `vim`. Par exemple :
     ```bash
     sudo vim /etc/postgresql/12/main/pg_hba.conf
     ```

2. **Ajouter une règle d'accès** :
   - À la fin du fichier, ajoutez la ligne suivante :
     ```
     host    all    all    0.0.0.0/0    md5
     ```
   - Cette ligne permet d'accepter les connexions de n'importe quelle adresse IP pour tous les utilisateurs et toutes les bases de données. Le `md5` indique que l'authentification par mot de passe doit être utilisée.

3. **Configurer PostgreSQL pour écouter sur toutes les interfaces** :
   - Assurez-vous également que PostgreSQL est configuré pour écouter sur toutes les interfaces réseau. Pour cela, modifiez le fichier `postgresql.conf` :
     ```bash
     sudo vim /etc/postgresql/12/main/postgresql.conf
     ```
   - Trouvez la ligne `listen_addresses` et changez-la pour :
     ```
     listen_addresses = '*'
     ```
   - Si cette ligne est commentée (précédée par un `#`), décommentez-la en supprimant le `#`.

4. **Redémarrer le service PostgreSQL** :
   - Après avoir effectué ces modifications, vous devez redémarrer le service PostgreSQL pour appliquer les changements :
     ```bash
     sudo systemctl restart postgresql
     ```

### Instalation de l' adaptateur
```bash
export PATH="/usr/lib/postgresql/12/bin:$PATH"

sudo apt install make libpq-dev build-essential postgresql-server-dev-12

git clone https://github.com/timescale/pg_prometheus

cd pg_prometheus

make

make install
```

puis dans le fichier /etc/postgresql/12/main/postgresql.conf -> `shared_preload_libraries = 'timescaledb,pg_prometheus'`

`systemctl restart posgresql`

Puis il faut cree la table:
`sudo -u postgres psql`
```psql
\c prometheus_data
CREATE EXTENSION pg_prometheus;
SELECT create_prometheus_table('metrics');
```

```bash
wget https://github.com/timescale/prometheus-postgresql-adapter/releases/download/v0.6.0/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz
tar -xf prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz

./prometheus-postgresql-adapter -pg-host=localhost -pg-port=5432 -pg-user=postgres -pg-password=password -pg-database=prometheus_data -web-listen-address=:9201
```
