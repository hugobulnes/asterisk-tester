#!/bin/bash

set -e

/etc/init.d/mysql.server start

mysqladmin -u root password $DB_PASS

exec asterisk -c "$@"

exec $@