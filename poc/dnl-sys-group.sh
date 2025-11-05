#!/bin/bash
# Downloads Group data from target server
# bash ./dnl-sys-group.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header_and_conf "Downloading Groups"
require_active_session
reset_data_groups
# Loop pages
echo "Requesting data"
PAGE=0
while [ "${PAGE}" -lt "${BN_RQ_LIMIT}" ]; do
    printf "\r\t\tRequest: %d" "$((PAGE+1))" && do_delay
    # Request data
    DATA=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_url_group "${PAGE}")")
    G_ID=$(json_extract_value "${DATA}" 'id') # Group ID
    # Validate data, save or break
    if [ -n "${G_ID}" ] && [ "${G_ID}" != "unknown" ]; then
        echo "${DATA}" > "${DIR_OUT_SYS_GROUP}/group-${G_ID}.json"
    else
        printf "\n\t\t\t\t%s" "$([ "${PAGE}" -eq 0 ] && echo "No data" || echo "No more data")" && break
    fi
    PAGE=$((PAGE + 1)) # Increase page number
done
# end of pages loop
echo -e "\nDone"