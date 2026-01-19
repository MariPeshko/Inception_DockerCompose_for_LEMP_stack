```bash
docker build -t my_nginx ./requirements/nginx

docker run -d --name nginx_cont \
    --network inception_network \
    --env-file .env \
    -p 443:443 \
    -v /home/mpeshko/data/wordpress:/var/www/html \
    my_nginx
```

Log of errors:

1. docker logs nginx_cont
2026/01/19 14:23:38 [emerg] 1#1: unknown "ssl_cert" variable

My container is crashing because Nginx cannot read environment variables ($SSL_CERT) directly from its configuration file.

When Nginx sees ${SSL_CERT} in the nginx.conf file, it thinks it is its own internal variable (like $uri or $host), cannot find its description, and throws an unknown variable error.