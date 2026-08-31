#!/bin/bash

echo "running socat proxy LISTEN on port 3128"
while true; do
  socat TCP-LISTEN:3128,reuseaddr,fork SYSTEM:'echo -e "HTTP/1.1 403 Forbidden"'
done
