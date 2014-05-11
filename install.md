# Table of contents
- [Example environment overview](#example-environment-overview)
- [Initial tasks](#initial-tasks)
- [Nginx](#nginx)
- [PHP](#php)
- [MySQL](#mysql)
- [Postfix](#postfix)
- [vnStat](#vnstat)


## Example environment overview
Instructions and supplied configuration files are based on the following fictional environment. Adjust your implementation and configuration to suit.

- **Operating system:** Ubuntu server 12.04.4 LTS
- **Public IP address:** 123.255.255.123
- **Hostname:** servername
- **Fully qualified domain name (FQDN):** servername.domainname.com
- **Website domain:** websitename.com


## Initial tasks

### Create user, add to sudo group
- **Note:** replace `username` with desired Linux username

	```sh
	$ sudo su
	# adduser [username]
	# usermod -aG sudo [username]
	```

- Logout and re-login as `username` to continue with setup

### SSH server
- Disable root user SSH login and enable specific user(s) SSH login rights (using `username` from above steps)

	```sh
	$ sudo apt-get install openssh-server
	$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.pkg
	```

- Update `/etc/ssh/sshd_config` in place
- Configure `/etc/ssh/sshd_config`
	- Update `ListenAddress` directive, setting to the public IP address of server
	- Allow `username` SSH access to server, adding appropriate `AllowUsers [username]` directive
- Ensure `.ssh` directory permissions are locked down
	- `$ sudo chmod 0700 /home/[username]/.ssh`
- `$ sudo reload ssh`

### Network
- `$ sudo cp /etc/network/interfaces /etc/network/interfaces.pkg`
- Update `/etc/network/interfaces` in place
- Configure network interface settings in `/etc/network/interfaces`

	```sh
	$ sudo /etc/init.d/networking restart
	$ ifconfig
	$ sudo cp /etc/sysctl.conf /etc/sysctl.conf.pkg
	```

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

	```sh
	$ sudo rm /var/log/mail.*
	$ sudo rm /var/log/ufw.log
	$ sudo rm -rf /var/log/news
	```

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

	```sh
	$ sudo apt-get install ufw
	$ sudo mkdir -p /var/server/script
	```

- Copy `/var/server/script/ufw-rulesetup.sh` in place
- Copy `/var/server/script/ufw-ruleclear.sh` in place

	```sh
	$ sudo chmod u+x /var/server/script/ufw-*.sh
	$ sudo /var/server/script/ufw-rulesetup.sh
	$ sudo ufw enable
	$ sudo ufw status verbose
	```

- **Note:** Adjust the allowed incoming ports as required. Provided `/var/server/script/ufw-rulesetup.sh` opens ports **22** and **80** for SSH (rate limited) and HTTP respectively only.

### Remove AppArmor
- **Note:** YMMV, but I am personally not a fan of AppArmor so choose to remove it, but you can skip these steps if desired.

	```sh
	$ sudo /etc/init.d/apparmor stop
	$ sudo update-rc.d -f apparmor remove
	$ sudo apt-get purge apparmor
	```


## Nginx

### Build from source

```sh
$ sudo su
# apt-get install checkinstall libpcre3-dev zlib1g-dev
# mkdir -p ~/build/nginx && cd ~/build/nginx
# wget http://nginx.org/download/nginx-1.6.0.tar.gz
# tar xvf nginx-1.6.0.tar.gz && cd nginx-1.6.0
```

- If building Nginx with SSL support (`--with-http_ssl_module`) change the above `apt-get install` line to the following

	```sh
	# apt-get install checkinstall libpcre3-dev libssl-dev zlib1g-dev
	```

- Configure Nginx makefile as required, refer to [configure.nginx.txt](configure.nginx.txt) for an example
- Make and build deb package

	```sh
	# make
	# echo "Nginx 1.6.0" > description-pak && checkinstall -Dy --install=no --nodoc make -i install
	```

- Nginx deb package has now been created with the following filename:
	- `nginx_1.6.0-1_amd64.deb` for **64 bit** Ubuntu server
	- `nginx_1.6.0-1_i386.deb` for **32 bit** Ubuntu server
- Review then install the built deb package, optionally save `nginx_1.6.0-1_*.deb` package for later use (recommended)

	```sh
	# dpkg -c nginx_1.6.0-1_*.deb
	# dpkg -i nginx_1.6.0-1_*.deb
	```

- To remove/re-install Nginx package

	```sh
	$ sudo su
	# stop nginx
	# dpkg -r nginx
	# dpkg -i nginx_1.6.0-1_*.deb
	```

### Configure
- **Note:** Configuration has been provided as an example, certain sections assume Nginx paths have been set as per [configure.nginx.txt](configure.nginx.txt). You **will** need to modify `/etc/nginx/nginx.conf` presented here to suit your specific requirements.
- **Note:** A suggested SSL virtual host configuration has also been included (commented out) as follows. In addition, changes to `/var/server/script/ufw-rulesetup.sh` and `/var/server/script/ufw-ruleclear.sh` will be required to open port `443`.

		http {

			# -- SNIP --

			ssl_session_cache shared:SSL:5m;
			ssl_session_timeout 5m;

			# -- SNIP --

			server {
				listen 123.255.255.123:443 default_server ssl;

				keepalive_timeout 30;
				ssl_certificate /etc/nginx/cert/websitename.com.crt;
				ssl_certificate_key /etc/nginx/cert/websitename.com.key;

				# -- SNIP --
			}
		}

- Copy upstart init script `/etc/init/nginx.conf` in place

	```sh
	$ sudo mkdir -p /var/www/00
	$ sudo mkdir -p /var/log/nginx/00
	$ sudo touch /var/www/00/index.html
	$ sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.pkg
	```

- Update `/etc/nginx/nginx.conf` in place
- `$ sudo cp /etc/nginx/mime.types /etc/nginx/mime.types.pkg`
- Update `/etc/nginx/mime.types` in place
	- **Note:** alternatively you may wish to use the [mime.types.essential](00root/etc/nginx/mime.types.essential) definitions as a cut-down common use set of MIME types.
- `$ sudo cp /etc/nginx/fastcgi_params /etc/nginx/fastcgi_params.pkg`
- Update `/etc/nginx/fastcgi_params` in place
- `$ sudo mkdir -p /etc/nginx/conf`
- Copy `/etc/nginx/conf/phpfastcgi` in place
- `$ sudo start nginx`
- Nginx runtime statistics will be available via http://servername.domainname.com/_nginx563458 (URL configured or disabled via `/etc/nginx/nginx.conf`).


## PHP

### Build from source

```sh
$ sudo su
# apt-get install checkinstall libxml2-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev
# mkdir -p ~/build/php && cd ~/build/php
# wget http://php.net/get/php-5.5.12.tar.gz/from/this/mirror -O php-5.5.12.tar.gz
# tar xvf php-5.5.12.tar.gz && cd php-5.5.12
```

- Configure PHP makefile as required, refer to [configure.php.txt](configure.php.txt) for an example
- Make and build deb package

	```sh
	# make
	# echo "PHP 5.5.12" > description-pak && checkinstall -Dy --install=no --nodoc make -i install
	```

- PHP deb package has now been created with the following filename:
	- `php_5.5.12-1_amd64.deb` for **64 bit** Ubuntu server
	- `php_5.5.12-1_i386.deb` for **32 bit** Ubuntu server
- Review then install the built deb package, optionally save `php_5.5.12-1_*.deb` package for later use (recommended)

	```sh
	# dpkg -c php_5.5.12-1_*.deb
	# dpkg -i php_5.5.12-1_*.deb
	```

- To remove/re-install PHP package

	```sh
	$ sudo su
	# stop php-fpm
	# dpkg -r php
	# dpkg -i php_5.5.12-1_*.deb
	```

- **Note:** Zend OPcache
	- As of PHP 5.5.0 the [Zend OPcache](http://php.net/opcache) extension has been open sourced and subsequently bundled with the PHP source distribution. The existing [Alternative PHP Cache](http://www.php.net/manual/en/book.apc.php) (APC) project as a result is no longer under development and therefore is **not** recommended for use with PHP 5.5.0 or above.
	- The Zend OPcache is built automatically by default as a shared extension, enabled with the supplied [php.ini](00root/etc/php5/php.ini) provided in this guide and is recommended for use with any production PHP install to improve application performance. The extension will be installed to the `/usr/local/lib/php/extensions/no-debug-non-zts-20121212/` directory as `opcache.so`.
	- If you wish to disable the build of Zend OPcache module you can do so by providing the `--disable-all` flag during the `./configure` step and then reinclude each required PHP extension. The supplied `/etc/php5/php.ini` will also need updating to remove inclusion of the extension.

### Configure
- **Note:** Configuration has been provided as an example, certain sections assume PHP paths have been set as per [configure.php.txt](configure.php.txt). You **will** need to modify `/etc/php5/php.ini` and `/etc/php5/php-fpm.ini` presented here to suit your specific requirements.
- Copy upstart init script `/etc/init/php-fpm.conf` in place
- `$ sudo mkdir -p /etc/php5/ext`
- Copy `/etc/php5/php-fpm.conf` in place
- Copy `/etc/php5/php.ini` in place

	```sh
	$ sudo touch /var/log/phperror
	$ sudo chown www-data: /var/log/phperror
	$ sudo start php-fpm
	```

- PHP-FPM runtime statistics will be available at http://servername.domainname.com/_phpfpm346234. This URL can be configured or disabled via `/etc/php5/php-fpm.conf` and `/etc/nginx/nginx.conf`.


## MySQL

### Install
- `$ sudo apt-get install mysql-server`
- Enter new root password

### Configure
- `$ sudo cp /etc/mysql/my.cnf /etc/mysql/my.cnf.pkg`
- Update `/etc/mysql/my.cnf` in place

	```sh
	$ sudo rm /var/log/mysql.*
	$ sudo stop mysql
	```

- Delete initial InnoDB files to be recreated (`ib_logfile?` sizes set by `innodb_log_file_size` in `/etc/mysql/my.cnf`) upon MySQL startup.

	```sh
	$ sudo rm /var/lib/mysql/ibdata1
	$ sudo rm /var/lib/mysql/ib_logfile?
	$ sudo start mysql
	```

- **Note:** InnoDB tables have been configured to use individual files per each table/index space via the `innodb_file_per_table` setting in `/etc/mysql/my.cnf` and is the default as of MySQL 5.6.6.


## Postfix

### Install
- `$ sudo apt-get install postfix`
- Select **No configuration** during install

### Configure
- `$ sudo cp /usr/share/postfix/main.cf.dist /etc/postfix/main.cf.pkg`
- Copy `/etc/postfix/main.cf` in place
- Confirm the following `/etc/postfix/main.cf` settings

	```sh
	$ postconf | grep "^inet_interfaces"
	$ postconf | grep "^myhostname"
	$ postconf | grep "^mynetworks"
	$ postconf | grep "^smtpd_recipient_restrictions"
	```

- Rebuild `/etc/aliases` lookup database

	```sh
	$ sudo newaliases
	$ sudo /etc/init.d/postfix start
	```


## vnStat

### Build from source

```sh
$ sudo su
# apt-get install gcc libgd2-xpm-dev
# mkdir -p ~/build/vnstat && cd ~/build/vnstat
# wget http://humdi.net/vnstat/vnstat-1.11.tar.gz
# tar xvf vnstat-1.11.tar.gz
# cd vnstat-1.11
# make all
# mkdir -p /var/server/vnstat
# cp ./src/vnstat ./src/vnstatd ./src/vnstati /var/server/vnstat
```

### Configure
- Copy upstart init script `/etc/init/vnstat.conf` in place

	```sh
	$ sudo mkdir -p /var/lib/vnstat
	$ sudo start vnstat
	$ mkdir -p /var/server/vnstat
	```

- Copy `/var/server/vnstat/buildimages.sh` in place
- `$ sudo chmod u+x /var/server/vnstat/buildimages.sh`
- Copy `/var/server/vnstat/vnstat.conf` in place
- Create public web directory for generated vnStat graph images
- `$ sudo mkdir -p /var/www/00/_vnstat768438`
- Network traffic statistics generated every 20 minutes will be available at http://servername.domainname.com/_vnstat768438/ (URL configured via `/var/server/vnstat/buildimages.sh`, reporting frequency via `/etc/crontab`).
