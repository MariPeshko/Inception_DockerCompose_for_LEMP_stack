You can create the network manually before starting:

```bash
docker network create inception_network

#build maria

docker run -d --name mariadb_container \
--network inception_network \
--env-file .env \
-v /home/mpeshko/data/mariadb:/var/lib/mysql \
my_mariadb

docker build -t my_wordpress ./requirements/wordpress

docker run -d --name wordpress_container \
    --network inception_network \
    --env-file .env \
    -v /home/mpeshko/data/wordpress:/var/www/html \
    my_wordpress
```

Are the containers on the same network?
```bash
docker network inspect inception_network
```

### **Nginx → WordPress tests**

1. Checking Nginx configuration (simplest)

```bash
docker exec nginx_cont nginx -t
```

2. Checking from the host machine (Debian)
```bash
curl -v -k --resolve mpeshko.42.fr:443:127.0.0.1 https://mpeshko.42.fr
```

3. With curl

```bash
docker exec nginx_cont curl -I wordpress_container:9000
```

What we expect: Since port 9000 is not HTTP, but FastCGI, curl may throw an error like Connection reset by peer (or Empty reply from server, Connection reset) .

Why this is a success: If you see any response other than Could not resolve host or Connection refused, then Nginx knows where WordPress is located and the port is open.

Why does this prove that everything works?
- If the container was down, you would get: *Could not resolve host*.
- If the network was configured incorrectly, you would get: *No route to host*.
- If the port was closed or the PHP-FPM script was not listening on the network, you would get: *Connection refused*.

4. 
```bash
docker exec nginx_cont curl -I -k https://localhost
```

Expected result: HTTP/1.1 200 OK

This will confirm that Nginx successfully "translated" your HTTP request into FastCGI, passed it to WordPress, received the response, and returned it to you.

5. Checking site availability (HTTP → HTTPS)

Let's try to simulate accessing the site via the terminal of the host machine (Debian). Since we are using a self-signed certificate, we add the -k (ignore insecure) flag.

```bash
curl -k https://localhost
```

If this test (curl -k) gave an error *Error establishing a database connection*, then the Nginx-WordPress connection is there, but the WordPress-MariaDB connection is not.

If you see the HTML page, the connection is perfect throughout the chain.

6. The final touch (Browser)

To see the result "pretty", you need to add the domain to the */etc/hosts* file of your main system (not the virtual machine, but the one where you open the browser), or inside Debian:

```bash
echo "127.0.0.1 mpeshko.42.fr" | sudo tee -a /etc/hosts
```

Now open your browser and enter: https://mpeshko.42.fr. The browser will show a red warning (as required by the Evaluation Sheet) - click "Advanced" and "Proceed".


Error with WordPress script.

1. Your script is stuck because the mysqladmin ping command is trying to "knock" on the database door, but MariaDB is not letting it in without a password or due to incorrect access rights.

Why is mysqladmin not working?
Sometimes mysqladmin ping may require authorization if the database is already initialized. You need to pass in your credentials. Since this is an initialization script, it is best to use the root user.

```bash
until mysqladmin ping -h"mariadb_container" -u root -p"$MYSQL_ROOT_PASSWORD" --silent; do
```