#!/bin/sh
# openssl pkcs12 -in "$1" -nocerts -nodes -out privatekey.pem
openssl pkcs12 -in "$1" -clcerts -nokeys -out certificate.pem
openssl x509 -enddate -noout -in certificate.pem
