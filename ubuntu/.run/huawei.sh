#!/bin/bash
hostitel=$(pkexec arp-scan --localnet --quiet --ignoredups | awk '/d4:61:2e:9b:17:bf/ {print $1}')
nautilus "ftp://huawei_drop@$hostitel:12345/storage"
