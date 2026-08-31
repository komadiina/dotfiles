#!/bin/bash

echo "running proxy with deny-all policy on port 3128..."

while true; do 
  {
    echo -e "HTTP/1.1 403 Forbidden\r"
    echo -e "Content-Length: 0\r"
    echo -e "\r"
  } | nc -l -p 3128 -k
done
