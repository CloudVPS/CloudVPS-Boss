#!/bin/bash
# Restic wrapper to back up to OpenStack Object Store
# Credits to Cream Commerce B.V. for their work on the restic implementation.
#
# Copyright (C):          CloudVPS B.V.
# Copyright (C):          Cream Commerce B.V., https://www.cream.nl/
# Based on the work of:   Remy van Elst, https://raymii.org/, CloudVPS B.V. & Cream Commerce B.V.

VERSION="2.0.0"
TITLE="CloudVPS Boss Backup Cleanup ${VERSION}"

if [[ ! -f "/etc/cloudvps-boss/common.sh" ]]; then
    lerror "Cannot find /etc/cloudvps-boss/common.sh"
    exit 1
fi
source /etc/cloudvps-boss/common.sh

lecho "${TITLE} started on ${HOSTNAME} at $(date)."

lecho "restic unlock --remove-all --repo ${BACKUP_BACKEND} --password-file=/etc/cloudvps-boss/restic-password.conf --cleanup-cache --verbose=1"

OLD_IFS="${IFS}"
IFS=$'\n'
RESTIC_OUTPUT=$(restic unlock \
    --remove-all \
    --repo ${BACKUP_BACKEND} \
    --password-file=/etc/cloudvps-boss/restic-password.conf \
    --cleanup-cache \
    --verbose=1 2>&1 | grep -v -e Warning -e pkg_resources -e oslo -e tar -e attr -e kwargs)

if [[ $? -ne 0 ]]; then
    for line in ${RESTIC_OUTPUT}; do
            lerror ${line}
    done
    lerror "CloudVPS Boss Cleanup FAILED!. Please check server ${HOSTNAME}."
fi

for line in ${RESTIC_OUTPUT}; do
        lecho "${line}"
done
IFS="${OLD_IFS}"

lecho "restic prune --repo ${BACKUP_BACKEND} --password-file=/etc/cloudvps-boss/restic-password.conf --cleanup-cache --verbose=1"

OLD_IFS="${IFS}"
IFS=$'\n'
RESTIC_OUTPUT=$(restic prune \
    --repo ${BACKUP_BACKEND} \
    --password-file=/etc/cloudvps-boss/restic-password.conf \
    --cleanup-cache \
    --verbose=1 2>&1 | grep -v -e Warning -e pkg_resources -e oslo -e tar -e attr -e kwargs)

if [[ $? -ne 0 ]]; then
    for line in ${RESTIC_OUTPUT}; do
            lerror ${line}
    done
    lerror "CloudVPS Boss Cleanup FAILED!. Please check server ${HOSTNAME}."
fi

for line in ${RESTIC_OUTPUT}; do
        lecho "${line}"
done
IFS="${OLD_IFS}"

echo
lecho "CloudVPS Boss Cleanup ${VERSION} ended on $(date)."
