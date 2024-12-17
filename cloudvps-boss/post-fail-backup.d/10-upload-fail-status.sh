#!/bin/bash
# Restic wrapper to back up to OpenStack Object Store
# Credits to Cream Commerce B.V. for their work on the restic implementation.
#
# Copyright (C):          CloudVPS B.V.
# Copyright (C):          Cream Commerce B.V., https://www.cream.nl/
# Based on the work of:   Remy van Elst, https://raymii.org/, CloudVPS B.V. & Cream Commerce B.V.

VERSION="3.0.0"
TITLE="CloudVPS Boss Fail Status Upload ${VERSION}"

if [[ ! -f "/etc/cloudvps-boss-v3/common.sh" ]]; then
    lerror "Cannot find /etc/cloudvps-boss-v3/common.sh"
    exit 1
fi
source /etc/cloudvps-boss-v3/common.sh

touch "/etc/cloudvps-boss-v3/status/${HOSTNAME}/failed"
if [[ $? -ne 0 ]]; then
    lerror "Cannot update status"
    exit 1
fi

OLD_IFS="${IFS}"
IFS=$'\n'
SWIFTTOUCH=$(swift upload ${CONTAINER_NAME} "/etc/cloudvps-boss-v3/status/${HOSTNAME}/failed" --object-name "status/${HOSTNAME}/failed" 2>&1 | grep -v -e Warning -e pkg_resources -e oslo)
if [[ $? -ne 0 ]]; then
    lerror "Could not upload failed status"
    for line in ${SWIFTTOUCH}; do
        lerror ${line}
    done
fi
IFS="${OLD_IFS}"

lecho "${TITLE} ended on ${HOSTNAME} at $(date)."
