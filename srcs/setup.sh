#!/bin/bash

#setup local dir

mkdir /var/www/html/ft_server

#ssl auto-signé

mkdir /etc/nginx/ssl
openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout ft_server.key -out ft_server.crt -subj "/C=FR/ST=Paris/L=Paris/O=42 paris/OU=ft_server/CN=cbeaurai/emailAddress=cbeaurai@student.42.fr"
mv ft_server.key /etc/nginx/ssl && mv ft_server.crt /etc/nginx/ssl

#mariadb setup

service mysql start

echo "CREATE DATABASE wordpress;" | mysql -u root
echo "CREATE USER 'user42' @'localhost' IDENTIFIED BY 'root'" | mysql -u root
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'user42'@'localhost' WITH GRANT OPTION" |
mysql -u root
echo "FLUSH PRIVILEGES" | mysql -u root

#php_my_admin setup

#downloads latest version

mkdir /var/www/html/ft_server/phpmyadmin && cd /var/www/html/ft_server/phpmyadmin
DATA="$(wget https://www.phpmyadmin.net/home_page/version.txt -q -O-)"
URL="$(echo $DATA | cut -d ' ' -f 3)"
VERSION="$(echo $DATA | cut -d ' ' -f 1)"
wget https://files.phpmyadmin.net/phpMyAdmin/${VERSION}/phpMyAdmin-${VERSION}-all-languages.tar.gz

#

tar -xvf phpMyAdmin-${VERSION}-all-languages.tar.gz
mv phpMyAdmin-${VERSION}-all-languages/* ~/../var/www/html/ft_server/phpmyadmin
rm -rf phpMyAdmin-${VERSION}-all-language*
cd ~/..
mv ./tmp/phpmyadmin.inc.php ./var/www/html/ft_server/phpmyadmin/config.inc.php

#autoindex 

if [ "$AUTOINDEX" = "OFF" ]
then
	sed -i 's/autoindex			on/autoindex			off/g' /tmp/nginx-conf
fi
#nginx setup

mv ./tmp/nginx-conf /etc/nginx/sites-available/ft_server
ln -s /etc/nginx/sites-available/ft_server /etc/nginx/sites-enabled/ft_server
rm -rf /etc/nginx/sites-enabled/default && rm -rf /etc/nginx/sites-available/default

#nginx rights

chown -R www-data:www-data /var/www/html/ft_server/*
chmod -R 755 /var/www/html/ft_server/* 

#wordpress activation

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
cd /var/www/html/ft_server && mkdir wordpress && cd wordpress

wp core download --allow-root
wp core config --dbname=wordpress --dbuser=user42 --dbpass=root --dbhost=localhost --dbprefix=wp_ --allow-root
wp core install --url="localhost/wordpress" --title="ft_server" --admin_user="user42" --admin_password="root" --admin_email="cbeaurai@student.42.fr" --allow-root
wp theme install spacious --activate --allow-root

cd ~/..

#launch server
service php7.3-fpm start
service nginx start

#############

bash
