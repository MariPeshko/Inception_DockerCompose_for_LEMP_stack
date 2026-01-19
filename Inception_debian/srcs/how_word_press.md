Even for testing a single service, it's better to create a network. It's not difficult, but it eliminates 90% of communication problems.

```bash
docker network create test_network
```

Run MariaDB on this network:

```bash
docker run -d --name mariadb_container --network test_network --env-file .env my_mariadb
```

Build and run WordPress on the same network.
-it instead of -d so you can see the script logging in real time.

```bash
docker build -t my_wordpress ./requirements/wordpress

docker run -d --name wordpress_container --network test_network --env-file .env my_wordpress
```

#### How to run a container with a "bind" to a folder:

```bash
docker run -d --name wordpress_container --network test_network \
  --env-file .env \
  -v /home/mpeshko/data/wordpress:/var/www/html \
  my_wordpress
```

Go inside to check. Let's check if your WordPress files are in place:
```bash
docker exec -it wordpress_container ls -la /var/www/html
```

**We can check the "health" of the system through the console.**

1. Interaction check (Database connection).
We will check if WordPress can see the tables in MariaDB.

```bash
docker exec -it wordpress_container wp db check --allow-root
```
Expected result: message *Success: Database checked.*

2. Checking the list of tables

```bash
docker exec -it wordpress_container wp db tables --allow-root
```

3. Checking PHP-FPM (Port 9000)
We need to make sure that PHP-FPM is actually listening on port 9000 and ready to accept requests from Nginx. To do this, we will look at the "open ports" inside the container:

```bash
docker exec -it wordpress_container ss -tuln
```
Expected result: the line where it says 0.0.0.0:9000 or *:9000.

My error: OCI runtime exec failed: exec failed: unable to start container process: exec: "ss": executable file not found in $PATH

Solution:
```bash
docker exec -it wordpress_container grep "listen =" /etc/php/8.2/fpm/pool.d/www.conf
```

Another solution:
If you really need to perform this check via ss, you can temporarily install the tools directly into the running container:
```bash
docker exec -it wordpress_container apt update
docker exec -it wordpress_container apt install -y iproute2
docker exec -it wordpress_container ss -tuln
```

4. Experiment: Creating a user via the terminal

```bash
docker exec -it wordpress_container wp user create test_user test@example.com --role=author --user_pass=password123 --allow-root
```

And then check through MariaDB if it appeared there:

```bash
docker exec -it mariadb_container mariadb -u mpeshko -p -e "USE inception_db; SELECT user_login FROM wp_users;"
```

Remove the old container: 
```bash
docker rm wordpress_container
```
