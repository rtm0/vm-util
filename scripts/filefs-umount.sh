#!/bin/bash

set -e

MNT_POINT=$1

sudo umount "${MNT_POINT}"
