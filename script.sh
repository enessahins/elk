#!/bin/bash

install_packages() {
    echo "Installing required packages..."
    yum -y update
    yum -y install epel-release
    yum -y install nginx java-11-openjdk-devel tcpdump net-tools curl htop msmtp gnupg
}

install_elk() {
    echo "Downloading ELK packages..."
    wget https://artifacts.elastic.co/downloads/logstash/logstash-7.10.0-x86_64.rpm
    wget https://artifacts.elastic.co/downloads/kibana/kibana-7.10.0-x86_64.rpm
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-x86_64.rpm

    echo "Installing ELK packages..."
    rpm -ivh logstash-7.10.0-x86_64.rpm
    rpm -ivh kibana-7.10.0-x86_64.rpm
    rpm -ivh elasticsearch-7.10.0-x86_64.rpm
}

configure_nginx() {
    echo "Configuring Nginx..."
    cat << EOF > /etc/nginx/conf.d/kibana.conf
server {
  listen 81;
  server_name localhost;
  error_log /var/log/nginx/kibana.error.log;
  access_log /var/log/nginx/kibana.access.log;
  location / {
    rewrite ^/(.*) /$1 break;
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;
    proxy_ignore_client_abort on;
    proxy_pass http://localhost:5601;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
  }
}
EOF

    systemctl restart nginx
}

install_packages
install_elk
configure_nginx
