#!/bin/bash

# This script will copy over the configuration files

echo "Copying nginx configuration ..."
cp /srv/config/nginx/nginx.conf /etc/nginx/nginx.conf
cp /srv/config/nginx/nginx-wp.conf /etc/nginx/nginx-wp.conf
rsync -rvh --delete /srv/config/nginx/sites/ /etc/nginx/sites-enabled/


for SITE_CONFIG_FILE in $(find /srv/www -maxdepth 5 -name 'nginx.conf'); do
  echo "Found nginx config $SITE_CONFIG_FILE"

  DEST_CONFIG_FILE=${SITE_CONFIG_FILE//\/srv\/www\//}
  DEST_CONFIG_FILE=${DEST_CONFIG_FILE//\//\-}
  DEST_CONFIG_FILE=${DEST_CONFIG_FILE/%-vvv-nginx.conf/}
  DEST_CONFIG_FILE="$DEST_CONFIG_FILE-$(md5sum <<< "$SITE_CONFIG_FILE" | cut -c1-32).conf"
  # We allow the replacement of the {path_to_folder} token with
  # whatever you want, allowing flexible placement of the site folder
  # while still having an Nginx config which works.
  DIR="$(dirname $SITE_CONFIG_FILE)"
  sed "s#{path_to_folder}#$DIR#" "$SITE_CONFIG_FILE" > /etc/nginx/sites-enabled/"$DEST_CONFIG_FILE"
done

echo "Copying php & php-fpm config ..."
cp /srv/config/php/www.conf /etc/php5/fpm/pool.d/www.conf
cp /srv/config/php/php-fpm.conf /etc/php5/fpm/php-fpm.conf
cp /srv/config/php/php.ini /etc/php5/fpm/php.ini

echo "Cleaning the virtual machine's /etc/hosts file ..."
sed -n '/# vagrant$/!p' /etc/hosts > /tmp/hosts
mv /tmp/hosts /etc/hosts
echo "Adding domains to the virtual machine's /etc/hosts file ..."
find /srv/www/ -maxdepth 5 -name 'hosts' | \
while read hostfile; do
  while IFS='' read -r line || [ -n "$line" ]; do
    if [[ "#" != ${line:0:1} ]]; then
      if [[ -z "$(grep -q "^127.0.0.1 $line$" /etc/hosts)" ]]; then
        echo "127.0.0.1 $line # vagrant" >> /etc/hosts
        echo "Added $line from $hostfile"
      fi
    fi
  done < "$hostfile"
done

echo "Copying MySQL config"
cp /srv/config/mysql/my.cnf /etc/mysql/my.cnf

echo "Restarting nginx, php-fpm, and mysql"
service nginx restart
service php5-fpm restart
service mysql restart

echo "Running init scripts"
for INIT_SCRIPT in $(find /srv/www -maxdepth 5 -name 'init.sh'); do
  cd $(dirname "$INIT_SCRIPT")
  source 'init.sh';
done
