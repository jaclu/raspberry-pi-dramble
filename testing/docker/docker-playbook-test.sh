#!/bin/bash
#
# Shell script to test the Raspberry Pi Dramble playbook on a Docker container.
#
# This is hacky, but it does what I need it to do :)
#
# Usage (from project root):
#   testing/docker/docker-playbook-test.sh

container_name=dramble

# Run a Docker container for the playbook to run inside.
docker run --detach \
  -h kube1 \
  -p 8080:80 \
  --volume=$(pwd):/etc/ansible/pi-dramble:rw \
  --name $container_name \
  --privileged \
  --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
  geerlingguy/docker-debian10-ansible:latest \
  /lib/systemd/systemd

# Install requirements.
docker exec --tty $container_name env TERM=xterm ansible-galaxy install -r /etc/ansible/pi-dramble/requirements.yml

# Check the playbook's syntax.
docker exec --tty $container_name env TERM=xterm \
  ansible-playbook /etc/ansible/pi-dramble/main.yml --syntax-check

# Run the playbook.
docker exec --tty $container_name env TERM=xterm \
  ansible-playbook /etc/ansible/pi-dramble/main.yml --connection=local \
  -i /etc/ansible/pi-dramble/testing/docker/inventory \
  --extra-vars "deploy_target=docker" \
  --limit=kube1
