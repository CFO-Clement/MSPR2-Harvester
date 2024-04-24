# L'Harvester (Client)

**Objectif** : Collecter des métriques de manière efficace et sécurisée depuis les machines clientes et proposer une solution de télémaintenance.

## Collecte de données

Nous utilisons Prometheus, qui se sert de `node_exporter` pour collecter les métriques de base de la machine, et de `remote_write` pour centraliser les données de tous les harvesters dans une base de données TimeScaleDB/Postgres12.

### Structure de la collecte de données

```plaintext
prometheus_ansible/
│
├── files/
│   ├── prometheus.yml             # Fichier de configuration de Prometheus
│   ├── prometheus.service         # Service systemd pour Prometheus
│   └── node_exporter.service      # Service systemd pour node_exporter
├── playbook.yml                   # Playbook Ansible
└── install_prometheus.sh          # Script d'installation
```

#### `prometheus_ansible/files/prometheus.yml`

##### Job Prometheus
La configuration détaillée du job (exemple). La valeur `localhost:9090` permet de rendre accessible Prometheus localement via le loopback.

##### Job node_exporter
Description du job (exemple). La valeur `localhost:9100` permet d'exposer les données collectées par l'exporter.

##### remote_write
L'URL pointe vers un agrégateur sur la machine SGBD qui va récupérer les appels API de Prometheus et les enregistrer dans la base de données.

### `prometheus_ansible/files/node_exporter.service`
Service systemd qui se lance après le réseau et exécute le binaire `/usr/local/bin/node_exporter` sous l'utilisateur `node_exporter`.

### `prometheus_ansible/files/prometheus.service`
Service systemd qui se lance après le réseau avec une politique de redémarrage en cas d'échec et qui exécute le binaire `/usr/local/bin/prometheus` sous l'utilisateur `prometheus` avec les arguments suivants :

```plaintext
  --config.file=/etc/prometheus/prometheus.yml
  --storage.tsdb.path=/var/lib/prometheus/
  --web.console.templates=/etc/prometheus/consoles
  --web.console.libraries=/etc/prometheus/console_libraries
```

### `prometheus_ansible/playbook.yml`
Playbook Ansible qui installe et configure toutes les dépendances en se basant sur les ressources de `files/`, puis lance les services.

### `install_prometheus.sh`
Script qui installe Ansible si nécessaire, demande à l'utilisateur l'endpoint de l'agrégateur TimeScaleDB, puis lance le playbook avec les bons arguments.

## Télémaintenance -- VNC

Nous utilisons un serveur `tightvncserver` pour supporter des bureaux à distance, ainsi que le service `NoVNC` pour encapsuler les sessions VNC dans un websocket, permettant l'utilisation d'un client web pour se connecter à la machine.

### Structure de la télémaintenance

```plaintext
novnc_ansible/
│
├── files/
│   ├── novnc.service           # Daemon NoVNC
│   ├── vncserver               # Script pour tightvncserver
│   └── vncserver.service       # Service systemd pour notre binaire vncserver
├── playbook.yml                # Playbook Ansible
└── install_novnc.sh            # Script d'installation
```

### `novnc_ansible/files/novnc.service`
Daemon qui s'exécute après le démarrage du réseau et lance le binaire `/opt/noVNC/utils/novnc_proxy` pour encapsuler les sessions VNC dans un websocket.
Options :
`--vnc localhost:5902` - Endpoint du serveur VNC
`--listen 6082` - Port d'écoute pour les websockets

### `novnc_ansible/files/vncserver`
Script agissant comme un binaire facilitant la gestion du serveur tightvncserver à travers des daemons. Ce script utilise le display `:2`.

### `novnc_ansible/files/vncserver.service`
Daemon systemd qui se lance après le réseau et exécute le binaire personnalisé `/usr/local/bin/vncserver`.

### `novnc_ansible/playbook.yml`
Playbook Ansible qui installe et configure toutes les dépendances en se basant sur les ressources de `files/` puis lance les services.

### `install_novnc.sh`
Script qui installe Ansible si nécessaire, puis lance le playbook avec les bons arguments.

## Télémaintenance -- SSH

Nous avons également intégré ShellInABox pour permettre un accès terminal sécurisé via le navigateur. Ce service est installé et configuré sur chaque machine pour fournir un accès direct au terminal à travers une interface web sécurisée.

### Playbook Ansible pour ShellInABox

```plaintext
shellinabox_ansible/
│
├── files/
│   └── shellinabox                   # Fichier de configuration de ShellInABox
├── playbook.yml                      # Playbook Ansible
└── install_shellinabox.sh            # Script d'installation
```

#### `shellinabox_ansible/files/shellinabox`
Configuration de ShellInABox pour démarrer avec le système et écouter sur le port 6175. La connexion est sécurisée via HTTPS.

#### `shellinabox_ansible/playbook.yml`
Playbook Ansible qui prépare le serveur SSH et installe ShellInABox, assure le démarrage du service et configure le firewall pour permettre le trafic sur le port 6175.

### `install_shellinabox.sh`
Script qui installe Ansible si nécessaire, puis lance le playbook avec les bons arguments.


### Connection au Harvester
Cette partie hérite directement de la MSPR1. Le projet Seahawks_Harvester consiste en un serveur reverse TCP qui ce connecte au Nester lui permetant de faire remonter des info et de pouvoir etre controler par le Nester
```plaintext
harvester_ansible/
│
├── files/
│   ├── app/
│       ├── config.env          # Variables d'environnement
│       ├── DockerFile          # Dockerfile du projet Seahawks Harvester
│       ├── install.sh          # Script d'installation du Harvester (configuration des vars, docker build...)
│       ├── requirements.txt    # Dépendances Python
│       ├── start.sh            # Script de lancement du projet
│       ├── update.sh           # Script de mise à jour du projet
│       ├── src/                # Application Flask 
│   └── harvester.service          # Daemon pour lancer Harvester
├── playbook.yml                # Playbook Ansible
└── install_harvester.sh           # Script d'installation
```
#### `harvester_ansible/files/harvester.service`
Daemon qui lance, après le démarrage du réseau, le script `start.sh` dans `/opt/harvester` avec les paramètres Docker.

#### `harvester_ansible/playbook.yml`
Ce playbook installe les dépendances, copie le projet Seahawks harvester dans `/opt/harvester`, construit l'image, crée le daemon et lance le service.

#### `install_harvester.sh`
Script qui installe Ansible si nécessaire, puis lance le playbook.

## Résumé des Services et Ports

- **Prometheus** : Port 9090
- **Node Exporter** : Port 9100
- **NoVNC** : Port 6082 pour les websockets
- **ShellInABox** : Port 6175 (sécurisé via HTTPS)
- **VNC Server** : Écoute typiquement sur les ports commençant par 5900 (ex. : 5902)
- **Harvester** : Port 5000

Ces configurations garantissent une surveillance efficace et une maintenance à distance sécurisée de vos systèmes.


## TODO

### Collecte de données :
   - Permettre à Ansible de prendre en compte la variable de l'endpoint TimeScaleDB, qui est actuellement codée en dur.
   - Variabiliser le nom de la node afin de pouvoir les identifier une fois agrégées.

### Harvester :
  - Variabilier le fichier config pour le port et le endpoint du nester