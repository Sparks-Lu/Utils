#!/bin/bash

pfx_path=$1
crt_path=extracted.crt
openssl pkcs12 -in $pfx_path -clcerts -nokeys -out $crt_path
