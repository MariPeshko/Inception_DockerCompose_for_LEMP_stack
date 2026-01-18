#!/bin/bash
# this is a initialization script (bootstrap)

set -e

# Check if the database has already been initialized (if the mysql folder exists)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    
    # Забезпечуємо правильні права доступу перед початком
    chown -R mysql:mysql /var/lib/mysql

    # Setting up system tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Temporarily start the server for configuration
    tfile=`mktemp`
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    # The % symbol means that the user can connect from any IP address (for example, from a WordPress container).
    cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    echo "Executing bootstrap SQL..."
    # This method does not require running a full server for initial setup.
    # We use --datadir to know exactly where the data is written.
    /usr/sbin/mariadbd --user=mysql --bootstrap --datadir=/var/lib/mysql < $tfile
    if [ $? -ne 0 ]; then
        echo "Bootstrap failed!"
        exit 1
    fi
    rm -f $tfile
    echo "Database initialized successfully."

    else
    echo "DEBUG: Directory /var/lib/mysql/mysql already exists. Skipping initialization."

fi

# Фінальна перевірка прав перед запуском
chown -R mysql:mysql /var/lib/mysql

echo "Starting MariaDB..."
# Передаємо керування основній команді (mariadbd з Dockerfile)
exec "$@"

# Why do we use exec “$@” at the end?
# This is the “golden rule” of writing Entrypoint scripts.

# $@ is what you wrote in CMD in Dockerfile (i.e., mariadbd --user=mysql).
# exec replaces the script process (bash) with the database process. This 
# makes MariaDB process #1 (PID 1), allowing it to correctly receive stop 
# signals (such as the SIGTERM we mentioned earlier).

# Що таке exec "$@"?
# Уявіть, що контейнер — це кімната, де може бути лише один "Головний" 
# (процес з PID 1).
# Без exec: Коли контейнер запускається, першим головним процесом стає 
# ваш Bash-скрипт (docker-entrypoint.sh). Коли він доходить до останнього 
# рядка і запускає MariaDB, він запускає її як "дитину". Bash залишається 
# PID 1, а MariaDB стає PID 2.
# З exec: Команда exec каже системі: "Видали мене (Bash) з пам'яті і 
# постав на моє місце (PID 1) команду, яка йде далі".