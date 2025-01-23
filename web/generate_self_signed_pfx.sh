#!/bin/bash
echo 'create private key...'
openssl genpkey -algorithm RSA -out private.key -aes256
echo 'create certificate sign request...'
openssl req -new -key private.key -out server.csr
echo 'generate certificate...'
openssl x509 -req -days 365 -in server.csr -signkey private.key -out certificate.crt
echo 'generate .pfx...'
openssl pkcs12 -export -out cis20250123.pfx -inkey private.key -in certificate.crt -name "cis20250123"

