#!/bin/bash
# openssl pkeyutl -verify -rawin -pubin -inkey test.pub -in input.txt -sigfile input.txt.sig
input_file=input.txt
input_sig=input.txt.sig
public_key=public_key.pem
echo "Verify signature file $input_sig using public key $public_key for input file $input_file..."
openssl sha1 -verify $public_key -signature $input_sig $input_file
