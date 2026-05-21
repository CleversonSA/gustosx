#! /bin/bash

counter=1
while [ 1 == 1 ]; 
do
  echo "Request #${counter}"
  ../openmsx-getstring.py --dir /tmp/openmsx-$(whoami)
  #./openmsx-conn.py --dir /tmp/openmsx-$(whoami) --timeout 10
  counter=$((counter + 1))
  #sleep 1
done
