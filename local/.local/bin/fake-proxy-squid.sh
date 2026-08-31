#!/bin/bash

proxy_ctr_name="squid-proxy"

docker run -d --name "$proxy_ctr_name" -p "3128:3128" ubuntu/squid

docker exec "$proxy_ctr_name" sh -c "echo 'http_access deny all' >> /etc/squid/squid.conf"

