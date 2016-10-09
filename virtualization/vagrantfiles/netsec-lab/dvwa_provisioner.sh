#!/usr/bin/env bash
debconf-set-selections <<< 'mysql-server mysql-server/root_password password p@ssw0rd'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password p@ssw0rd'
apt-get update
apt-get install --yes mysql-server mysql-client
add-apt-repository -y ppa:nginx/stable
apt-get update
apt-get install --yes nginx
apt-get install --yes php5-cli php5-common php5-mysql php5-gd php5-fpm php5-cgi php5-fpm php-pear php5-mcrypt vim git
apt-get -f install --yes
/etc/init.d/nginx stop
/etc/init.d/php5-fpm stop

sed -i 's/^;cgi.fix_pathinfo.*$/cgi.fix_pathinfo = 0/g' /etc/php5/fpm/php.ini

## Settings for DVWA to be extra vuln :)
sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php5/fpm/php.ini
sed -i 's/allow_url_fopen = Off/allow_url_fopen = On/g' /etc/php5/fpm/php.ini
sed -i 's/safe_mode = On/safe_mode = Off/g' /etc/php5/fpm/php.ini
echo "magic_quotes_gpc = Off" >> /etc/php5/fpm/php.ini
sed -i 's/display_errors = Off/display_errors = On/g' /etc/php5/fpm/php.ini

sed -i 's/^;security.limit_extensions.*$/security.limit_extensions = .php .php3 .php4 .php5/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^;listen\s.*$/listen = \/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^listen.owner.*$/listen.owner = www-data/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^listen.group.*$/listen.group = www-data/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/^;listen.mode.*$/listen.mode = 0660/g' /etc/php5/fpm/pool.d/www.conf
cat << 'EOF' > /etc/nginx/sites-enabled/default
server
{
    listen  80;
    root /var/www/html;
    index index.php index.html index.htm;
    #server_name localhost
    location "/"
    {
        index index.php index.html index.htm;
        #try_files $uri $uri/ =404;
    }

    location ~ \.php$
    {
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $request_filename;
    }
}
EOF
/etc/init.d/mysql restart
/etc/init.d/php5-fpm restart
/etc/init.d/nginx restart
mysql -u root -p"p@ssw0rd" -e "CREATE DATABASE dvwa;"
if [[ ! -d "/var/www/html" ]]; then mkdir -p /var/www; ln -s /usr/share/nginx/html /var/www/html; chown -R www-data. /var/www/html; fi
rm /var/www/html/*.html
cd /var/www/html && git clone https://github.com/RandomStorm/DVWA.git && chown -R www-data. ./ && mv ./DVWA/* . && chmod 777 ./hackable/uploads/; chmod 777 ./external/phpids/0.6/lib/IDS/tmp/phpids_log.txt
