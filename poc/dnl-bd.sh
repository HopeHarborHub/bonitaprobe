#!/bin/bash
# Downloads Business Data from the target server
# bash ./dnl-bd.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header_and_conf "Downloading Business Data"
require_active_session
require_bd_output_file

bdm_count() {
    local BDM_OBJ_NM API_URL RS_OUT R_RANGE R_COUNT
    BDM_OBJ_NM=$1
    API_URL="$(make_bd_count_url "${BDM_OBJ_NM}")"
    RS_OUT=$(curl -s -i "${API_URL}" -H "Cookie: ${BN_SESS_COOKIE};" 2>/dev/null)
    R_RANGE=$(echo "${RS_OUT}" | grep -i '^Content-Range:' | head -1)
    [[ -z "${R_RANGE}" ]] && echo -e 0 && return
    R_COUNT="${R_RANGE##*/}"
    R_COUNT="${R_COUNT%%[!0-9]*}"
    [[ "$R_COUNT" =~ ^[0-9]+$ ]] || R_COUNT=0
    [[ "$R_COUNT" =~ ^[0-9]+$ ]] && [[ "$R_COUNT" -gt 0 ]] && echo "${R_COUNT}" || echo 0
}

# Read Business Objects
BD_OBJECTS_ARR=()
while IFS= read -r LINE; do
    [[ -z "${LINE// }" ]] && continue
    BD_OBJECTS_ARR+=("$LINE")
done <"${FILE_OUT_BD_OBJ}"
require_data_in_array "${BD_OBJECTS_ARR[@]}"
reset_data_bd

# Loop trough list of Business Object types
for BD_OBJ in "${BD_OBJECTS_ARR[@]}"; do
    PAGE=0 && BD_NAME=${BD_OBJ##*.}
    DIR_STORE="${DIR_OUT_BD}/${BD_NAME}" && mkdir -p "${DIR_STORE}"
    echo -e "\n\n\t${BD_NAME}"
    canDownload=$(bdm_count "${BD_OBJ}")
    echo -e "\t\t${canDownload} records available for download."
    if [ "${canDownload}" != "0" ]; then
        # Loop pages
        while [ "${PAGE}" -lt "${BN_RQ_LIMIT}" ]; do
            printf "\r\t\tDownloading: %d" "$((PAGE + 1))" && do_delay
            # Request data
            DATA=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_bd_url "${BD_OBJ}" "${PAGE}")")
            P_ID=$(json_extract_value "${DATA}" 'persistenceId') # Persistence ID
            if [ -n "${P_ID}" ] && [ "${P_ID}" != "unknown" ]; then # Validate data, save or break
                echo "${DATA}" >"${DIR_STORE}/${BD_NAME}-${P_ID}.json"
            else
                printf "\n\t\t\t\t%s" "$([ "${PAGE}" -eq 0 ] && echo "No data" || echo "No more data")" && break
            fi
            PAGE=$((PAGE + 1)) # Increase page number
        done
        # end of pages loop
    fi
done
# end of objects loop

echo -e "\nDone"