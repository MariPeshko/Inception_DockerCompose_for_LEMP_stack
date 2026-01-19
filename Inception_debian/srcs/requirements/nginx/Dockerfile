# If you want to use variables directly in a Dockerfile you need to use 
# the ARG statement.
# Key generation (req -x509)
FROM debian:bookworm-slim

RUN apt update && apt install -y --no-install-recommends --no-install-suggests \
		nginx \
		openssl \
		curl && \
		rm -rf /var/lib/apt/lists/*

# 1 warning found (use docker --debug to expand):
# - SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions for sensitive data (ARG "SSL_KEY") (line 12)

ARG SSL_CERT_FOLDER=/etc/nginx/ssl/
ARG SSL_KEY=/etc/nginx/ssl/inception.key
ARG SSL_CERT=/etc/nginx/ssl/inception.crt
ARG DOMAIN_NAME=mpeshko.42.fr

# ARG SSL_CERT_FOLDER SSL_KEY SSL_CERT DOMAIN_NAME

# Creating a folder for SSL certificates
RUN mkdir -p "${SSL_CERT_FOLDER}"

# Generate a self-signed certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout "${SSL_KEY}" \
    -out "${SSL_CERT}" \
	-subj "/C=DE/ST=Berlin/L=Berlin/O=42/OU=student/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

RUN	mkdir -p /var/www/html
RUN	chown -R www-data:www-data /var/www/html

# Redirect Nginx standard logs to STDOUT and STDERR for Docker
# to see logs with docker logs
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# start the nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]