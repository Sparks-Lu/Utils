# generate private key
openssl genpkey -algorithm RSA -out pfx/private.key
# generate CSR (Certificate Signing Request)
openssl req -new -key pfx/private.key -out pfx/csr.csr
# generate certificate using private key and CSR
openssl x509 -req -days 365 -in pfx/csr.csr -signkey pfx/private.key -out pfx/certificate.crt
# generate pfx
openssl pkcs12 -export -out pfx/certificate.pfx -inkey pfx/private.key -in pfx/certificate.crt -passout pass:password
