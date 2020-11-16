#!/bin/bash
INPUT=$1
OLDIFS=$IFS
IFS=','

[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

echo "password,username,group"

while read username group
do
    pw=$(pwgen -Bcny -r ",\"'|<>:;+=*" 12 1)
    echo "$pw",$username,$group
    # ship that first line
done < $INPUT | awk 'NR>1'
IFS=$OLDIFS
