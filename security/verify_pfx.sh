echo "Input the pfx file path:"
read fn_certificate
echo "Input the password:"
read password
openssl pkcs12 -in $fn_certificate -nokeys -clcerts -password pass:$password
