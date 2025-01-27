#!/bin/bash

SRC=/home/user/tmp/demo/storage1
DST=/home/user/tmp/demo/storage2
PARTITION=2024_09

rm -Rf $DST/*

mkdir -p \
  $DST/data/big \
  $DST/data/indexdb \
  $DST/data/small

cp -R \
  $SRC/data/big/$PARTITION \
  $DST/data/big/$PARTITION
cp -R \
  $SRC/data/indexdb/$PARTITION \
  $DST/data/indexdb/$PARTITION
cp -R \
  $SRC/data/small/$PARTITION \
  $DST/data/small/$PARTITION

ls -l $DST/data/big/ $DST/data/indexdb/ $DST/data/small/
