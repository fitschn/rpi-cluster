# Ansible based deployment

## Requirements

* local ansible deployment (ideally via pipenv)
* API token for the secret manager set as environment var

## Optional dependencies

If you want to set the API token for the secret manager automatically,
you can

* install direnv (https://direnv.net)
* install and configure pass (https://www.passwordstore.org)

## Deployment

* for the initial node setup, you have to deploy the bootstrap role
  ```
  ansible-playbook -i inventories/home playbooks/bootstrap.yml -l target-node -D -u pi
  ```
* after that you can deploy all the required base services to the node
  ```
  ansible-playbook -i inventories/home 01-base-deployment.yml -l target-node -D
  ```
* now the deployment of the services can be started
  ```
  ansible-playbook -i inventories/home 02-service-deployment.yml -l target-node -D
  ```
