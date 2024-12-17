#!/bin/bash
# Restic wrapper to back up to OpenStack Object Store
# Credits to Cream Commerce B.V. for their work on the restic implementation.
#
# Copyright (C):          CloudVPS B.V.
# Copyright (C):          Cream Commerce B.V., https://www.cream.nl/
# Based on the work of:   Remy van Elst, https://raymii.org/, CloudVPS B.V. & Cream Commerce B.V.

VERSION="3.0.0"
TITLE="CloudVPS Boss Stats ${VERSION}"

if [[ ! -f "/etc/cloudvps-boss-v3/common.sh" ]]; then
    lerror "Cannot find /etc/cloudvps-boss-v3/common.sh"
    exit 1
fi
source /etc/cloudvps-boss-v3/common.sh

USED="$(swift stat --lh ${HOSTNAME} 2>&1 | awk '/Bytes/ { print $2}' | grep -v -e Warning -e pkg_resources -e oslo)"

echo "========================================="
lecho "Start of CloudVPS Boss Status ${VERSION}"
lecho "Hostname: ${HOSTNAME}"
lecho "External IP: $(curl -s http://ip.cloudvps.nl)"
lecho "Username: ${SWIFT_USERNAME}"
lecho "Storage used: ${USED}"
lecho "Full backups to keep: ${FULL_TO_KEEP}"
lecho "Create full backup if last full backup is older than: ${FULL_IF_OLDER_THAN}"
echo "-----------------------------------------"
lecho "Restic snapshots:"
OLD_IFS="${IFS}"
IFS=$'\n'
RESTIC_OUTPUT=$(restic snapshots \
    --repo ${BACKUP_BACKEND} \
    --password-file=/etc/cloudvps-boss-v3/restic-password.conf \
    --cleanup-cache \
    --verbose=1 2>&1 | grep -v -e Warning -e pkg_resources -e oslo -e tar -e attr -e kwargs)
for line in ${RESTIC_OUTPUT}; do
        lecho "${line}"
done
IFS="${OLD_IFS}"
lecho "End of CloudVPS Boss Status"
echo "========================================="

