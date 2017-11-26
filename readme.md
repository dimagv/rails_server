# What is this?

This is an automated script to help you setup new server and deploy Rails application along with database dump.

## Requirements:
Ubuntu 16.04 or newer

## Setup

    cd your-rails-project-folder
    git clone git@github.com:gambala/rails_server.git server
    cp server/hosts.yml.example server/hosts.yml
    ansible-galaxy install -r server/requirements.yml

Also:

1. Place your postgres database dump at `server/app_name.sql`. Dump must be created with following command: `pg_dump --no-owner app_name > app_name.sql -U DB_USERNAME`
2. Update IP address of your server in `config/deploy/production.rb` and set user value to `deploy`.

**IMPORTANT**
After first deploy and restore database from backup **don't forget** to change `restore_backup` value to `false`. In other case on next applying `app.yml` playbook your database will be rewrited with provided in `server` directory.

## Usage

Run
```
ansible-playbook server/python.yml -i server/hosts.yml
ansible-playbook server/server.yml -i server/hosts.yml
cap production deploy:check
ansible-playbook server/app.yml -i server/hosts.yml
```

This script goes through full server configuration process. For now it does next things (in order of applying):

### python.yml

- Installs Python2 in order to allow Ansible do all the work
- Installs pip, python packet manager

### server.yml

- Creates `deploy` user which is our main user for application deployments
- Configures `zsh` and `oh-my-zsh` for both `root` and `deploy` users
- Installs `vim` and `htop`
- Installs `monit` for server state monitoring and notifications (RAM, HDD, etc)
- Installs `nginx` with `passenger` to serve your Rails applications
- Installs `Redis`
- Installs `Ruby`
- Installs `PostgreSQL`

### app.yml

- Configures Nginx to server your Rails application
- Creates PostgreSQL database and user for your Rails application
- Uploads database dump and restores it on server
- Setups daily DB backups with uploading to Yandex Disk

### Application

Run `cap production deploy` to start deployment process.

### That's all!

## Deploying application to already configured server

Just run `ansible-playbook server/app.yml -i server/hosts`. You'll also want to update files from Preparation as appropriate.
