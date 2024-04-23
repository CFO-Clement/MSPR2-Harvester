#!/bin/bash

if ! command -v ansible &> /dev/null
then
    echo "Ansible n'est pas installé. Installation en cours..."
    sudo apt update
    sudo apt install -y ansible
fi

ansible-playbook -i localhost, -c local test.yml --ask-become-pass