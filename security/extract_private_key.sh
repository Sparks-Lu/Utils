#!/bin/bash
pfx_path=$1
openssl pkcs12 -in $pfx_path -nocerts -out key.pem -nodes
