echo 'Submitting urls in urls.txt...'
curl -H 'Content-Type:text/plain' --data-binary @urls.txt "http://data.zz.baidu.com/urls?site=fishpano.com&token=dK9j7VKYon2iGeTY"
echo 'Finished'
