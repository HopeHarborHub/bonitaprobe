#!/bin/bash
set -e
SCRIPTS_DIR=$(dirname "$(realpath "$0")")
source "${SCRIPTS_DIR}/_config.sh"

# Include functions
source "${SCRIPTS_DIR}/_functions.sh"
load_conf_from_env

# URL's
export URL_API="${BN_SERVER_URL}/API"
export URL_API_BD="${URL_API}/bdm/businessData/"
export URL_API_BD_LIST="${URL_API}/extension/demo/bd"
export URL_API_BD_REF="${URL_API}/bdm/businessDataReference?p=0&c=10&f=caseId="
export URL_API_SESSION_INFO="${URL_API}/system/session/unusedid;i18ntranslation"
export URL_API_SYS_GROUP="${URL_API}/identity/group/;i18ntranslation"
export URL_API_SYS_USER="${URL_API}/identity/user/;i18ntranslation"
export URL_SYS_EXT_BD="${URL_API}/extension/demo/bd"
export URL_SYS_EXT_ENABLE="${BN_SERVER_URL}/API/portal/page/;i18ntranslation"
export URL_SYS_EXT_UPLOAD="${BN_SERVER_URL}/portal/pageUpload;i18ntranslation?action=add"
export URL_SYS_USER_PROFILES="${BN_SERVER_URL}/API/portal/profile/;i18ntranslation?p=0&c=100&f=user_id%3d"
export URL_API_SYS_ROLE="${URL_API}/identity/role"
export URL_API_SYS_H_TASK="${URL_API}/bpm/humanTask"

# Output root
mkdir -p "${SCRIPTS_DIR}/../output"
DIR_OUT="$(readlink -f "${SCRIPTS_DIR}/../output")"
export DIR_OUT

# Output dirs
export DIR_OUT_BD="${DIR_OUT}/bd"
export DIR_OUT_SYS_GROUP="${DIR_OUT}/sys/group"
export DIR_OUT_SYS_ROLE="${DIR_OUT}/sys/role"
export DIR_OUT_SYS_USER="${DIR_OUT}/sys/user"
export DIR_OUT_SYS_TASK_HUMAN="${DIR_OUT}/sys/humanTask"
export DIR_OUT_SYS_CASE_ID="${DIR_OUT}/sys/caseId"
export DIR_OUT_SYS_BD_TYPE="${DIR_OUT}/sys/bdType"

DIR_BN_EXT="$(readlink -f "${SCRIPTS_DIR}/../bn-ext")"

# Input files
export FILE_IN_BN_EXT_BD_TYPES="${DIR_BN_EXT}/bdTypes.zip"

# Output files
export FILE_OUT_BD_OBJ="${DIR_OUT_SYS_BD_TYPE}/result-bd-type.txt"
export FILE_OUT_SYS_CASE_ID="${DIR_OUT_SYS_CASE_ID}/result-case-ids.txt"

# Create output dirs
mkdir -p "${DIR_OUT_SYS_GROUP}"
mkdir -p "${DIR_OUT_SYS_ROLE}"
mkdir -p "${DIR_OUT_SYS_USER}"
mkdir -p "${DIR_OUT_SYS_TASK_HUMAN}"
mkdir -p "${DIR_OUT_SYS_CASE_ID}"
mkdir -p "${DIR_OUT_SYS_BD_TYPE}"
