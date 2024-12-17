#!/bin/bash
# Restic wrapper to back up to OpenStack Object Store
# Credits to Cream Commerce B.V. for their work on the restic implementation.
#
# Copyright (C):          CloudVPS B.V.
# Copyright (C):          Cream Commerce B.V., https://www.cream.nl/
# Based on the work of:   Remy van Elst, https://raymii.org/, CloudVPS B.V. & Cream Commerce B.V.

VERSION="3.0.0"
TITLE="CloudVPS Boss File Overview ${VERSION}"

if [[ ! -f "/etc/cloudvps-boss-v3/common.sh" ]]; then
    lerror "Cannot find /etc/cloudvps-boss-v3/common.sh"
    exit 1
fi
source /etc/cloudvps-boss-v3/common.sh

if [[ -n "$1" ]]; then
    TIME="$1"
    TIMEOPT="--time $1"
    TIME_MESS="Requested Time: $1"
fi

echo "========================================="
lecho "Start of CloudVPS Boss File Overview"
lecho "Hostname: ${HOSTNAME}"
lecho "$TIME_MESS"
echo "-----------------------------------------"
echo ""
restic snapshots --repo ${BACKUP_BACKEND} --password-file=/etc/cloudvps-boss-v3/restic-password.conf --verbose=1
echo ""
lecho "End of CloudVPS Boss File Overview"
echo "========================================="

