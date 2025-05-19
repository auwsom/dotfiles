#!/bin/bash
fdisk /dev/vda <<EEOF
d
1
n
1


w
EEOF
exit 0
resize2fs /dev/vda1
