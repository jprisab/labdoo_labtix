#!/bin/bash
#This script comes without  warranty.


readonly DISK_PASSWORD="43524532"
ata_disk="$1"

ata_erase_support() {
    local disk="$1"
    local -a hdparm_identify_result
    local identify_index
    # If SECURITY ERASE UNIT is supported, hdparm -I (identify) output should
    # match "Security:" with "supported" on either the first or second
    readarray -t hdparm_identify_result < <( hdparm -I "${disk}" 2>/dev/null )
    # Could probably have done this with grep -c instead. Oh, well.
    for identify_index in "${!hdparm_identify_result[@]}"; do
        if [[ "${hdparm_identify_result[$identify_index]}" =~ ^Security: ]]; then
            if [[ "${hdparm_identify_result[$identify_index+1]//$'\t'/}" =~ ^supported \
                || "${hdparm_identify_result[$identify_index+2]//$'\t'/}" =~ ^supported ]]; then
                true
            else
                false
            fi
        break
        else
            false
        fi
    done
}

is_unfrozen() {
    local frozen_state
    frozen_state=$(hdparm -I "${ata_disk}" 2>/dev/null | awk '/frozen/ { print $1,$2 }')
    if [ "${frozen_state}" == "not frozen" ]; then
        true
    else
        false
    fi
}

set_password () {
    local ata_disk="$1"
    hdparm --user-master u --security-set-pass "${DISK_PASSWORD}" "${ata_disk}" >/dev/null
}

is_password_set () {
    local password_state
    password_state=$(hdparm -I "$1" 2>/dev/null | awk '/Security:/{n=NR+3} NR==n { print $1,$2 }')
    if [[ ${password_state} == "enabled" ]]; then
        true
    else
        false
    fi
}

estimate_erase_time () {
    local ata_disk="$1"
    hdparm -I "${ata_disk}" | awk '/for SECURITY ERASE UNIT/'
}

erase_disk() {
    local ata_disk="$1"
    time hdparm --user-master u --security-erase "${DISK_PASSWORD}" "$ata_disk"
}







if ! ata_erase_support "${ata_disk}"; then
echo  "Error: ATA SECURITY ERASE UNIT unsupported on ${ata_disk}"
exit 1
fi

# Check for frozen state
if ! is_unfrozen "${ata_disk}"; then
echo "Error: Disk ${ata_disk} security state is frozen, check https://ata.wiki.kernel.org/index.php/ATA_Secure_Erase for options..."

exit 99
fi

set_password "${ata_disk}"

if is_password_set "${ata_disk}"; then
echo  "Error checkin user password on ${ata_disk}..."
exit 1
else
echo "User password set, attempting secure erase for ${ata_disk}"
estimate_erase_time "${ata_disk}"
erase_disk "${ata_disk}"

# Sucessful erase should reset "enabled" value to "not"
if ! is_password_set "${ata_disk}"; then
echo "Secure erase was successful for ${ata_disk}"
exit 0
else
echo  "Error performing secure erase on ${ata_disk}..."

exit 1
fi
fi
