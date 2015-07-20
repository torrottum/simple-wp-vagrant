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

# Add mysql backup script
cat << 'EOF' > /usr/local/bin/db_backup
#!/bin/bash
echo "Backing up databases ..."
mysql -uroot -proot -e 'show databases' | \
grep -v -F "information_schema" | \
grep -v -F "performance_schema" | \
grep -v -F "mysql" | \
grep -v -F "test" | \
grep -v -F "Database" | \
while read dbname; do
	mysqldump -uroot -proot "$dbname" > /srv/database/"$dbname".sql && echo "Database $dbname backed up ...";
done
EOF

chmod +x /usr/local/bin/db_backup

# Install WP-CLI
echo "Installing WP-CLI ..."
curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x /usr/local/bin/wp
# Completions
curl -o /usr/share/bash-completion/completions/wp https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash
