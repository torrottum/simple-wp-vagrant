#!/bin/bash

echo "Setting up example.local site"

# Create database if it doesn't exist
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS example"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON example.* TO wp@localhost IDENTIFIED BY 'wp';"

if [ ! -d htdocs ]; then
	mkdir htdocs
	cd htdocs

	wp core download --allow-root
	wp core config --dbname="example" --dbuser=wp --dbpass=wp --dbhost="localhost" --allow-root

	wp core install --url=example.local --title="Example" --admin_user=admin --admin_password=password --admin_email=demo@example.com --allow-root
fi
