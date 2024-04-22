#!/bin/bash

# Demander à l'utilisateur l'URL de l'endpoint remote_write
read -p "Entrez l'URL de l'endpoint remote_write (laissez vide pour utiliser la valeur par défaut): " remote_write_endpoint
remote_write_endpoint=${remote_write_endpoint:-http://example.com/write}

# Exécuter le playbook Ansible avec l'URL de l'endpoint remote_write
ansible-playbook -i localhost, -c local -e "remote_write_endpoint=$remote_write_endpoint" prometheus_ansible/playbook.yml
