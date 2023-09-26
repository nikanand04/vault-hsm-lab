#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
readonly __DEBUG="${MP_DEBUG:=0}"

# Define field seperator for word spllitting
# IFS=$' \n\t'

# set debug output
if [[ ${__DEBUG} = 1 || ${__DEBUG} = "TRUE" ]]; then
	set -o xtrace #Turn on traces, useful while debugging but unset by default
fi

###
# Global Variables
###
# readonly __XFR_FILES=(output.txt access_key.txt secret_key.txt)
readonly __XFR_FILES=(output.txt privateKey.pem)

# terraform output -json >output.txt

tee output.txt &>/dev/null <<EOF
{
	"hsm_cluster_id": {
		"value": "${HSM_CLUSTER_ID}"
	},
	"rds_endpoint": {
		"value": "${RDS_ENDPOINT}"
	},
	"vault_ent_ip": {
		"value": "${VAULT_ENT_IP}"
	},
	"vault_hsm_ip": {
		"value": "${VAULT_HSM_IP}"
	}
}
EOF

for i in "${__XFR_FILES[@]}"; do
	scp "${i}" root@${VAULT_ENT_IP}:~
	scp "${i}" root@${VAULT_HSM_IP}:~
done
