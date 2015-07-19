#!/bin/bash

# This script will install the required software (nginx, mysql, php, etc)

# Add nginx mainline ppa
apt-add-repository -y ppa:nginx/development

# Set MySQL password root to root
echo "mysql-server-5.5 mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password root" | debconf-set-selections

# Setup postfix
echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
echo postfix postfix/mailname string vvv | debconf-set-selections

apt-get -q update

pkgs_to_install=(
	nginx
	mysql-server-5.5
	mysql-client
	php5-cli
	php5-common
	php5-fpm
	php5-cgi
	php5-curl
	php5-gd
	php5-imagick
	php5-mcrypt
	php5-mysql
	memcached
	php5-memcache
	postfix
	git
	imagemagick
	ntp
	zip
	unzip
);

# Install the packages
apt-get install -qy ${pkgs_to_install[@]}

# Enable mcrypt php module
php5enmod mcrypt

# Add external mysql user
echo "GRANT ALL PRIVILEGES ON *.* TO 'external'@'%' IDENTIFIED BY 'external';" | mysql -u root -proot
