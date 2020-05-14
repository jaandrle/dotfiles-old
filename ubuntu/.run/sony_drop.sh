#!/bin/bash
hostitel=$(pkexec arp-scan --localnet --quiet --ignoredups | awk '/d4:38:9c:8c:50:b7/ {print $1}')
nautilus "ftp://sony_drop@$hostitel:12345/"
