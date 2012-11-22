# Web server install - Ubuntu 12.04LTS

## What is this?
A step-by-step [install guide](webserverinstall.ubuntu12.04/blob/master/install.md) for a Nginx, PHP & MySQL enabled web application server using Ubuntu 12.04LTS server as the distribution base.

The guide is based upon previous experience of web server installs and is the basis of the steps I typically undertake when provisioning new production servers. Steps have been broken down into high level components to allow the inclusion/exclusion of specific server items as required.

I will try my best to keep this guide updated as I make changes/improvements to my install methods and when new stable builds of Nginx/PHP are released.

Finally for overall success, it's expected the reader has at least moderate experience with the Linux/Unix shell and can get their way around the file system.

## Feature set
After successful install, you should have the following components available and configured.

- Ubuntu 12.04LTS server with:
	- SSH shell
	- Correctly configured network/hostname
	- System logging & log rotation
	- Software firewall
- Nginx web server
- PHP (both PHP-FPM & PHP-CLI)
- PHP - Alternative PHP cache for opcode caching
- MySQL
- Postfix MTA as an outgoing SMTP mail server
- vnStat with automated graph generation for basic network traffic monitoring

Note that the performance critical components of Nginx and PHP are compiled from source rather than pre-built packages.

Personally, I have found that successful compilation of these components are rather trivial under recent releases of Ubuntu/Debian so this does not typically add complexity to the process. Plus, it allows the easy upgrade of new stable source releases as they are made available, rather than sourcing alternative third party repositories.

## Configuration files
Every configuration file added or modified on top of a base Ubuntu 12.04LTS server install has been added as part of this repository under the [/00root](webserverinstall.ubuntu12.04/tree/master/00root) directory. This is typically how I manage my own workflow, keeping all configuration files for each server in private Git repositories so I can reliably track changes/modifications to server environments.

**Note:** many configuration files are specific to physical server/application stack requirements (e.g. network/hostname, open firewall ports, Nginx, PHP), so these configurations for the most part should **not** be copied verbatim, but adjusted where appropriate. All configuration does follow a mock [example environment](webserverinstall.ubuntu12.04/blob/master/install.md#example-environment-overview) to help the reader understand the configuration easier.

## What about [insert component], shouldn't that be part of the stack?
- **DNS server:** I have previously installed instances of BIND for hosting domain name records, but the fact you really should setup two or more instances (primary/secondary) on physically separate networks plus the additional CPU/RAM overhead on lower end VPS systems, I'm now of the opinion this is all better served by a third party service. There are several big players in this game at very reasonable pricing (I'm personally a fan of [DNS Made Easy](http://www.dnsmadeeasy.com/)) and can offer a level of performance and redundancy that would be hard to match with a roll-your-own solution.
- **Incoming SMTP/POP3/IMAP:** Somewhat leading on from above, setting up incoming SMTP/POP3/IMAP services with spam mail filtering is certainly possible, but assuming you then take steps to regularly train/update spam rulesets, control CPU overheads of analysing incoming emails (which could be better used serving web apps) and finally actually having enough disk space to hold all those gigabytes of users email, it soon could become a source of frustration. I think most people would agree, something like [Google Apps](http://www.google.com/intl/en_au/enterprise/apps/business/) really is the sane way to go.

## Feedback & comments?
If anyone has any suggestions for improvement, finds typos/bugs, flat out disapproves with how I do things on the server(!) or needs something explained a little better - let me know. Or better yet, fork and submit a pull-request. Would really appreciate any and all feedback.
