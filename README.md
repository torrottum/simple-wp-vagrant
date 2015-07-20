# Simple WordPress Vagrant
A Vagrant setup for WordPress with Ubuntu 14.04 (Trusty), Nginx, MySQL, and PHP.

## Features
* Nginx mainline
* php-fpm 5.5.x
* MySQL 5.5.x
* WP-CLI
* git
* Fast site creation (on every `vagrant up`)
* Database backups (please read [this](#database-backups))

### Why use this instead of [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)?
It's much faster to create sites with Simple WP Vagrant. This is because you don't need to reprovision and check for updates for the whole box each time you just want to add a new site.

On each `vagrant up` it will copy over the server configuration files.

## Installation & Usage
1. Install [Vagrant](https://www.vagrantup.com) and [Virtualbox](https://www.virtualbox.org)
1. Install recommended vagrant plugin
	* `vagrant plugin install vagrant-hostsupdater`
    * `vagrant plugin install vagrant-triggers`
	* This step is not required but recommended. The vagrant-hostsupdater plugin automatically adds the sites to your machine's hosts file. And the vagrant-triggers plugins allows us to take database backups on `vagrant halt`, `vagrant destroy`, and `vagrant suspend`
1. Clone the repo and run `vagrant up`
	* `git clone https://github.com/torrottum/simple-wp-vagrant`
	* `cd simple-wp-vagrant`
	* `vagrant up`
	* It might require your administrator password to update your hosts file
1. Visit these links in your browser
	* [http://example.local](http://example.local) example WordPress site
	* [http://wp.local](http://wp.local) for a dashboard
1. Add your own sites

### Usage - How to add your own sites
It's simple to add your own site. Just create a new directory inside the `www/` directory.
Inside that folder you'll need to create four files: `hosts`, `init.sh`, `nginx.conf`, and `wp-cli.yml`

As of now you'll have to create these manually. But I hope to create a scaffolding script soon.

#### Hosts file - Your domains
The host file just contains the hostnames you want to use for the site. For example
```
test.local
sub-domain.test.local
```

#### init.sh - The setup script
The init.sh is a script that is run on every `vagrant up`. You can have anything in it and it allows you to setup your sites the way you want it.

Here's an example of a simple `init.sh` script that installs WordPress
```bash
#!/bin/bash

echo "Setting up example.local site"

# Create database if it doesn't exist
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS test"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON test.* TO wp@localhost IDENTIFIED BY 'wp';"

if [ ! -d htdocs ]; then
	mkdir htdocs
	cd htdocs

	wp core download --allow-root
	wp core config --dbname="test" --dbuser=wp --dbpass=wp --dbhost="localhost" --allow-root

	wp core install --url=test.local --title="Test site" --admin_user=admin --admin_password=password --admin_email=demo@example.com --allow-root
fi
```

#### nginx.conf - Nginx config
To serve your site with Nginx you'll need to create a nginx.conf file.

Here's an example:
```nginx
server {
    # Listen at port 80 for HTTP requests
    listen          80;

    # The domain name(s) that the site should answer
    # for. You can use a wildcard here, e.g.
    # *.example.com for a subdomain multisite.
    server_name     test.local;

    # The folder containing your site files.
    # The {path_to_folder} token gets replaced
    # with the folder containing this, e.g. if this
    # folder is /srv/www/foo/ and you have a root
    # value of `{path_to_folder}/htdocs` this
    # will be auto-magically transformed to
    # `/srv/www/foo/htdocs`.
    root            {path_to_folder}/htdocs;

    include         /etc/nginx/nginx-wp.conf;
}
```

#### wp-cli.yml - WP-CLI Configuration
In order to use wp-cli correctly and outside of the VM you'll need to add a wp-cli.yml file containing this:
```yaml
path: htdocs
require:
  - ../../config/wp-cli/config.php
```

### Credentials
#### Example WordPress installation
* Path: `www/example/htdocs`
* VM Path: `/srv/www/example/htdocs`
* URL: `http://example.local`
* Admin username: `admin`
* Admin password: `password`

#### MySQL
* Root username: `root`
* Root password: `root`
* External username: `external`
* External password: `external`

## Database backups
Databases are backed up on `vagrant halt`, `vagrant destroy`, and `vagrant suspend`. However there are no automated importing procedure. If you destroy the vagrant box, you'll have to import them by yourself.

## Credits
Much of the configuration and provisioning is taken from [VVV](https://github.com/Varying-Vagrant-Vagrants/VVV/)
