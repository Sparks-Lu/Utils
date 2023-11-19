#!/bin/bash
# openssl pkeyutl -verify -rawin -pubin -inkey test.pub -in input.txt -sigfile input.txt.sig
input_file=input_3.txt
input_sig=b64_3.txt.sig
public_key=public_key_2.pem
base64 -d $input_sig >/tmp/input.sig
echo "Verify signature file /tmp/input.sig using public key $public_key for input file $input_file..."
openssl sha1 -verify $public_key -signature $input_sig $input_file
