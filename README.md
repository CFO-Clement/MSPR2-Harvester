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