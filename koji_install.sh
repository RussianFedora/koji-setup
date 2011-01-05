#!/bin/sh

current_pwd=`pwd`
mkdir originals
backup_dir=$current_pwd/originals
echo "--> Installing PreReqs"
yum install -y httpd mod_ssl postgresql-server mod_python mock setarch rpm-build createrepo koji koji-hub koji-web koji-builder koji-utils

#backup and copy our files
mkdir -p /etc/pki/koji/{certs,private}
cp gen_*.sh ssl.cnf /etc/pki/koji
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
mv /etc/koji-hub/hub.conf $backup_dir/hub.conf.original
mv /etc/httpd/conf.d/kojihub.conf $backup_dir/kojihub.conf.original
mv /etc/httpd/conf.d/kojiweb.conf $backup_dir/kojiweb.conf.original
mv /etc/httpd/conf.d/ssl.conf $backup_dir/ssl.conf.original
mv /etc/kojid/kojid.conf $backup_dir/kojid.conf.original
mv /etc/koji.conf $backup_dir/koji.conf.original
mv /etc/kojira/kojira.conf $backup_dir/kojira.conf.original
cp conf/koji.conf /etc/
cp conf/kojid.conf /etc/kojid/
cp conf/kojira.conf /etc/kojira/
cp conf/hub.conf /etc/koji-hub/
cp conf/kojihub.conf /etc/httpd/conf.d/
cp conf/kojiweb.conf /etc/httpd/conf.d/
cp conf/ssl.conf /etc/httpd/conf.d/

echo "--> Generate certificates"
echo " --> Please setup koji building host (press Ctrl-D as finish):"
cd /etc/pki/koji
KOJI_BUILDING_HOST=`tac`
KOJI_DEFAULT_BUILDING_HOST=koji.russianfedora.ru
if [ "$KOJI_DEFAULT_BUILDING_HOST" != "$KOJI_BUILDING_HOST" ];
then
	echo "--> Change hostname in conf-files" # ssl.cnf and gen_main_certs.sh"
	sed -i "s/${KOJI_DEFAULT_BUILDING_HOST}/${KOJI_BUILDING_HOST}/g" ssl.cnf gen_main_certs.sh /etc/koji-hub/hub.conf /etc/httpd/conf.d/kojihub.conf /etc/httpd/conf.d/kojiweb.conf /etc/kojid/kojid.conf /etc/koji.conf /etc/kojira/kojira.conf
fi
IP=`ip addr show | grep inet | grep -v inet6 | grep -v 127.0 | sed 's/\/24//g' | awk '{print $2}'`
echo "$IP $KOJI_BUILDING_HOST" >> /etc/hosts
echo " --> Please write follow string to you client /etc/hosts"
echo "		$IP $KOJI_BUILDING_HOST"
echo " --> Please enter e-mail koji administrator for ssl (press Ctrl-D then finish type):"
KOJI_EMAIL=`tac`
sed -i "s/info@russianfedora.ru/${KOJI_EMAIL}/g" ssl.cnf /etc/koji-hub/hub.conf /etc/httpd/conf.d/kojihub.conf /etc/httpd/conf.d/kojiweb.conf
echo " --> Change e-mail in ssl.cnf"
touch index.txt
echo 01 > serial
echo " --> Please fill data or press Enter"
sh gen_main_certs.sh
echo " --> Please enter koji-admin name (press Ctrl-D to finish):"
KOJI_ADMIN_NAME=`tac`
echo " --> WARNING!!! This Common name must be a koji-admin name and e-mail - as koji-admin e-mail"
sh gen_user_certs.sh $KOJI_ADMIN_NAME
echo " --> Add user $KOJI_ADMIN_NAME in you client system and copy follow files to ~/.koji:"
echo " --> /etc/pki/koji/$KOJI_ADMIN_NAME.pem as ~/.koji/client.crt"
echo " --> /etc/pki/koji/koji_ca_cert.crt as ~/.koji/clientca.crt"
echo " --> /etc/pki/koji/koji_ca_cert.crt as ~/.koji/serverca.crt"
echo "--< Finish certificates"
cd $current_pwd

echo "--> Setup PosgreSQL"
echo " --> Install koji"
#yum install -y koji

echo " --> Create DB"
/sbin/service postgresql initdb
echo " --> Starting PgSql"
/sbin/service postgresql start

echo " --> Add user koji and fill database"
useradd koji
passwd -d koji
su - postgres -c 'createuser -S -D -R koji; createdb -O koji koji'
su - koji -c 'psql koji koji < /usr/share/doc/koji*/docs/schema.sql'

echo " --> Create koji admin account"
KOJI_DEF_ADMIN_NAME=koji-admin-name
PGSQL_SCRIPT=/tmp/create-user.sql
sed "s/${KOJI_DEF_ADMIN_NAME}/${KOJI_ADMIN_NAME}/g" create-user.sql > $PGSQL_SCRIPT
chmod 777 $PGSQL_SCRIPT
su - koji -c "psql koji koji < ${PGSQL_SCRIPT}"
sed -i "s/ident/trust/g" /var/lib/pgsql/data/pg_hba.conf
/sbin/service postgresql restart
echo "--< Finish PostgreSQL"

echo "--> Configure KojiHub"
echo " --> setup httpd for KojiHub"
sed -i "s/MaxRequestsPerChild\  0/MaxRequestsPerChild  100/g" /etc/httpd/conf/httpd.conf
echo " --> configure hub.conf and kojihub.conf"
echo " --> configure selinux"
setsebool -P httpd_can_network_connect_db 1
echo " --> configure koji filesystem skeleton"
mkdir -p /mnt/koji/{packages,repos,work,scratch}
chown -R apache.apache /mnt/koji

echo "--> Configure kojiweb"
/sbin/service httpd restart
echo "--< Finish kojiweb and kojihub. Web interface is now operational"

#############################################
echo "--> Install and configure koji-builder and kojira"
mkdir -p ~/.koji
cp /etc/pki/koji/${KOJI_ADMIN_NAME}.pem ~/.koji/client.crt
cp /etc/pki/koji/koji_ca_cert.crt ~/.koji/clientca.crt
cp /etc/pki/koji/koji_ca_cert.crt ~/.koji/serverca.crt

echo " --> Try add this host as buildhost for koji..."
koji add-host ${KOJI_BUILDING_HOST} i386 x86_64
koji add-host-to-channel ${KOJI_BUILDING_HOST} createrepo

echo " --> Try start kojid service..."
/sbin/service kojid start

echo " --> Try generate kojira certs..."
cd /etc/pki/koji
echo " --> WARNING! Set common name as kojira!"
sh gen_user_certs.sh kojira
cd $current_pwd

koji add-user kojira
koji grant-permission repo kojira
/sbin/service kojira start


