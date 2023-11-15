#!/bin/bash
private_key_file=private_key.pem
openssl genpkey -algorithm RSA -out $private_key_file
echo "Generated private key file: $private_key_file"
