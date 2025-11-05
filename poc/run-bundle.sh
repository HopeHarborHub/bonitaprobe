#!/bin/bash
# Executes an entire set of tests
# bash ./run-bundle.sh
set -e
SCRIPTS_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPTS_DIR}/_const.sh"
print_dash_line
print_header "BUNDLE OF TESTS"

# Ask for a target
while true; do
    [ -n "${BONITA_URL}" ] && break
    read -r -p "Enter target URL: " USER_INPUT_URL
    if [ -n "${USER_INPUT_URL}" ]; then
        USER_INPUT_URL=$(echo "${USER_INPUT_URL}" | sed -e 's/^[[:space:]\/]*//' -e 's/[[:space:]\/]*$//')
        export BONITA_URL="${USER_INPUT_URL}"
        break
    else
        echo -e "\tURL cannot be empty. Please try again."
    fi
done

# Ask for session
while true; do
    [ -n "${BONITA_SESSION_ID}" ] && break
    read -r -s -p "Enter Session ID: " USER_INPUT_SESSION
    echo
    if [ -n "${USER_INPUT_SESSION}" ]; then
        export BONITA_SESSION_ID="${USER_INPUT_SESSION}"
        break
    else
        echo "Session ID cannot be empty. Please try again."
    fi
done

# Run tests
bash "${SCRIPTS_DIR}/cve-2022-25237-status.sh"
bash "${SCRIPTS_DIR}/dnl-sys-user.sh"
bash "${SCRIPTS_DIR}/dnl-sys-group.sh"
bash "${SCRIPTS_DIR}/abp-ext-upload.sh"
bash "${SCRIPTS_DIR}/dnl-bd.sh"
# End of tests
print_dash_line
echo "Bundle done"