# The script is executed inside the container.

# this specifies the base image that the build will extend
FROM ubuntu:jammy

# MariaDB GutHub: add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql --home-dir /var/lib/mysql

# ENV <name> <value> - this instruction sets an environment 
# variable that a running container will use.

# RUN <command>
RUN	apt update && \
	apt install -y --no-install-recommends --no-install-suggests \
	mariadb-server && \
	# We clean the data folder so that our ENTRYPOINT can do a clean initialization
	rm -rf /var/lib/mysql/* && \
	# Clear the package cache
	rm -rf /var/lib/apt/lists/*

# Create a folder for the socket and grant rights to the mysql user
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# COPY <host-path> <image-path> bring our application code into the image
# from source on the host into destination (working directory)

# By default, MariaDB only listens to 127.0.0.1 (localhost). In Docker, 
# this means that no one from outside can connect to it. You need to change 
# the bind-address to 0.0.0.0.
# Configure MariaDB to listen on all interfaces
COPY ./conf/55-override.cnf /etc/mysql/mariadb.conf.d/
COPY ./tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Specify default executable.
ENTRYPOINT ["bash", "/usr/local/bin/docker-entrypoint.sh"]

# CMD ["<command>", "<arg1>"] - this instruction sets the default 
# command a container using this image will run.
# to make the container to run our application we specify command to start our script
# Launching the database daemon directly
CMD ["mariadbd", "--user=mysql"]
