#!/bin/sh

for serv in kojira kojid httpd postgresql; do
	/sbin/service $serv stop
done

yum -y remove 'koji*' httpd mod_python mod_ssl postgresql-server

rm -rf /etc/koji* /etc/httpd/conf.d/koji* /var/lib/pgsql /etc/pki/koji /etc/httpd/conf.d/ssl.conf*

