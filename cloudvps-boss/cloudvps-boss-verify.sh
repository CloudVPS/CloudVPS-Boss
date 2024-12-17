#!/bin/bash
# Restic wrapper to back up to OpenStack Object Store
# Credits to Cream Commerce B.V. for their work on the restic implementation.
#
# Copyright (C):          CloudVPS B.V.
# Copyright (C):          Cream Commerce B.V., https://www.cream.nl/
# Based on the work of:   Remy van Elst, https://raymii.org/, CloudVPS B.V. & Cream Commerce B.V.

VERSION="3.0.0"
TITLE="CloudVPS Boss Backup Verify ${VERSION}"

if [[ ! -f "/etc/cloudvps-boss-v3/common.sh" ]]; then
    lerror "Cannot find /etc/cloudvps-boss-v3/common.sh"
    exit 1
fi
source /etc/cloudvps-boss-v3/common.sh

lecho "${TITLE} started on ${HOSTNAME} at $(date)."

lecho "restic check --repo ${BACKUP_BACKEND} --password-file=/etc/cloudvps-boss-v3/restic-password.conf --cleanup-cache --verbose=1"

OLD_IFS="${IFS}"
IFS=$'\n'
RESTIC_OUTPUT=$(restic check \
    --repo ${BACKUP_BACKEND} \
    --password-file=/etc/cloudvps-boss-v3/restic-password.conf \
    --cleanup-cache \
    --verbose=1 2>&1 | grep -v -e Warning -e pkg_resources -e oslo -e tar -e attr -e kwargs)

if [[ $? -ne 0 ]]; then
    for line in ${RESTIC_OUTPUT}; do
            lerror ${line}
    done
    lerror "CloudVPS Boss Verify FAILED!. Please check server ${HOSTNAME}."
fi

for line in ${RESTIC_OUTPUT}; do
        lecho "${line}"
done
IFS="${OLD_IFS}"

echo
lecho "CloudVPS Boss Verify ${VERSION} ended on $(date)."
