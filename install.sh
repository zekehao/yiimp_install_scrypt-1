#!/bin/bash
################################################################################
# Original Author:   crombiecrunch
# Current Author: manfromafar
# Web:     yiimp.poolofd32th.club
#
# Program:
#   Install yiimp on Ubuntu 16.04 running Nginx, MariaDB, and php7.x
# BTC Donation: 18AwGT19befE4Z3siEiAzsF8n9MoJEifiH
#
################################################################################

    output() {
      printf "\E[0;33;40m"
      echo $1
      printf "\E[0m"
    }

    displayErr() {
      echo
      echo $1;
      echo
      exit 1;
    }

    clear

    output "Make sure you double check before hitting enter! Only one shot at these!"
    output ""
    read -e -p "Enter time zone (e.g. America/New_York) : " TIME
    read -e -p "Server name (no http:// or www. just example.com) : " server_name
    read -e -p "Are you using a subdomain (pool.example.com?) [y/N] : " sub_domain
    read -e -p "Enter support email (e.g. admin@example.com) : " EMAIL
    read -e -p "Set stratum to AutoExchange? i.e. mine any coinf with BTC address? [y/N] : " BTC
    read -e -p "Please enter a new location for /site/adminRights this is to customize the admin entrance url (e.g. myAdminpanel) : " admin_panel
    read -e -p "Enter your Public IP for admin access (http://www.whatsmyip.org/) : " Public
    read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
    read -e -p "Install UFW and configure ports? [Y/n] : " UFW
    read -e -p "Install LetsEncrypt SSL? IMPORTANT! You MUST have your domain name pointed to this server prior to running the script!! [Y/n]: " ssl_install
    clear

    output "Updating system and installing required packages."
    output ""
    apt-get -y update
    apt-get -y upgrade
    apt-get -y dist-upgrade
    apt-get -y autoremove
    clear

    output "Switching to Aptitude."
    output ""
    apt-get -y install aptitude
    clear

    output "Installing Nginx server."
    output ""
    aptitude -y install nginx
    rm /etc/nginx/sites-enabled/default
    service nginx start
    service cron start
    #Making Nginx a bit hard
echo 'map $http_user_agent $blockedagent {
  default         0;
  ~*malicious     1;
  ~*bot           1;
  ~*backdoor      1;
  ~*crawler       1;
  ~*bandit        1;
}
' | tee /etc/nginx/blockuseragents.rules >/dev/null 2>&1
    clear

    output "Installing Mariadb Server."
    output ""
    # create random password
    rootpasswd=$(openssl rand -base64 12)
    export DEBIAN_FRONTEND="noninteractive"
    aptitude -y install mariadb-server
    clear

    output "Installing php7.x and other needed files"
    output ""
    aptitude -y install php7.0-fpm php7.0 php7.0-common php7.0-opcache php7.0-gd php7.0-mysql
    aptitude -y install php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth-sasl php7.0-mcrypt
    aptitude -y install mcrypt imagemagick libruby php7.0-curl php7.0-intl php7.0-pspell
    aptitude -y install php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl
    aptitude -y install memcached php-memcache php-imagick php-gettext php7.0-zip
    aptitude -y install php7.0-mbstring
    phpenmod mcrypt
    phpenmod mbstring
    clear

    output "Installing developer library files"
    output ""
    aptitude -y install git
    aptitude -y install pwgen -y
    aptitude -y install libgmp3-dev default-libmysqlclient-dev libcurl4-gnutls-dev libkrb5-dev
    aptitude -y install libldap2-dev libidn11-dev gnutls-dev librtmp-dev
    aptitude -y install build-essential libtool autotools-dev automake pkg-config libssl1.0-dev
    aptitude -y install libevent-dev bsdmainutils libboost-all-dev libminiupnpc-dev
    aptitude -y install libpsl-dev libssh2-1-dev libidn2-0-dev libnghttp2-dev sasl2-bin
    aptitude -y install sendmail
    clear

    # Installing BerkeleyDB 4.8
    output "Installing BerkeleyDB 4.8"
    output ""
    wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    tar -xzvf db-4.8.30.NC.tar.gz
    cd db-4.8.30.NC/build_unix/
    ../dist/configure --enable-cxx --prefix=/usr/local
    make
    make install
    clear

    output "Testing to see if server emails are sent"
    output ""
    if [[ "$EMAIL" != "" ]]; then
      echo $EMAIL >> ~/.email
      echo $EMAIL >> ~/.forward

      echo "This is a mail test for the SMTP Service." > /tmp/email.msg
      echo "You should receive this !" >> /tmp/email.msg
      echo "" >> /tmp/email.msg
      echo "Cheers" >> /tmp/email.msg
      echo /tmp/email.msg | sendmail -v $EMAIL

      rm -f /tmp/email.msg
      echo "Mail sent"
    fi
    clear

    output "Some optional installs"

    if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
      output "Installing Fail2ban"
      output ""
      aptitude -y install fail2ban
    fi

    if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
      output "Installing UFW"
      output ""
      apt-get install ufw
      ufw default deny incoming
      ufw default allow outgoing
      ufw allow ssh
      ufw allow http
      ufw allow https
      ufw allow 2142/tcp
      ufw allow 3739/tcp
      ufw allow 3525/tcp
      ufw allow 4233/tcp
      ufw allow 3747/tcp
      ufw allow 5033/tcp
      ufw allow 4262/tcp
      ufw allow 3737/tcp
      ufw allow 3556/tcp
      ufw allow 3553/tcp
      ufw allow 4633/tcp
      ufw allow 8433/tcp
      ufw allow 3555/tcp
      ufw allow 3833/tcp
      ufw allow 4533/tcp
      ufw allow 4133/tcp
      ufw allow 5339/tcp
      ufw allow 8533/tcp
      ufw allow 3334/tcp
      ufw allow 4933/tcp
      ufw allow 3333/tcp
      ufw allow 6033/tcp
      ufw allow 5766/tcp
      ufw allow 3533/tcp
      ufw allow 4033/tcp
      ufw allow 3433/tcp
      ufw allow 3633/tcp
      ufw --force enable
    fi
    clear

    #Generating Random Passwords
    output "Generating Random Passwords"
    output ""
    password=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    password2=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    AUTOGENERATED_PASS=`pwgen -c -1 20`
    clear

    output "Installing phpmyadmin"
    output ""
    echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpasswd" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/mysql/app-pass password $AUTOGENERATED_PASS" | debconf-set-selections
    echo "phpmyadmin phpmyadmin/app-password-confirm password $AUTOGENERATED_PASS" | debconf-set-selections
    aptitude -y install phpmyadmin
    clear






    output "Installing yiimp"
    output ""
    output "Grabbing yiimp fron Github, building files and setting file structure."
    output ""
    #Generating Random Password for stratum
    blckntifypass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    cd ~
    git clone https://github.com/tpruvot/yiimp.git

    cd $HOME/yiimp/blocknotify
    sed -i 's/tu8tu5/'$blckntifypass'/' blocknotify.cpp
    make

    cd $HOME/yiimp/stratum/iniparser
    make

    cd $HOME/yiimp/stratum
    if [[ ("$BTC" == "y" || "$BTC" == "Y") ]]; then
      sed -i 's/CFLAGS += -DNO_EXCHANGE/#CFLAGS += -DNO_EXCHANGE/' $HOME/yiimp/stratum/Makefile
      make
    fi
    make

    cd $HOME/yiimp
    sed -i 's/AdminRights/'$admin_panel'/' $HOME/yiimp/web/yaamp/modules/site/SiteController.php
    cp -r $HOME/yiimp/web /var/
    mkdir -p /var/stratum
    cd $HOME/yiimp/stratum
    cp -a config.sample/. /var/stratum/config
    cp -r stratum /var/stratum
    cp -r run.sh /var/stratum
    cd $HOME/yiimp
    cp -r $HOME/yiimp/bin/. /bin/
    cp -r $HOME/yiimp/blocknotify/blocknotify /usr/local/bin/
    mkdir -p /etc/yiimp
    mkdir -p /$HOME/backup/

    #fixing yiimp
    sed -i "s|ROOTDIR=/data/yiimp|ROOTDIR=/var|g" /bin/yiimp
    #fixing run.sh
    rm -r /var/stratum/config/run.sh

echo '
#!/bin/bash
ulimit -n 10240
ulimit -u 10240
cd /var/stratum
while true; do
  ./stratum /var/stratum/config/$1
  sleep 2
done
exec bash
' | tee /var/stratum/config/run.sh >/dev/null 2>&1
    chmod +x /var/stratum/config/run.sh
    clear

    output "Update default timezone."
    # check if link file
    [ -L /etc/localtime ] &&  unlink /etc/localtime
    # update time zone
    ln -sf /usr/share/zoneinfo/$TIME /etc/localtime
    aptitude -y install ntpdate
    # write time to clock.
    hwclock -w
    clear

    output "Making Web Server Magic Happen!"
    # adding user to group, creating dir structure, setting permissions
    mkdir -p /var/www/$server_name/html
    output "Creating webserver initial config file"
    output ""
    if [[ ("$sub_domain" == "y" || "$sub_domain" == "Y") ]]; then
echo 'include /etc/nginx/blockuseragents.rules;
server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 80;
  listen [::]:80;
  server_name '"${server_name}"';
  root "/var/www/'"${server_name}"'/html/web";
  index index.html index.htm index.php;
  charset utf-8;

  location / {
    try_files $uri $uri/ /index.php?$args;
  }
  location @rewrite {
    rewrite ^/(.*)$ /index.php?r=$1;
  }

  location = /favicon.ico { access_log off; log_not_found off; }
  location = /robots.txt  { access_log off; log_not_found off; }

  access_log off;
  error_log  /var/log/nginx/'"${server_name}"'.app-error.log error;

  # allow larger file uploads and longer script runtimes
  client_body_buffer_size  50k;
  client_header_buffer_size 50k;
  client_max_body_size 50k;
  large_client_header_buffers 2 50k;
  sendfile off;

  location ~ ^/index\.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_intercept_errors off;
    fastcgi_buffer_size 16k;
    fastcgi_buffers 4 16k;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    try_files $uri $uri/ =404;
  }
  location ~ \.php$ {
    return 404;
  }
  location ~ \.sh {
    return 404;
  }
  location ~ /\.ht {
    deny all;
  }
  location ~ /.well-known {
    allow all;
  }
  location /phpmyadmin {
    root /usr/share/;
    index index.php;
    try_files $uri $uri/ =404;
    location ~ ^/phpmyadmin/(doc|sql|setup)/ {
      deny all;
    }
    location ~ /phpmyadmin/(.+\.php)$ {
      fastcgi_pass unix:/run/php/php7.0-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
      include snippets/fastcgi-php.conf;
    }
  }
}
' | tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1
      ln -s /etc/nginx/sites-available/$server_name.conf /etc/nginx/sites-enabled/$server_name.conf
      ln -s /var/web /var/www/$server_name/html
      service nginx restart
      clear

      if [[ ("$ssl_install" == "y" || "$ssl_install" == "Y" || "$ssl_install" == "") ]]; then
        output "Install LetsEncrypt and setting SSL"
        aptitude -y install letsencrypt
        letsencrypt certonly -a webroot --webroot-path=/var/web --email "$EMAIL" --agree-tos -d "$server_name"
        rm /etc/nginx/sites-available/$server_name.conf
        openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
        # I am SSL Man!
echo 'include /etc/nginx/blockuseragents.rules;
server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 80;
  listen [::]:80;
  server_name '"${server_name}"';
  # enforce https
  return 301 https://$server_name$request_uri;
}

server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name '"${server_name}"';

  root /var/www/'"${server_name}"'/html/web;
  index index.php;

  access_log /var/log/nginx/'"${server_name}"'.app-accress.log;
  error_log  /var/log/nginx/'"${server_name}"'.app-error.log error;

  # allow larger file uploads and longer script runtimes
  client_body_buffer_size  50k;
  client_header_buffer_size 50k;
  client_max_body_size 50k;
  large_client_header_buffers 2 50k;
  sendfile off;

  # strengthen ssl security
  ssl_certificate /etc/letsencrypt/live/'"${server_name}"'/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/'"${server_name}"'/privkey.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  # Add headers to serve security related headers
  add_header Strict-Transport-Security "max-age=15768000; preload;";
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Robots-Tag none;
  add_header Content-Security-Policy "frame-ancestors 'self'";

  location / {
    try_files $uri $uri/ /index.php?$args;
  }
  location @rewrite {
    rewrite ^/(.*)$ /index.php?r=$1;
  }
  location ~ ^/index\.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_intercept_errors off;
    fastcgi_buffer_size 16k;
    fastcgi_buffers 4 16k;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    include /etc/nginx/fastcgi_params;
    try_files $uri $uri/ =404;
  }
  location ~ \.php$ {
    return 404;
  }
  location ~ \.sh {
    return 404;
  }
  location ~ /\.ht {
    deny all;
  }
  location /phpmyadmin {
    root /usr/share/;
    index index.php;
    try_files $uri $uri/ =404;
    location ~ ^/phpmyadmin/(doc|sql|setup)/ {
      deny all;
    }
    location ~ /phpmyadmin/(.+\.php)$ {
      fastcgi_pass unix:/run/php/php7.0-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
      include snippets/fastcgi-php.conf;
    }
 }
}
' | tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1
      fi
      service nginx restart
      service php7.0-fpm reload
    else
echo 'include /etc/nginx/blockuseragents.rules;
server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 80;
  listen [::]:80;
  server_name '"${server_name}"' www.'"${server_name}"';
  root "/var/www/'"${server_name}"'/html/web";
  index index.html index.htm index.php;
  charset utf-8;

  location / {
    try_files $uri $uri/ /index.php?$args;
  }
  location @rewrite {
    rewrite ^/(.*)$ /index.php?r=$1;
  }
  location = /favicon.ico { access_log off; log_not_found off; }
  location = /robots.txt  { access_log off; log_not_found off; }

  access_log off;
  error_log  /var/log/nginx/'"${server_name}"'.app-error.log error;

  # allow larger file uploads and longer script runtimes
  client_body_buffer_size  50k;
  client_header_buffer_size 50k;
  client_max_body_size 50k;
  large_client_header_buffers 2 50k;
  sendfile off;

  location ~ ^/index\.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_intercept_errors off;
    fastcgi_buffer_size 16k;
    fastcgi_buffers 4 16k;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    try_files $uri $uri/ =404;
  }
  location ~ \.php$ {
    return 404;
  }
  location ~ \.sh {
    return 404;
  }
  location ~ /\.ht {
    deny all;
  }
  location ~ /.well-known {
    allow all;
  }
  location /phpmyadmin {
    root /usr/share/;
    index index.php;
    try_files $uri $uri/ =404;
    location ~ ^/phpmyadmin/(doc|sql|setup)/ {
      deny all;
    }
    location ~ /phpmyadmin/(.+\.php)$ {
      fastcgi_pass unix:/run/php/php7.0-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
      include snippets/fastcgi-php.conf;
    }
  }
}
' | tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1

      ln -s /etc/nginx/sites-available/$server_name.conf /etc/nginx/sites-enabled/$server_name.conf
      ln -s /var/web /var/www/$server_name/html
      service nginx restart

      if [[ ("$ssl_install" == "y" || "$ssl_install" == "Y" || "$ssl_install" == "") ]]; then
        output "Install LetsEncrypt and setting SSL"
        aptitude -y install letsencrypt
        letsencrypt certonly -a webroot --webroot-path=/var/web --email "$EMAIL" --agree-tos -d "$server_name" -d www."$server_name"
        rm /etc/nginx/sites-available/$server_name.conf
        openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
        # I am SSL Man!
echo 'include /etc/nginx/blockuseragents.rules;
server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 80;
  listen [::]:80;
  server_name '"${server_name}"';
  # enforce https
  return 301 https://$server_name$request_uri;
}

server {
  if ($blockedagent) {
    return 403;
  }
  if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 444;
  }
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name '"${server_name}"' www.'"${server_name}"';

  root /var/www/'"${server_name}"'/html/web;
  index index.php;

  access_log /var/log/nginx/'"${server_name}"'.app-accress.log;
  error_log  /var/log/nginx/'"${server_name}"'.app-error.log error;

  # allow larger file uploads and longer script runtimes
  client_body_buffer_size  50k;
  client_header_buffer_size 50k;
  client_max_body_size 50k;
  large_client_header_buffers 2 50k;
  sendfile off;

  # strengthen ssl security
  ssl_certificate /etc/letsencrypt/live/'"${server_name}"'/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/'"${server_name}"'/privkey.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
  ssl_dhparam /etc/ssl/certs/dhparam.pem;

  # Add headers to serve security related headers
  add_header Strict-Transport-Security "max-age=15768000; preload;";
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Robots-Tag none;
  add_header Content-Security-Policy "frame-ancestors 'self'";

  location / {
    try_files $uri $uri/ /index.php?$args;
  }
  location @rewrite {
    rewrite ^/(.*)$ /index.php?r=$1;
  }
  location ~ ^/index\.php$ {
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    fastcgi_intercept_errors off;
    fastcgi_buffer_size 16k;
    fastcgi_buffers 4 16k;
    fastcgi_connect_timeout 300;
    fastcgi_send_timeout 300;
    fastcgi_read_timeout 300;
    include /etc/nginx/fastcgi_params;
    try_files $uri $uri/ =404;
  }
  location ~ \.php$ {
    return 404;
  }
  location ~ \.sh {
    return 404;
  }
  location ~ /\.ht {
    deny all;
  }
  location /phpmyadmin {
    root /usr/share/;
    index index.php;
    try_files $uri $uri/ =404;
    location ~ ^/phpmyadmin/(doc|sql|setup)/ {
      deny all;
    }
    location ~ /phpmyadmin/(.+\.php)$ {
      fastcgi_pass unix:/run/php/php7.0-fpm.sock;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
      include snippets/fastcgi-php.conf;
    }
  }
}
' | tee /etc/nginx/sites-available/$server_name.conf >/dev/null 2>&1
      fi
      service nginx restart
      service php7.0-fpm reload
    fi
    clear

    output "Now for the database fun!"
    # create database
    Q1="CREATE DATABASE IF NOT EXISTS yiimpfrontend;"
    Q2="GRANT ALL ON *.* TO 'panel'@'localhost' IDENTIFIED BY '$password';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    mysql -u root -p="" -e "$SQL"
    # create stratum user
    Q1="GRANT ALL ON *.* TO 'stratum'@'localhost' IDENTIFIED BY '$password2';"
    Q2="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}"
    mysql -u root -p="" -e "$SQL"

    #Create my.cnf
 echo '
[clienthost1]
user=panel
password='"${password}"'
database=yiimpfrontend
host=localhost
[clienthost2]
user=stratum
password='"${password2}"'
database=yiimpfrontend
host=localhost
[mysql]
user=root
password='"${rootpasswd}"'
' | tee ~/.my.cnf >/dev/null 2>&1
    chmod 0600 ~/.my.cnf

    #Create keys file
echo '<?php
/* Sample config file to put in /etc/yiimp/keys.php */
define('"'"'YIIMP_MYSQLDUMP_USER'"'"', '"'"'panel'"'"');
define('"'"'YIIMP_MYSQLDUMP_PASS'"'"', '"'"''"${password}"''"'"');
/* Keys required to create/cancel orders and access your balances/deposit addresses */
define('"'"'EXCH_BITTREX_SECRET'"'"', '"'"'<my_bittrex_api_secret_key>'"'"');
define('"'"'EXCH_BITSTAMP_SECRET'"'"','"'"''"'"');
define('"'"'EXCH_BLEUTRADE_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_BTER_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_CCEX_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_COINMARKETS_PASS'"'"', '"'"''"'"');
define('"'"'EXCH_CRYPTOPIA_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_EMPOEX_SECKEY'"'"', '"'"''"'"');
define('"'"'EXCH_HITBTC_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_KRAKEN_SECRET'"'"','"'"''"'"');
define('"'"'EXCH_LIVECOIN_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_NOVA_SECRET'"'"','"'"''"'"');
define('"'"'EXCH_POLONIEX_SECRET'"'"', '"'"''"'"');
define('"'"'EXCH_YOBIT_SECRET'"'"', '"'"''"'"');
' | tee /etc/yiimp/keys.php >/dev/null 2>&1
    output "Database 'yiimpfrontend' and users 'panel' and 'stratum' created with password $password and $password2, will be saved for you"
    output ""
    clear

    output "Peforming the SQL import"
    output ""
    cd ~
    cd yiimp/sql
    # import sql dump
    zcat 2016-04-03-yaamp.sql.gz | mysql --defaults-group-suffix=host1
    # oh the humanity!
    mysql --defaults-group-suffix=host1 --force < 2016-04-24-market_history.sql
    mysql --defaults-group-suffix=host1 --force < 2016-04-27-settings.sql
    mysql --defaults-group-suffix=host1 --force < 2016-05-11-coins.sql
    mysql --defaults-group-suffix=host1 --force < 2016-05-15-benchmarks.sql
    mysql --defaults-group-suffix=host1 --force < 2016-05-23-bookmarks.sql
    mysql --defaults-group-suffix=host1 --force < 2016-06-01-notifications.sql
    mysql --defaults-group-suffix=host1 --force < 2016-06-04-bench_chips.sql
    mysql --defaults-group-suffix=host1 --force < 2016-11-23-coins.sql
    mysql --defaults-group-suffix=host1 --force < 2017-02-05-benchmarks.sql
    mysql --defaults-group-suffix=host1 --force < 2017-03-31-earnings_index.sql
    mysql --defaults-group-suffix=host1 --force < 2017-05-accounts_case_swaptime.sql
    mysql --defaults-group-suffix=host1 --force < 2017-06-payouts_coinid_memo.sql
    mysql --defaults-group-suffix=host1 --force < 2017-09-notifications.sql
    mysql --defaults-group-suffix=host1 --force < 2017-10-bookmarks.sql
    mysql --defaults-group-suffix=host1 --force < 2017-11-segwit.sql
    mysql --defaults-group-suffix=host1 --force < 2018-01-stratums_ports.sql
    mysql --defaults-group-suffix=host1 --force < 2018-02-coins_getinfo.sql
    clear

    output "Generating a basic serverconfig.php"
    output ""
    # make config file
echo '<?php
ini_set('"'"'date.timezone'"'"', '"'"'UTC'"'"');
define('"'"'YAAMP_LOGS'"'"', '"'"'/var/log'"'"');
define('"'"'YAAMP_HTDOCS'"'"', '"'"'/var/web'"'"');
define('"'"'YAAMP_BIN'"'"', '"'"'/var/bin'"'"');
define('"'"'YAAMP_DBHOST'"'"', '"'"'localhost'"'"');
define('"'"'YAAMP_DBNAME'"'"', '"'"'yiimpfrontend'"'"');
define('"'"'YAAMP_DBUSER'"'"', '"'"'panel'"'"');
define('"'"'YAAMP_DBPASSWORD'"'"', '"'"''"${password}"''"'"');
define('"'"'YAAMP_PRODUCTION'"'"', true);
define('"'"'YAAMP_RENTAL'"'"', true);
define('"'"'YAAMP_LIMIT_ESTIMATE'"'"', false);
define('"'"'YAAMP_FEES_MINING'"'"', 0.5);
define('"'"'YAAMP_FEES_EXCHANGE'"'"', 2);
define('"'"'YAAMP_FEES_RENTING'"'"', 2);
define('"'"'YAAMP_TXFEE_RENTING_WD'"'"', 0.002);
define('"'"'YAAMP_PAYMENTS_FREQ'"'"', 3*60*60);
define('"'"'YAAMP_PAYMENTS_MINI'"'"', 0.001);
define('"'"'YAAMP_ALLOW_EXCHANGE'"'"', false);
define('"'"'YIIMP_PUBLIC_EXPLORER'"'"', true);
define('"'"'YIIMP_PUBLIC_BENCHMARK'"'"', false);
define('"'"'YIIMP_FIAT_ALTERNATIVE'"'"', '"'"'USD'"'"'); // USD is main
define('"'"'YAAMP_USE_NICEHASH_API'"'"', false);
define('"'"'YAAMP_BTCADDRESS'"'"', '"'"'18AwGT19befE4Z3siEiAzsF8n9MoJEifiH'"'"');
define('"'"'YAAMP_SITE_URL'"'"', '"'"''"${server_name}"''"'"');
define('"'"'YAAMP_STRATUM_URL'"'"', YAAMP_SITE_URL); // change if your stratum server is on a different host
define('"'"'YAAMP_SITE_NAME'"'"', '"'"'PoolofD32th'"'"');
define('"'"'YAAMP_ADMIN_EMAIL'"'"', '"'"''"${EMAIL}"''"'"');
define('"'"'YAAMP_ADMIN_IP'"'"', '"'"''"${Public}"''"'"'); // samples: "80.236.118.26,90.234.221.11" or "10.0.0.1/8"
define('"'"'YAAMP_ADMIN_WEBCONSOLE'"'"', true);
define('"'"'YAAMP_NOTIFY_NEW_COINS'"'"', true);
define('"'"'YAAMP_DEFAULT_ALGO'"'"', '"'"'x11'"'"');
define('"'"'YAAMP_USE_NGINX'"'"', true);
// Exchange public keys (private keys are in a separate config file)
define('"'"'EXCH_CRYPTOPIA_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_POLONIEX_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_BITTREX_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_BLEUTRADE_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_BTER_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_YOBIT_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_CCEX_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_COINMARKETS_USER'"'"', '"'"''"'"');
define('"'"'EXCH_COINMARKETS_PIN'"'"', '"'"''"'"');
define('"'"'EXCH_BITSTAMP_ID'"'"','"'"''"'"');
define('"'"'EXCH_BITSTAMP_KEY'"'"','"'"''"'"');
define('"'"'EXCH_HITBTC_KEY'"'"','"'"''"'"');
define('"'"'EXCH_KRAKEN_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_LIVECOIN_KEY'"'"', '"'"''"'"');
define('"'"'EXCH_NOVA_KEY'"'"', '"'"''"'"');
// Automatic withdraw to Yaamp btc wallet if btc balance > 0.3
define('"'"'EXCH_AUTO_WITHDRAW'"'"', 0.3);
// nicehash keys deposit account & amount to deposit at a time
define('"'"'NICEHASH_API_KEY'"'"','"'"'521c254d-8cc7-4319-83d2-ac6c604b5b49'"'"');
define('"'"'NICEHASH_API_ID'"'"','"'"'9205'"'"');
define('"'"'NICEHASH_DEPOSIT'"'"','"'"'3J9tapPoFCtouAZH7Th8HAPsD8aoykEHzk'"'"');
define('"'"'NICEHASH_DEPOSIT_AMOUNT'"'"','"'"'0.01'"'"');
$cold_wallet_table = array(
  '"'"'18AwGT19befE4Z3siEiAzsF8n9MoJEifiH'"'"' => 0.10,
);
// Sample fixed pool fees
$configFixedPoolFees = array(
  '"'"'zr5'"'"' => 2.0,
  '"'"'scrypt'"'"' => 20.0,
  '"'"'sha256'"'"' => 5.0,
);
// Sample custom stratum ports
$configCustomPorts = array(
//  '"'"'x11'"'"' => 7000,
);
// mBTC Coefs per algo (default is 1.0)
$configAlgoNormCoef = array(
//  '"'"'x11'"'"' => 5.0,
);
' | tee /var/web/serverconfig.php >/dev/null 2>&1
    clear

    output "Updating stratum config files with database connection info."
    output ""
    cd /var/stratum/config
    sed -i 's/password = tu8tu5/password = '$blckntifypass'/g' *.conf
    sed -i 's/server = yaamp.com/server = '$server_name'/g' *.conf
    sed -i 's/host = yaampdb/host = localhost/g' *.conf
    sed -i 's/database = yaamp/database = yiimpfrontend/g' *.conf
    sed -i 's/username = root/username = stratum/g' *.conf
    sed -i 's/password = patofpaq/password = '$password2'/g' *.conf
    cd ~
    clear

    output "Final Directory permissions"
    output ""
    touch /var/log/debug.log

    chown -R www-data:www-data /var/stratum
    chown -R www-data:www-data /var/web
    chown -R www-data:www-data /var/log/debug.log

    chmod -R 775 /var/www/$server_name/html
    chmod -R 775 /var/web
    chmod -R 775 /var/stratum
    chmod -R 775 /var/web/yaamp/runtime
    chmod -R 664 /root/backup/
    chmod -R 644 /var/log/debug.log
    chmod -R 775 /var/web/serverconfig.php

    mv $HOME/yiimp/ $HOME/yiimp-install-only-do-not-run-commands-from-this-folder
    service nginx restart
    service php7.0-fpm reload
    clear

    output "Whew that was fun, just some reminders. Your mysql information is saved in ~/.my.cnf. this installer did not directly install anything required to build coins."
    output ""
    output "Please make sure to change your wallet addresses in the /var/web/serverconfig.php file."
    output ""
    output "Please make sure to add your public and private keys."
    output ""
    output "If you found this script helpful please consider donating some BTC Donation: 18AwGT19befE4Z3siEiAzsF8n9MoJEifiH"
