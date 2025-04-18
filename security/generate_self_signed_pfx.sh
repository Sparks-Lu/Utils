#!/bin/bash
echo 'create private key...'
openssl genpkey -algorithm RSA -out private.key -aes256
echo 'create certificate sign request...'
openssl req -new -key private.key -out server.csr -config vhuan.cnf
echo 'generate certificate...'
openssl x509 -req -days 365 -in server.csr -signkey private.key -out certificate.crt -extfile vhuan.cnf -extensions req_ext
echo 'generate .pfx...'
openssl pkcs12 -export -out vhuan20250124.pfx -inkey private.key -in certificate.crt -name "vhuan20250211"
