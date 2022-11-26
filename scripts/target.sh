#!/bin/bash

# load our environment-variables from the config-folder for the given config.
set -a
source <(cat /dumper/config/environments/$TARGET/$ENTITY.env | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g"  -e 's/\r//g')
set +a

echo "importing $BASE..."

mysql --force -h $HOST --port $PORT -u $USER -p"$PASS" 2>&1 > "/dumper/dumps/${FILENAME_APPENDIX}_$ENTITY.log" <<MYSQL_SCRIPT
DROP DATABASE IF EXISTS $BASE;
CREATE DATABASE $BASE;
use $BASE;
SET autocommit=0;

source /dumper/dumps/${FILENAME_APPENDIX}_$ENTITY.sql

COMMIT;
MYSQL_SCRIPT

echo "importing $BASE finished!"
