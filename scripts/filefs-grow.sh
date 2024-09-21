#!/bin/bash

set -e

FILE=$1
SIZE=$2

dd if=/dev/zero of="${FILE}" bs=${SIZE} conv=notrunc oflag=append count=1
sudo e2fsck -yf "${FILE}"
sudo resize2fs -f "${FILE}"
# losetup -c /dev/loop0
# resize2fs /dev/loop0
