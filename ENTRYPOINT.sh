#!/bin/bash
# set -e
lsblk

echo ''
echo 'working dir'
pwd

echo 'Volumes'
echo 'df -h'
df -h

ls -al /data
ls -al /scratch 