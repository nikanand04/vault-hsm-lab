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
readonly __XFR_FILES=(output.txt)

terraform output -json >output.txt

for i in "${__XFR_FILES[@]}"; do
	scp -i privateKey.pem ${i} ubuntu@$(cat output.txt | jq -r '.vault_ent_ip.value'):~
	scp -i privateKey.pem ${i} ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value'):~
done
