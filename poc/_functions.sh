#!/bin/bash
set -e

load_conf_from_env(){
    if [[ -n "${BONITA_REQUESTS_DELAY}" ]]; then export BN_RQ_DElAY_TIME="${BONITA_REQUESTS_DELAY}"; fi
    if [[ -n "${BONITA_REQUESTS_LIMIT}" ]]; then export BN_RQ_LIMIT="${BONITA_REQUESTS_LIMIT}"; fi
    if [[ -n "${BONITA_SESSION_ID}" ]]; then export BN_SESS_COOKIE="JSESSIONID=${BONITA_SESSION_ID}"; fi
    if [[ -n "${BONITA_URL}" ]]; then export BN_SERVER_URL="${BONITA_URL}"; fi
}

print_dash_line(){
    echo '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - '
}

print_header() {
    print_dash_line
    echo "$1"
    print_dash_line
}

print_header_and_conf() {
    print_header "$1"
    print_configuration
    print_dash_line
}

get_bonita_version() {
    local version
    version=$(curl -s "${BN_SERVER_URL}/VERSION" | head -n1)
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$version"
    else
        echo "unknown"
    fi
}

get_domain() {
    sed -E 's#^https?://([^/:]+).*$#\1#' <<< "$1"
}

get_session_status() {
    local CURL_RESULT
    CURL_RESULT=$(curl -s -b "${BN_SESS_COOKIE}" "${URL_API_SESSION_INFO}")
    [ -z "${CURL_RESULT}" ] && echo "Not Alive" && return 0
    if echo "${CURL_RESULT}" | jq . >/dev/null 2>&1; then
        if [ "${CURL_RESULT}" != "{}" ] && [ "$(echo "${CURL_RESULT}" | jq 'has("user_id")')" = "true" ]; then
            echo "Alive"
        else
            echo "Not Alive"
        fi
    else
        echo "Unable to detect"
    fi
    return 0
}

get_user_profile_names(){
    local USER_ID=$1
    local CURL_RESULT
    [ -z "${USER_ID}" ] && { echo "User ID required" >&2; return 0; }
    CURL_RESULT=$(curl -s -b "${BN_SESS_COOKIE}" "$(make_url_user_profiles "${USER_ID}")")
    echo "${CURL_RESULT}" | jq -r '.[].name' 2>/dev/null | sed '/^[[:space:]]*$/d' || echo "Failed to get profile data" >&2
}

get_session_user_id() {
    local CURL_RESULT
    CURL_RESULT=$(curl -s -b "${BN_SESS_COOKIE}" "${URL_API_SESSION_INFO}")
    [ -z "${CURL_RESULT}" ] && echo "0" && return 0
    if echo "${CURL_RESULT}" | jq . >/dev/null 2>&1; then
        USER_ID=$(echo "${CURL_RESULT}" | jq -r '.user_id // "0"')
        echo "${USER_ID}"
    else
        echo "0"
    fi
    return 0
}

get_user_profiles_as_string() {
    local USER_ID PROFILES_DATA
    USER_ID=$(get_session_user_id)
    PROFILES_DATA=$(get_user_profile_names "${USER_ID}")
    if [ -z "${PROFILES_DATA}" ]; then
        echo "No profiles found"
        return 0
    fi
    echo "${PROFILES_DATA}" | paste -sd "," -
}

get_cve_2022_25237_status() {
    local HEADER
    HEADER=$(curl -s -I "${URL_API_SESSION_INFO}" | head -n1)
    case "${HEADER}" in
        *"HTTP/"*" 200"*) echo "Infected" ;;
        *"HTTP/"*" 401"*) echo "Not infected" ;;
        *) echo "Unknown status: ${HEADER}" ;;
    esac
}

print_configuration(){
    local BN_VERSION
    local CVE_2022_25237_STATUS
    local DOMAIN
    local SESSION_CK_IS_SET
    local USER_PROFILES
    local SESSION_STATUS='Not validated'
    if [ -z "${BN_SESS_COOKIE}" ]; then
        SESSION_CK_IS_SET="Unset"
    else
        SESSION_CK_IS_SET="Set"
    fi
    DOMAIN=$(get_domain "${BN_SERVER_URL}")
    SESSION_STATUS=$(get_session_status)
    CVE_2022_25237_STATUS=$(get_cve_2022_25237_status)
    BN_VERSION=$(get_bonita_version)
    USER_PROFILES=$(get_user_profiles_as_string)
    echo -e "Bonita Server:\t\t${DOMAIN}"
    echo -e "Bonita Version:\t\t${BN_VERSION}"
    echo -e "Cookie Conf:\t\t${SESSION_CK_IS_SET}"
    echo -e "Session Status:\t\t${SESSION_STATUS}"
    echo -e "User Profiles:\t\t${USER_PROFILES}"
    echo -e "CVE-2022-25237:\t\t${CVE_2022_25237_STATUS}"
    echo -e "Requests Limit:\t\t${BN_RQ_LIMIT}"
}

require_active_session(){
    [ "$(get_session_status)" = "Alive" ] || { echo "Active session is required. Aborting."; exit 1; }
}

require_data_in_array() {
    local OBJECTS_ARR=("$@")
    if [ ${#OBJECTS_ARR[@]} -eq 0 ]; then
        echo "No data for processing. Aborting."
        exit 0
    else
        echo "Processing ${#OBJECTS_ARR[@]} elements"
    fi
}

require_bd_output_file(){
    if [ ! -f "${FILE_OUT_BD_OBJ}" ]; then
        echo "Error: File '$(basename "${FILE_OUT_BD_OBJ}")' does not exist. Aborting." >&2
        exit 1
    fi
}

require_case_output_file(){
    if [ ! -f "${FILE_OUT_SYS_CASE_ID}" ]; then
        echo "Error: File '$(basename "${FILE_OUT_SYS_CASE_ID}")' does not exist. Aborting." >&2
        exit 1
    fi
}

require_non_empty_case_output_file(){
    require_case_output_file
    # Check if file has content
    if [[ ! -s "${FILE_OUT_SYS_CASE_ID}" ]]; then
        echo "Error: ${FILE_OUT_SYS_CASE_ID}  is empty. Aborting" >&2
        exit 1
    fi
}

make_bd_url() {
    echo "${URL_API_BD}$1?q=find&c=1&p=$2"
}

make_bdr_url() {
    echo "${URL_API_BD_REF}$1"
}

make_url_group() {
    echo "${URL_API_SYS_GROUP}?c=1&p=$1"
}

make_url_user() {
    echo "${URL_API_SYS_USER}?c=1&p=$1"
}

make_url_role() {
    echo "${URL_API_SYS_ROLE}?c=1&p=$1"
}

make_url_human_task() {
    echo "${URL_API_SYS_H_TASK}?c=1&p=$1"
}

make_url_user_profiles(){
    echo "${URL_SYS_USER_PROFILES}$1"
}

do_delay(){
    # shellcheck disable=SC2154
    sleep "${BN_RQ_DElAY_TIME}"
}

reset_data_groups(){
    rm -rf "${DIR_OUT_SYS_GROUP:?}"/{*,.[!.],..?}
}

reset_data_users(){
    rm -rf "${DIR_OUT_SYS_USER:?}"/{*,.[!.],..?}
}

reset_data_bd(){
    rm -rf "${DIR_OUT_BD:?}"/{*,.[!.],..?}
}

json_extract_value() {
    echo "$1" | jq -r ".[0].$2 // \"unknown\""
}

store_case_id() {
    local value="$1"
    # Skip if value is empty or only whitespace
    [[ -z "${value// }" ]] && return 0
    # Create file if it doesn't exist
    touch "${FILE_OUT_SYS_CASE_ID}"
    # Only append if the exact value is not already present
    grep -Fxq "${value}" "${FILE_OUT_SYS_CASE_ID}" || echo "${value}" >> "${FILE_OUT_SYS_CASE_ID}"
}

store_bd_type() {
    local value="$1"
    # Skip if value is empty or only whitespace
    [[ -z "${value// }" ]] && return 0
    # Create file if it doesn't exist
    touch "${FILE_OUT_BD_OBJ}"
    # Only append if the exact value is not already present
    grep -Fxq "${value}" "${FILE_OUT_BD_OBJ}" || echo "${value}" >> "${FILE_OUT_BD_OBJ}"
}

store_bd_type_array(){
    local -a TYPES_ARRAY=("$@")
    for BD_TYPE in "${TYPES_ARRAY[@]}"; do
        store_bd_type "${BD_TYPE}"
    done
}

store_human_task(){
    local REC_ID=$1
    local CURL_RESULT=$2
    echo "${CURL_RESULT}" > "${DIR_OUT_SYS_TASK_HUMAN}/task-${REC_ID}.json"
}
