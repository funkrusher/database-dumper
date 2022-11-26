#!/bin/bash

echo "SOURCE:"
echo $SOURCE
echo "--"
echo "TARGET:"
echo $TARGET
echo "--"
echo "ENTITY:"
echo $ENTITY



FILENAME_APPENDIX=$(date +%F)
export FILENAME_APPENDIX

if [ -n "$SOURCE" ]; then
  /dumper/scripts/source.sh
fi
if [ -n "$TARGET" ]; then
  /dumper/scripts/target.sh
fi