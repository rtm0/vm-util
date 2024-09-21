#!/bin/bash

set -e

FILE=$1
MNT_POINT=$2

mkdir -p "${MNT_POINT}"
sudo mount -o loop "${FILE}" "${MNT_POINT}"
sudo find "${MNT_POINT}" -type f -exec chmod -R 666 {} \;
sudo find "${MNT_POINT}" -type d -exec chmod -R 777 {} \;
