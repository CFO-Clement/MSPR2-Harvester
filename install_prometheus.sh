#!/bin/bash

# Installer Ansible s'il n'est pas déjà installé
if ! command -v ansible &> /dev/null
then
    echo "Ansible n'est pas installé. Installation en cours..."
    sudo apt update
    sudo apt install -y ansible
fi

DEFAULT_REMOTE_WRITE_ENDPOINT="http://posgres:password@192.168.122.20:9201/write"
read -p "Entrez l'URL de l'endpoint remote_write (laissez vide pour utiliser la valeur par défaut -> ${DEFAULT_REMOTE_WRITE_ENDPOINT}) :  " remote_write_endpoint
remote_write_endpoint=${remote_write_endpoint:-$DEFAULT_REMOTE_WRITE_ENDPOINT}

ansible-playbook -i localhost, -c local -e "remote_write_endpoint=http://prometheus_user:prometheus@192.168.1.218:5432/write" prometheus_ansible/playbook.yml --ask-become-pass
