# *Developer documentation*

## 🔐 Locate and Manage Credentials
Set up the environment from scratch.

### � Access to Credentials

**To obtain the `.env` file with credentials:**
- **Contact**: Maryna Peshko
- **Login**: `mpeshko`
- **Request**: `.env` file for Inception project access

### 📂 Credential Location

All credentials must be stored in the environment file:
**📁 File**: `srcs/.env`

### 🗃️ Database Credentials (MariaDB)

The `.env` file contains the following database configuration variables:
- `MYSQL_DATABASE` - Database name
- `MYSQL_USER` - Database user
- `MYSQL_PASSWORD` - Database user password
- `MYSQL_ROOT_PASSWORD` - Database root password

**Usage**: These credentials are used internally by WordPress to connect to the MariaDB database.

### 🌐 WordPress Credentials

#### Administrator Account
The `.env` file contains these admin variables:
- `WP_ADMIN_USER` - Administrator username
- `WP_ADMIN_PASSWORD` - Administrator password  

**Access**: https://mpeshko.42.fr/wp-admin
**Capabilities**: Full administrative access, can manage users, content, themes, plugins

### 🔒 SSL Certificate Information

SSL certificate configuration variables in `.env`:
- `SSL_CERT_FOLDER` - Certificate folder path
- `SSL_CERT` - Certificate file path
- `SSL_KEY` - Private key file path

### Ensure that a SSL/TLS certificate is used.

Verification via network connection (OpenSSL s_client).
You mimic the actions of a browser, but receive a full technical report.

```bash
openssl s_client -connect localhost:443

openssl s_client -connect localhost:443 -tls1_3

# old certificate
openssl s_client -connect localhost:443 -tls1_1
```

What to pay attention to in the output:

1. **Certificate chain**: `s:C=DE, ST=Berlin, L=Berlin, O=42, OU=student, CN=mpeshko.42.fr` 
This proves that Nginx sent the certificate you generated in Dockerfile.

2. **Protocol version**: Look for the line: `Protocol : TLSv1.3` This confirms that the connection is secured with version 1.3.

3. **Cipher Suite**: For example: `Cipher : TLS_AES_256_GCM_SHA384` This is the specific mathematical algorithm that your data is currently encrypted with.

## 🔨 Build and Launch the Project using the Makefile and Docker Compose

### Using Makefile (Recommended)

The Makefile provides convenient targets for managing the entire stack:

#### Build and Launch Commands
```bash
# Full setup: builds images, starts containers, adds hosts entry
make setup
# or simply
make

# Only start containers (no hosts modification)
make up

# Add domain to /etc/hosts separately
make hosts
```

#### Container Management
```bash
# Stop containers but keep images and data
make down

# Pause containers (can be resumed)
make stop

# Resume paused containers
make start

# Complete cleanup: removes containers, images, volumes, hosts entry
make fclean

# Rebuild everything from scratch
make re
```

### Using Docker Compose Directly

For manual control or debugging, you can use Docker Compose commands directly:

```bash
# Build and start (detached mode)
docker compose -f srcs/docker-compose.yml up -d --build

# View logs
docker compose -f srcs/docker-compose.yml logs

# Check status
docker compose -f srcs/docker-compose.yml ps

# Stop containers
docker compose -f srcs/docker-compose.yml stop

# Start stopped containers
docker compose -f srcs/docker-compose.yml start

# Remove containers (keeps images and volumes)
docker compose -f srcs/docker-compose.yml down

# Remove containers AND volumes
docker compose -f srcs/docker-compose.yml down -v

# Remove containers, volumes, AND images
docker compose -f srcs/docker-compose.yml down -v --rmi all
```

### Individual Image Building

For development and testing individual services:

```bash
# Build individual images
docker build -t mariadb ./srcs/requirements/mariadb
docker build -t wordpress ./srcs/requirements/wordpress  
docker build -t nginx ./srcs/requirements/nginx

# Verify images are created
docker images
```

## 🛠️ Container and Volume Management

Use relevant commands to manage the containers and volumes.

### Container Status and Monitoring

#### Check Container Status
```bash
# Show running containers
docker ps

# Show all containers (including stopped)
docker ps -a

# Check specific container status
docker inspect mariadb
docker inspect wordpress
docker inspect nginx
```

#### Container Logs
```bash
# View logs for specific containers
docker logs mariadb
docker logs wordpress
docker logs nginx
```

### Stop and remove (delete) container
```bash
docker container stop CONTAINER
docker container rm [OPTIONS] CONTAINER
# -v, --volumes		Remove anonymous volumes associated with the container
```

#### Process Management
```bash
# Check processes inside containers
docker exec mariadb ps aux
docker exec wordpress ps aux
docker exec nginx ps aux

# Verify MariaDB is PID 1 (best practice)
docker exec mariadb ps aux | grep mariadb
```

### Interactive Container Access

#### Database Operations
```bash
# Access MariaDB as user
docker exec -it mariadb mariadb -u mpeshko -p

# Access MariaDB as root
docker exec -it mariadb mariadb -u root -p

# Quick database check
docker exec -it mariadb mariadb -u root -p -e "SHOW DATABASES;"
```

### SQL commands
```SQL
SHOW DATABASES;
```

Switch to your database.
```SQL
USE your_database_name;
SHOW TABLES;
```

Let's log in as root (whose password we changed in the script) and look at the list of users.
```SQL
SELECT user, host, plugin FROM mysql.user;
```

#### WordPress Operations
```bash
# Check WordPress files
docker exec -it wordpress ls -la /var/www/html

# WordPress CLI commands
# Check if WordPress can see the tables in MariaDB.
docker exec -it wordpress wp db check --allow-root
# Check the list of tables
docker exec -it wordpress wp db tables --allow-root

# Create test user via CLI
docker exec -it wordpress wp user create test_user test@example.com --role=author --user_pass=password123 --allow-root

# Then check through MariaDB if it appeared there:
docker exec -it mariadb mariadb -u mpeshko -p -e "USE inception_db; SELECT user_login FROM wp_users;"
```

#### Nginx Operations
```bash
# Test Nginx configuration
docker exec nginx nginx -t

# Check web root contents
docker exec nginx ls -la /var/www/html
```

**Nginx → WordPress tests**
```bash
# Test internal connectivity
docker exec nginx curl -I wordpress:9000
```

What we expect: Since port 9000 is not HTTP, but FastCGI, curl may throw an error like Connection reset by peer (or Empty reply from server, Connection reset) .

Why this is a success: If you see any response other than Could not resolve host or Connection refused, then Nginx knows where WordPress is located and the port is open.

Test2
```bash
docker exec nginx curl -I -k https://localhost
```
Expected result: HTTP/1.1 200 OK

This will confirm that Nginx successfully "translated" your HTTP request into FastCGI, passed it to WordPress, received the response, and returned it to you.

# Test listening ports of Nginx

```bash
docker exec nginx ss -tuln
```

### Network Management

#### Network Inspection
```bash
# List all networks
docker network ls

# Inspect the inception network
docker network inspect inception
```

#### Connectivity Testing

Since we are using a self-signed certificate, we add the `-k`(ignore insecure) flag.

```bash
# Test external access (from host)
curl -k https://localhost
curl -v -k --resolve mpeshko.42.fr:443:127.0.0.1 https://mpeshko.42.fr
```

### Volume Management

#### List and Inspect Volumes
```bash
# List all volumes
docker volume ls

# Inspect specific volumes  
docker volume inspect inception_db_data
docker volume inspect inception_wp_data
```

#### Remove a volume
```bash
docker volume rm NAME_VOLUME
```

## 💾 Data Storage and Persistence

Identify where the project data is stored and how it persists.

### Data Location

The project uses **bind mounts** to ensure data persistence:

```yaml
# From docker-compose.yml
volumes:
  db_data:
    driver: local
    driver_opts:
      device: ${HOME}/data/mariadb    # Host directory
      o: bind
      type: none
  wp_data:
    driver: local  
    driver_opts:
      device: ${HOME}/data/wordpress  # Host directory
      o: bind
      type: none
```

### Physical Storage Paths

| Service   | Container Path   | Host Path           | Purpose                  |
|-----------|------------------|---------------------|--------------------------|
| MariaDB   | `/var/lib/mysql` | `~/data/mariadb`    | Database files, logs     |
| WordPress | `/var/www/html`  | `~/data/wordpress`  | WordPress files, uploads |
| Nginx     | `/var/www/html`  | `~/data/wordpress`  | Shared with WordPress    |

### Data Persistence Behavior

#### What Persists
- **Database data**: MySQL tables, indexes, logs
- **WordPress files**: Core files, themes, plugins, uploads
- **SSL certificates**: Generated during build
- **Configuration files**: Custom configs in containers

#### What Gets Recreated
- **Containers**: Removed with `docker compose down`
- **Networks**: Recreated on each `up`
- **Temporary files**: Container-specific temp files

### Data Management Commands

#### Check Data Integrity
```bash
# Verify file permissions
docker exec wordpress ls -la /var/www/html
docker exec mariadb ls -la /var/lib/mysql

# Check disk usage
du -sh ~/data/mariadb/
```

#### Clean Data (Caution!)
```bash
# use the safer Makefile target
make fclean  # Handles permissions correctly
```

### Troubleshooting Data Issues

#### Permission Problems
```bash
# Check current ownership
ls -la ~/data/

# Expected owners:
# mariadb: dnsmasq (or mysql user)  
# wordpress: www-data

# Fix permissions if needed (rarely required)
sudo chown -R $(id -u):$(id -g) ~/data/mariadb
sudo chown -R www-data:www-data ~/data/wordpress
```

### 🚨 Troubleshooting Common Issues

**If website is inaccessible:**
```bash
# Verify hosts file entry
grep mpeshko.42.fr /etc/hosts

# Should show: 127.0.0.1 mpeshko.42.fr
```
