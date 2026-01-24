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

# Follow logs in real-time
docker logs -f wordpress

# View logs with timestamps
docker logs -t mariadb
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

#### WordPress Operations
```bash
# Access WordPress container
docker exec -it wordpress bash

# Check WordPress files
docker exec -it wordpress ls -la /var/www/html

# WordPress CLI commands
docker exec -it wordpress wp db check --allow-root
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

# Test internal connectivity
docker exec nginx curl -I wordpress:9000
docker exec nginx curl -I -k https://localhost

# Test listening ports
docker exec nginx ss -tuln
```

### Network Management

#### Network Inspection
```bash
# List all networks
docker network ls

# Inspect the inception network
docker network inspect inception

# Check if containers are on the same network
docker network inspect inception | grep -A 10 "Containers"
```

#### Connectivity Testing
```bash
# Test external access (from host)
curl -k https://localhost
curl -v -k --resolve mpeshko.42.fr:443:127.0.0.1 https://mpeshko.42.fr

# Test internal connectivity
docker exec nginx curl -I wordpress:9000
docker exec wordpress ping mariadb
```

### Volume Management

#### List and Inspect Volumes
```bash
# List all volumes
docker volume ls

# Inspect specific volumes  
docker volume inspect inception_db_data
docker volume inspect inception_wp_data

# Check volume usage
docker system df -v
```

#### Volume Data Access
```bash
# Check volume mount points (from containers)
docker exec mariadb df -h /var/lib/mysql
docker exec wordpress df -h /var/www/html

# Direct access to volume data (from host)
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
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

| Service | Container Path | Host Path | Purpose |
|---------|---------------|-----------|---------|
| MariaDB | `/var/lib/mysql` | `~/data/mariadb` | Database files, logs |
| WordPress | `/var/www/html` | `~/data/wordpress` | WordPress files, uploads |
| Nginx | `/var/www/html` | `~/data/wordpress` | Shared with WordPress |

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

#### Backup Data
```bash
# Backup database
docker exec mariadb mysqldump -u root -p --all-databases > backup_$(date +%Y%m%d).sql

# Backup WordPress files
tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz ~/data/wordpress/
```

#### Check Data Integrity
```bash
# Check database health
docker exec -it wordpress wp db check --allow-root

# Verify file permissions
docker exec wordpress ls -la /var/www/html
docker exec mariadb ls -la /var/lib/mysql

# Check disk usage
du -sh ~/data/mariadb/
du -sh ~/data/wordpress/
```

#### Clean Data (Caution!)
```bash
# Remove all data (use fclean instead)
sudo rm -rf ~/data/mariadb/* ~/data/wordpress/*

# Or use the safer Makefile target
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

#### Volume Mount Verification
```bash
# Verify mounts are working
docker exec mariadb mount | grep mysql
docker exec wordpress mount | grep html

# Test persistence by creating test files
docker exec mariadb touch /var/lib/mysql/test_persistence
docker exec wordpress touch /var/www/html/test_persistence

# Restart containers and check files still exist
make down && make up
docker exec mariadb ls /var/lib/mysql/test_persistence
docker exec wordpress ls /var/www/html/test_persistence
```

### 🚨 Troubleshooting Common Issues

**If website is inaccessible:**
```bash
# Verify hosts file entry
grep mpeshko.42.fr /etc/hosts

# Should show: 127.0.0.1 mpeshko.42.fr
```

### ✅ Health Check Checklist

- [ ] All 3 containers running (`docker ps`)
- [ ] Website accessible at https://mpeshko.42.fr
- [ ] SSL certificate working (shows padlock, even if "not secure")
- [ ] WordPress admin panel accessible
- [ ] Both user accounts can log in
- [ ] Comments can be added
- [ ] Data persists after container restart
- [ ] Data persists after VM reboot
