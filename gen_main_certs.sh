#!/bin/sh

caname=koji
openssl genrsa -out private/${caname}_ca_cert.key 2048
openssl req -config ssl.cnf -new -x509 -days 3650 -key private/${caname}_ca_cert.key -out ${caname}_ca_cert.crt -extensions v3_ca

for user in kojiweb kojihub koji.russianfedora.pro; do
	openssl genrsa -out certs/${user}.key 2048
	openssl req -config ssl.cnf -new -nodes -out certs/${user}.csr -key certs/${user}.key
	openssl ca -config ssl.cnf -keyfile private/${caname}_ca_cert.key -cert ${caname}_ca_cert.crt -out certs/${user}.crt -outdir certs -infiles certs/${user}.csr
	cat certs/${user}.crt certs/${user}.key > ${user}.pem
done
