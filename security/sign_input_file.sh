#!/bin/bash
input_file=input.txt
sig_file=input.txt.sig 
private_key_file=private_key.pem
openssl dgst -sign $private_key_file -out $sig_file $input_file
echo "Signed input file $input_file using private key file $private_key_file. Result file: $sig_file"
