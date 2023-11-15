#!/bin/bash
private_key=private_key.pem
input_file=input.txt
output_file=input.txt.sig
echo "Generate signagure using private key $private_key for file $input_file..."
#openssl rsautl -sign -in $input_file -inkey $private_key -out $output_file
openssl sha1 -sign $private_key -out $output_file $input_file
echo "Generated signature file: $output_file"
