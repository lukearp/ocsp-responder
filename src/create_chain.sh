#!/bin/sh

cd /root/tls

openssl genrsa -out /root/tls/private/ca.key.pem 2048
chmod 400 /root/tls/private/ca.key.pem

openssl req -config /root/tls/openssl.cnf \
      -key /root/tls/private/ca.key.pem \
      -new -x509 -days 3650 -sha256 -extensions v3_ca \
      -out /root/tls/certs/ca.cert.pem \
      -subj "/C=US/ST=CA/L=TE/O=TEST/OU=TESTING/CN=intermediate-cert.$ROOT_DOMAIN"


echo "Created Root Certificate"

chmod 444 /root/tls/certs/ca.cert.pem

#openssl genrsa -out intermediate/private/intermediate.key.pem 2048
#chmod 400 /root/tls/intermediate/private/intermediate.key.pem

#echo "Created Intermediate Private Key"

#openssl req -config intermediate/openssl.cnf \
#      -key /root/tls/intermediate/private/intermediate.key.pem \
#      -new -sha256 \
#      -out /root/tls/intermediate/csr/intermediate.csr.pem \
#      -subj "/C=US/ST=CA/L=TE/O=TEST/OU=TESTING/CN=intermediate-cert.$ROOT_DOMAIN/EMAIL=sec@$ROOT_DOMAIN"


#echo "Created Intermediate CSR"

#Creating an intermediate certificate, by signing the previous csr with the CA key based on root ca config with the directive v3_intermediate_ca extension to sign the intermediate CSR
#openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 2650 -notext -batch -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem

#echo "Created Intermediate Certificate Signed by root CA"

#Grant everyone reading rights
#chmod 444 /root/tls/intermediate/certs/intermediate.cert.pem


#Creating certificate chain with intermediate and root
cat /root/tls/certs/ca.cert.pem > /root/tls/intermediate/certs/ca-chain.cert.pem
chmod 444 /root/tls/intermediate/certs/ca-chain.cert.pem


#Create a Certificate revocation list of the intermediate CA
openssl ca -config /root/tls/intermediate/openssl.cnf \
      -gencrl -out /root/tls/intermediate/crl/intermediate.crl.pem

#Create OSCP key pair
openssl genrsa -out /root/tls/intermediate/private/ocsp.key.pem 2048

#Create the OSCP CSR
openssl req -config /root/tls/intermediate/openssl.cnf -new -sha256 \
      -key /root/tls/intermediate/private/ocsp.key.pem \
      -out /root/tls/intermediate/csr/ocsp.csr.pem \
      -nodes \
      -subj "/C=US/ST=CA/L=TE/O=TEST/OU=TESTING/CN=ocsp-cert.$ROOT_DOMAIN/EMAIL=sec@$ROOT_DOMAIN"


#Sign it
echo -e "y\ny\n" | openssl ca -config /root/tls/intermediate/openssl.cnf \
      -extensions v3_ocsp -days 375 -notext -md sha256 \
      -in /root/tls/intermediate/csr/ocsp.csr.pem \
      -out /root/tls/intermediate/certs/ocsp.cert.pem