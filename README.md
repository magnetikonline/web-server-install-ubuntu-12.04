# Web server install - Ubuntu 12.04 LTS

## What is this?
A step-by-step [install guide](install.md) for a Nginx, PHP & MySQL enabled web application server based on Ubuntu 12.04LTS.

The guide is based upon previous experience of web server installs and is the basis of the steps I typically undertake when provisioning new production servers. Steps have been broken down into high level components to allow the inclusion/exclusion of specific server items as required.

I will try my best to keep this guide updated as I make changes/improvements to my install methods and when new stable builds of Nginx/PHP are released.

Finally for overall success, it's expected the reader has at least moderate experience with the Linux/Unix shell and can get their way around the file system.

## Feature set
- **Ubuntu 12.04.2 LTS** server with:
	- SSH shell
	- Correctly configured network & hostname
	- System logging & log rotation
	- Software firewall
- **Nginx** web server
- **PHP** (PHP-FPM & PHP-CLI with Zend OPcache provided with PHP 5.5.0+)
- **MySQL**
- **Postfix** MTA as an outgoing SMTP mail server
- **vnStat** with automated graph generation for basic network traffic monitoring

Note that the performance critical components of Nginx and PHP are compiled from source rather than pre-built repository packages. Successful compilation of these components under Ubuntu/Debian is well supported, ensures latest stable builds are used and allows a fast upgrade path as source releases are made available.

## Configuration files
Each file added or modified on top of a base Ubuntu 12.04LTS server install has been included in this repository within the [/00root](00root) directory. This is how I handle server change management, keeping all configuration files for each server in private Git repositories so I can reliably track changes and modifications to server environments.

**Note:** many configuration files are specific to physical server/application stack requirements (e.g. network/hostname, open firewall ports, Nginx, PHP), so these configurations for the most part should **not** be copied verbatim, but adjusted where appropriate. All configuration does follow a mock [example environment](install.md#example-environment-overview) to help the reader understand the configuration easier.

## What about [insert component], shouldn't that be part of the stack?
- **DNS server:** I have previously installed instances of BIND for hosting domain name records, but the fact you really should setup two or more instances (primary/secondary) on physically separate networks plus the additional CPU/RAM overhead on lower end VPS systems, I'm now of the opinion this is all better served by a third party service. There are several big players in this game at very reasonable pricing (I'm personally a fan of [DNS Made Easy](http://www.dnsmadeeasy.com/)) and can offer a level of performance and redundancy that would be hard to match with a roll-your-own solution.
- **Incoming SMTP/POP3/IMAP:** Somewhat leading on from above, setting up incoming SMTP/POP3/IMAP services with spam mail filtering is certainly possible, but assuming you then take steps to regularly train/update spam rule sets, control CPU overheads of analysing incoming emails (which could be better used serving web apps) and finally actually having enough disk space to hold all those gigabytes of users email, it soon could become a source of frustration. I think most people would agree, something like [Google Apps](http://www.google.com/intl/en_au/enterprise/apps/business/) really is the sane way to go.

## Feedback & comments?
If anyone has any suggestions for improvement, finds typos/bugs, flat out disapproves with how I do things on the server(!) or needs something explained a little better - let me know. Or better yet, submit a pull-request. Would appreciate any feedback or improvements to this guide.
