#!/bin/bash

# load our environment-variables from the config-folder for the given config.
set -a
source <(cat /dumper/config/environments/$SOURCE/$ENTITY.env | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g"  -e 's/\r//g')
set +a

FILE=/dumper/config/sanitizers/$ENTITY.yml

if test -f "$FILE"; then
  echo "dumping_sanitize $BASE..."
  database-sanitizer -c /dumper/config/sanitizers/$ENTITY.yml mysql://$USER:$PASS@$HOST/$BASE > "/dumper/dumps/${FILENAME_APPENDIX}_$ENTITY.sql"
  echo "dumping_sanitize $BASE finished!"
else
  # see: https://bitsandpieces.it/posts/gentle-backups-with-mysql/
  # see: https://stackoverflow.com/questions/5666784/how-can-i-slow-down-a-mysql-dump-as-to-not-affect-current-load-on-the-server
  echo "dumping $BASE..."
  mysqldump --max_allowed_packet=1G --single-transaction --quick --lock-tables=false --ignore-table=xyz.MyStrangeTable --port=$PORT -h $HOST -u $USER -p''"$PASS"'' $BASE > "/dumper/dumps/${FILENAME_APPENDIX}_$ENTITY.sql"
  echo "dumping $BASE finished!"
fi