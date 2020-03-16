#!/bin/bash

SCRIPTS_DIR=/scripts/*

for i in $SCRIPTS_DIR
do   
    if [ -f $i ]
    then
        cat $i | mysql -u root --password=$DB_PASS
    fi
done