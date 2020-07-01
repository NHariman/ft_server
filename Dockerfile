FROM debian:buster
MAINTAINER nhariman <nhariman@student.codam.nl>

#install and download everything necessary, also move them to the right places
RUN apt-get update && \
	apt install -y \
	nginx \
	mariadb-server \
	mariadb-client \
	php-cgi \
	php-common \
	php-fpm \
	php-pear \
	php-mbstring \
	php-zip \
	php-net-socket \
	php-gd \
	php-xml-util \
	php-gettext \
	php-mysql \
	php-bcmath \
	php-curl \
	wget \
	openssl \
	sendmail

#Copy all necessary configuration files
COPY /srcs/ ./srcs/

#get wordpress and phpmyadmin
RUN tar -xvzf srcs/wordpress-5.4.2.tar.gz &&\
	mv wordpress/ var/www/html/ &&\
	tar -xvzf srcs/phpMyAdmin-5.0.2-all-languages.tar.gz &&\
	mv phpMyAdmin-5.0.2-all-languages phpmyadmin &&\
	mv phpmyadmin/ var/www/html/

#setup nginx and phpmyadmin
RUN	mv srcs/default /etc/nginx/sites-available/ &&\
	mv srcs/php.ini /etc/php/7.3/fpm/ &&\
	mv srcs/wp-config.php var/www/html/wordpress/ &&\
	mv srcs/config.inc.php var/www/html/phpmyadmin

RUN service php7.3-fpm start

#setup mysql, phpmyadmin and wp database, for wp: nhariman, codam42born2code, for phpmyadmin: wpuser, dbpassword
RUN service mysql start &&\
	mysql < /srcs/setup_ini.sql &&\
	mysql phpmyadmin < var/www/html/phpmyadmin/sql/create_tables.sql &&\
	chmod +x /srcs/wp-cli.phar &&\
	mv srcs/wp-cli.phar /usr/local/bin/wp &&\
	wp core install --url="localhost/wordpress"  --title="ft_server" --admin_user="nhariman" --admin_password="codam42born2code" --admin_email="nhariman@student.codam.nl" --allow-root --path="var/www/html/wordpress" &&\
	wp core update --allow-root --path="var/www/html/wordpress"

#set ownerships
RUN chown -R www-data:www-data /var/www/ &&\
 	chown -R www-data:www-data /var/lib/php/sessions/ &&\
 	service php7.3-fpm restart &&\
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/CN=123' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt

#80 for internal 433 for ssl, according to the nginx cnfig in default the 80 port will redirect to 443 for a secure connection using the keys generated in the previous run
EXPOSE 80 443

#restart services and use bash to create in-line command shell, used entrypoint rather than cmd to ensure no extra arguments can be provided. To toggle the autoindex on and off use: bash srcs/autoindex_toggle.sh
ENTRYPOINT service nginx restart &&\
	service mysql restart &&\
	service php7.3-fpm restart &&\
	service sendmail start &&\
	bash
