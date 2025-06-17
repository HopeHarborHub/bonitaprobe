#!/bin/bash
# Parses Users from downloaded data and stores into TSV file
# bash ./extract-users-tsv.sh
set -e
source "$(dirname "$0")/_const.sh"
print_header "Parsing Users list"

# Check if directory exists
if [ ! -d "${DIR_OUT_SYS_USER}" ]; then
    echo "Error: Directory ${DIR_OUT_SYS_USER} does not exist"
    exit 1
fi

# Count JSON files
FILES_COUNT=$(find "${DIR_OUT_SYS_USER}" -type f -name "*.json" | wc -l | tr -d '[:space:]')

if [ "${FILES_COUNT}" -eq 0 ]; then
    echo "No JSON files to parse"
    exit 1
fi

echo "Processing ${FILES_COUNT} files..."


# Define output file in the same directory
OUTPUT_FILE="${DIR_OUT}/users.tsv"

# Create/clear the output file with headers
echo -e "id\tuserName\tfirstname\tlastname\ttitle\tjob_title\tmanager_id\tcreation_date\tlast_update_date\tlast_connection\tcreated_by_user_id\tenabled\ticon" > "${OUTPUT_FILE}"

# Process each JSON file in the directory
find "${DIR_OUT_SYS_USER}" -type f -name "*.json" -print0 | while IFS= read -r -d '' FILE_IN; do
    jq -r '.[] | [
        .id,
        .userName,
        .firstname,
        .lastname,
        .title,
        .job_title,
        .manager_id,
        .creation_date,
        .last_update_date,
        .last_connection,
        .created_by_user_id,
        .enabled,
        .icon
    ] | @tsv' "${FILE_IN}" >> "${OUTPUT_FILE}"
done

# Count non-empty rows excluding header
ROWS_COUNT=$(sed '1d' "${OUTPUT_FILE}" | grep -v '^[[:space:]]*$' | wc -l | tr -d '[:space:]')

echo "Total records: ${ROWS_COUNT}"
echo "Processing complete"
