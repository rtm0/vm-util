#!/bin/bash

FILE=$1
SIZE=$2

dd if=/dev/zero of="${FILE}" bs=${SIZE} count=1
sudo mkfs.ext4 "${FILE}"
