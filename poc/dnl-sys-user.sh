#!/bin/bash
# Downloads User data from the target server
# bash ./dnl-sys-user.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header_and_conf "Downloading Users"
require_active_session
reset_data_users

echo "Requesting data"

# Loop through pages
PAGE=0
while [ "${PAGE}" -lt "${BN_RQ_LIMIT}" ]; do
    printf "\r\t\tRequest: %d" "$((PAGE+1))" && do_delay
    # Request data
    DATA=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_url_user "${PAGE}")")
    U_ID=$(json_extract_value "${DATA}" 'id') # User ID
    # Validate data, save or break
    if [ -n "${U_ID}" ] && [ "${U_ID}" != "unknown" ]; then
        echo "${DATA}" >"${DIR_OUT_SYS_USER}/user-${U_ID}.json"
    else
        printf "\n\t\t\t\t%s" "$([ "${PAGE}" -eq 0 ] && echo "No data" || echo "No more data")" && break
    fi
    PAGE=$((PAGE + 1)) # Increase page number
done
# End of pages loop
echo -e "\nDone"