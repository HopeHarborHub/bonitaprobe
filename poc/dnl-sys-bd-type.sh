#!/bin/bash
# Downloads Cases data and extracts Business Data from it.
# bash ./dnl-sys-bd-type.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header_and_conf "Downloading Cases and extracting Business Data types"
require_active_session
require_non_empty_case_output_file
# Loop trough cases
CNT=0
while IFS= read -r CASE_ID; do
    # Skip empty lines or lines with only whitespace
    [[ -z "${CASE_ID// }" ]] && continue
    # Request data
    printf "\r\t%s" "Requesting: ${CNT} (#${CASE_ID})" && do_delay
    DATA=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_bdr_url "${CASE_ID}")")
    # Parse and store data
    TYPES_ARRAY=( $(echo "${DATA}" | jq -r '.[].type | select(. != null and . != "")') )
    store_bd_type_array "${TYPES_ARRAY[@]}"
    ((CNT++))
    if ((CNT >= BN_RQ_LIMIT)); then
        break
    fi
done < "${FILE_OUT_SYS_CASE_ID}"
echo -e "\nDone"