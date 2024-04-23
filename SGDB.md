TimescaleDB
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

Pour configurer PostgreSQL afin qu'il accepte les connexions de n'importe quelle adresse IP, vous devez modifier le fichier `pg_hba.conf` en ajoutant une ligne spécifique. Voici comment procéder :

1. **Ouvrez le fichier `pg_hba.conf`** :
   - Utilisez un éditeur de texte pour ouvrir le fichier. Sous Debian, vous pouvez utiliser `nano` ou `vim`. Par exemple :
     ```bash
     sudo nano /etc/postgresql/14/main/pg_hba.conf
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
     sudo nano /etc/postgresql/14/main/postgresql.conf
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

5. **Vérifier la connectivité** :
   - Testez la connexion depuis la machine B pour vous assurer que les modifications ont été appliquées correctement.

Ces étapes devraient permettre à n'importe quelle machine capable de pinguer la machine A de se connecter à PostgreSQL, à condition qu'ils aient les bons identifiants et que le réseau permette la connexion au port PostgreSQL (par défaut, 5432). Assurez-vous que votre pare-feu (si activé) autorise également les connexions sur ce port.