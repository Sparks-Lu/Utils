#!/bin/bash
private_key_file=private_key.pem
public_key_file=public_key.pem
openssl rsa -pubout -in $private_key_file -out $public_key_file
echo "Generated public key into file $public_key_file from private key file $private_key_file"
