#!/bin/bash
# Parses Business Data types from downloaded data
# bash ./extract-bd-types.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header "Parsing Business Data Types"


TMP_FILE="${DIR_OUT_SYS_BD_TYPE}/parsed-bd-type.txt"
touch "${TMP_FILE}" "${FILE_OUT_BD_OBJ}"

# Find all Business Data types from downloaded data
find "${DIR_OUT_BD}" -type f -name "*.json" -exec grep -o "com\.company\.model\.[A-Za-z][A-Za-z0-9]*" {} \; | sort -u > "${TMP_FILE}"

# Combine parsed data with existing list
cat "${TMP_FILE}" "${FILE_OUT_BD_OBJ}" | sort -u > "${TMP_FILE}.tmp" && mv "${TMP_FILE}.tmp" "${FILE_OUT_BD_OBJ}"

# Count Business Types
COUNT_LINES=$(grep -c -v "^[[:space:]]*$" "${FILE_OUT_BD_OBJ}")
echo "Business Data Types: ${COUNT_LINES}"

echo -e "\nDone"