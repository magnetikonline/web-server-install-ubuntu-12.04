# Table of contents
- [Example environment overview](#example-environment-overview)
- [Initial tasks](#initial-tasks)
- [Nginx](#nginx)
- [PHP](#php)
- [PHP - Alternative PHP cache](#php---alternative-php-cache)
- [MySQL](#mysql)
- [Postfix](#postfix)
- [vnStat](#vnstat)

## Example environment overview
Instructions and supplied configuration files are based on the following fictional environment. Adjust your implementation and configuration to suit.

- **Operating system:** Ubuntu server 12.04.1 LTS
- **Public IP address:** 123.255.255.123
- **Hostname:** servername
- **Fully qualified domain name (FQDN):** servername.domainname.com
- **Website domain:** websitename.com

## Initial tasks

### Create user
- **Note:** replace `username` with desired Linux username
- `$ adduser [username]`
- Add new user to 'sudo' group
- `$ usermod -aG sudo [username]`
- Logout and re-login as `username` to continue configuration

### SSH server
- Disable root user SSH login and enable specific user(s) SSH login rights (using `username` from above steps)
- `$ sudo apt-get install openssh-server`
- `$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.pkg`
- Update `/etc/ssh/sshd_config` in place
- Configure `/etc/ssh/sshd_config`
	- Update `ListenAddress` directive, setting to the public IP address of server
	- Allow `username` SSH access to server, adding appropriate `AllowUsers [username]` directive
- `$ sudo reload ssh`

### Network
- `$ sudo cp /etc/network/interfaces /etc/network/interfaces.pkg`
- Update `/etc/network/interfaces` in place
- Configure network interface settings in `/etc/network/interfaces`
- `$ sudo /etc/init.d/networking restart`
- `$ ifconfig`
- `$ sudo cp /etc/sysctl.conf /etc/sysctl.conf.pkg`
- Update `/etc/sysctl.conf` in place
- `$ sudo sysctl -p`

### Hostname
- Update `/etc/hosts` in place
- Configure public IP address, server name `servername` and fully qualified domain name `servername.domainname.com` in `/etc/hosts`
- Update `/etc/hostname` in place
- Configure fully qualified domain name in `/etc/hostname` as `servername.domainname.com`
- `$ sudo hostname servername`
- Confirm hostname reported by server
- `$ hostname && hostname -f`
- Should return `servername` and `servername.domainname.com` respectively
- **Tip:** After successful hostname configuration is complete, ensure a reverse DNS entry (PTR record) has been added for your server. Important at the *very least* for outgoing SMTP ([Postfix](#postfix) in this example), as many receiving SMTP servers will perform a reverse IP lookup as the first line of validity checking for incoming email.
- `$ dig -x 123.255.255.123`
- Will return `servername.domainname.com` as the DNS server response if PTR record correctly configured.

### Logrotate / rsyslog
- **Note:** I choose to place all rotated logs into `/var/log/00rotated` for separation from currently active log files.
- `$ sudo mkdir -p /var/log/00rotated`
- Clean up some orphan log files we don't need
- `$ sudo rm /var/log/mail.*`
- `$ sudo rm /var/log/ufw.log`
- `$ sudo rm -r /var/log/news`
- **Note:** I prefer to have all log rotation config within `/etc/logrotate.conf` rather than including the default `/etc/logrotate.d/*` sub-configs.
- `$ sudo cp /etc/logrotate.conf /etc/logrotate.conf.pkg`
- Update `/etc/logrotate.conf` in place
- `$ sudo cp /etc/rsyslog.conf /etc/rsyslog.conf.pkg`
- Update `/etc/rsyslog.conf` in place
- `$ sudo stop rsyslog && sudo start rsyslog`
- Test services are logging as required and log rotations function correctly.

### Crontab
- **Note:** I prefer to have all cron jobs located in a single `/etc/crontab` rather than using `/etc/cron(daily|weekly|monthly)`.
- `$ sudo cp /etc/crontab /etc/crontab.pkg`
- Update `/etc/crontab` in place
- Setup bash script to run all nightly tasks (server time sync, log rotations, system backups, web statistics generation, etc.)
- `$ sudo mkdir -p /var/server/cron`
- Copy `/var/server/cron/00nightly.sh` in place
- `$ sudo chmod u+x /var/server/cron/00nightly.sh`

### Software firewall (Uncomplicated firewall)
- **Note:** If you have a correctly configured hardware firewall between the server and public internet you can skip these steps, running without the overhead of a software based firewall.
- `$ sudo apt-get install ufw`
- `$ sudo mkdir -p /var/server/script`
- Copy `/var/server/script/ufw-rulesetup.sh` in place
- Copy `/var/server/script/ufw-ruleclear.sh` in place
- `$ sudo chmod u+x /var/server/script/ufw-*.sh`
- `$ sudo /var/server/script/ufw-rulesetup.sh`
- `$ sudo ufw enable`
- `$ sudo ufw status verbose`
- **Note:** Adjust the allowed incoming ports as required. Provided `/var/server/script/ufw-rulesetup.sh` opens ports **22** and **80** for SSH (rate limited) and HTTP respectively only.

### Remove AppArmor
- **Note:** YMMV, but I am personally not a fan of AppArmor so choose to remove it, but you can skip these steps if desired.
- `$ sudo /etc/init.d/apparmor stop`
- `$ sudo update-rc.d -f apparmor remove`
- `$ sudo apt-get remove apparmor`

## Nginx

### Build from source
- `$ sudo su`
- `# apt-get install checkinstall libpcre3-dev zlib1g-dev`
- `# mkdir -p ~/build/nginx && cd ~/build/nginx`
- `# wget http://nginx.org/download/nginx-1.4.1.tar.gz`
- `# tar xvf nginx-1.4.1.tar.gz && cd nginx-1.4.1`
- Configure Nginx makefile as required, refer to [configure.nginx.txt](configure.nginx.txt) for an example
- Make and build deb package
- `# make`
- `# checkinstall -D --nodoc make -i install`
	- Name output deb package (e.g. `Nginx 1.4.1`)
	- Press enter to proceed with package creation
- Review built deb package contents
- `# dpkg -c nginx_1.4.1-1_amd64.deb`
- **Optional:** Save `nginx_1.4.1-1_amd64.deb` package for later use

### Configure
- **Note:** Configuration has been provided as an example, certain sections assume Nginx paths have been set as per [configure.nginx.txt](configure.nginx.txt). You will need to modify `/etc/nginx/nginx.conf` presented here to suit your specific requirements.
- Copy upstart init script `/etc/init/nginx.conf` in place
- `$ sudo mkdir -p /var/www/00`
- `$ sudo mkdir -p /var/log/nginx/00`
- `$ sudo touch /var/www/00/index.html`
- `$ sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.pkg`
- Update `/etc/nginx/nginx.conf` in place
- `$ sudo cp /etc/nginx/mime.types /etc/nginx/mime.types.pkg`
- Update `/etc/nginx/mime.types` in place
- `$ sudo cp /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.pkg`
- Update `/etc/nginx/fastcgi_params` in place
- `$ sudo mkdir -p /etc/nginx/conf`
- Copy `/etc/nginx/conf/phpfastcgi` in place
- `$ sudo start nginx`
- Nginx runtime statistics will be available via http://servername.domainname.com/_nginx563458 (URL configured or disabled via `/etc/nginx/nginx.conf`).

## PHP

### Build from source
- `$ sudo su`
- `# apt-get install checkinstall libxml2-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev`
- `# mkdir -p ~/build/php && cd ~/build/php`
- `# wget http://php.net/get/php-5.4.16.tar.gz/from/this/mirror -O php-5.4.16.tar.gz`
- `# tar xvf php-5.4.16.tar.gz && cd php-5.4.16`
- Configure PHP makefile as required, refer to [configure.php.txt](configure.php.txt) for an example
- Make and build deb package
- `# make`
- `# checkinstall -D --nodoc make -i install`
	- Name output deb package (e.g. `PHP 5.4.16`)
	- Press enter to proceed with package creation
- Review built deb package contents
- `# dpkg -c php_5.4.16-1_amd64.deb`
- **Optional:** Save `php_5.4.16-1_amd64.deb` package for later use

### Configure
- **Note:** Configuration has been provided as an example, certain sections assume PHP paths have been set as per [configure.php.txt](configure.php.txt). You will need to modify `/etc/php5/php.ini` and `/etc/php5/php-fpm.ini` presented here to suit your specific requirements.
- Copy upstart init script `/etc/init/php-fpm.conf` in place
- `$ sudo mkdir -p /etc/php5/ext`
- Copy `/etc/php5/php-fpm.conf` in place
- Copy `/etc/php5/php.ini` in place
- `$ sudo touch /var/log/phperror`
- `$ sudo chown www-data: /var/log/phperror`
- `$ sudo start php-fpm`
- PHP-FPM runtime statistics will be available at http://servername.domainname.com/_phpfpm346234. This URL can be configured or disabled via `/etc/php5/php-fpm.conf` and `/etc/nginx/nginx.conf`.

## PHP - Alternative PHP cache

### Build from source
- `$ sudo su`
- `# apt-get install autoconf`
- `# mkdir -p ~/build/phpapc && cd ~/build/phpapc`
- `# wget http://pecl.php.net/get/APC-3.1.14.tgz`
- `# tar xvf APC-3.1.14.tgz && cd APC-3.1.14`
- `# phpize`
- `# ./configure`
- `# make`
- `# mv ./modules/apc.so /etc/php5/ext`

### Configure
- A base configuration is provided under the `[apc]` section of `/etc/php5/php.ini`, tweak settings as required to suit your PHP application(s).
- `$ sudo stop php-fpm && sudo start php-fpm`

## MySQL

### Install
- `$ sudo apt-get install mysql-server`
- Enter new root password

### Configure
- `$ sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.pkg`
- Update `/etc/mysql/my.cnf` in place
- `$ sudo rm /var/log/mysql.*`
- `$ sudo stop mysql`
- Delete initial InnoDB log files to be recreated at their new size (set by `innodb_log_file_size` in `/etc/mysql/my.cnf`) upon MySQL startup.
- `$ sudo rm /var/lib/mysql/ib_logfile?`
- `$ sudo start mysql`

## Postfix

### Install
- `$ sudo apt-get install postfix`
- Select **No configuration** during install

### Configure
- `$ sudo cp /usr/share/postfix/main.cf.dist /etc/postfix/main.cf.pkg`
- Copy `/etc/postfix/main.cf` in place
- Confirm the following `/etc/postfix/main.cf` settings:
	- `$ postconf | grep "^inet_interfaces"`
	- `$ postconf | grep "^myhostname"`
	- `$ postconf | grep "^mynetworks"`
	- `$ postconf | grep "^smtpd_recipient_restrictions"`
- Rebuild `/etc/aliases` lookup database
- `$ sudo newaliases`
- `$ sudo /etc/init.d/postfix start`

## vnStat

### Build from source
- `$ sudo su`
- `# apt-get install gcc libgd2-xpm-dev`
- `# mkdir -p ~/build/vnstat && cd ~/build/vnstat`
- `# wget http://humdi.net/vnstat/vnstat-1.11.tar.gz`
- `# tar xvf vnstat-1.11.tar.gz`
- `# cd vnstat-1.11`
- `# make all`
- `# mkdir -p /var/server/vnstat`
- `# cp ./src/vnstat ./src/vnstatd ./src/vnstati /var/server/vnstat`

### Configure
- Copy upstart init script `/etc/init/vnstat.conf` in place
- `$ sudo mkdir -p /var/lib/vnstat`
- `$ sudo start vnstat`
- `$ mkdir -p /var/server/vnstat`
- Copy `/var/server/vnstat/buildimages.sh` in place
- `$ sudo chmod u+x /var/server/vnstat/buildimages.sh`
- Copy `/var/server/vnstat/vnstat.conf` in place
- Create public web directory for generated vnStat graph images
- `$ sudo mkdir -p /var/www/00/_vnstat768438`
- Network traffic statistics generated every 20 minutes will be available at http://servername.domainname.com/_vnstat768438/ (URL configured via `/var/server/vnstat/buildimages.sh`, reporting frequency via `/etc/crontab`).
