#!/bin/bash
# Downloads Human Task data from the target server
# bash ./dnl-sys-task-human.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header_and_conf "Downloading Human Tasks"
require_active_session
reset_data_users
# Loop pages
echo "Requesting data"
PAGE=0
while [ "${PAGE}" -lt "${BN_RQ_LIMIT}" ]; do
    printf "\r\t\tRequest: %d" "$((PAGE+1))" && do_delay
    # Request data
    DATA=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_url_human_task "${PAGE}")")
    T_ID=$(json_extract_value "${DATA}" 'id') # Task ID
    C_ID=$(json_extract_value "${DATA}" 'caseId') # Case ID
    # Validate data, save or break
    if [ -n "${T_ID}" ] && [ "${T_ID}" != "unknown" ]; then
        store_human_task "${T_ID}" "${DATA}"
        store_case_id "${C_ID}"
    else
        printf "\n\t\t\t\t%s" "$([ "${PAGE}" -eq 0 ] && echo "No data" || echo "No more data")" && break
    fi
    ((PAGE++)) # Increase page number
done
# end of pages loop

echo -e "\nDone"