#!/usr/bin/env bash

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

# constants and environment
declare -xr VAULT_ADDR="http://127.0.0.1:8200"

vault login $(jq -r .root_token <~/vault_init.json)
sleep 2

tput setaf 168
echo "RETRIEVE KEY-VALUE"
tput setaf 168
echo "=================="
sleep 2
vault kv get -version=1 kv/app-secret
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "DECRYPT CIPHERTEXT"
tput setaf 168
echo "=================="
sleep 2
tput setaf 168
echo "ciphertext = $(cat ciphertext.txt | jq -r '.data.ciphertext')"
sleep 2
tput setaf 168
echo "plaintext = $(vault write -field=plaintext transit/decrypt/hashiconf ciphertext=$(cat ciphertext.txt | jq -r '.data.ciphertext') | base64 --decode)"
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "GENERATE CERTIFICATE"
tput setaf 168
echo "===================="
sleep 2
vault write pki/issue/hashiconf-dot-com \
    common_name=www.hashiconf.com
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "LOOKUP FIRST MYSQL CREDENTIAL LEASE"
tput setaf 168
echo "==================================="
sleep 2
vault write sys/leases/lookup lease_id=$(cat lease_id.txt)
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "GENERATE DYNAMIC MYSQL CREDENTIALS"
tput setaf 168
echo "=================================="
sleep 2
vault read database/creds/hashiconf-role
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "LIST VAULT POLICIES"
tput setaf 168
echo "==================="
sleep 2
vault policy list
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "TEST VAULT POLICY WITH USERPASS AUTH METHOD"
tput setaf 168
echo "==========================================="
sleep 2
vault login -method=userpass \
    username=hc-admin \
    password=hashiconf
sleep 2
tput setaf 168
echo "TEST SUCCESSFUL KV GET"
tput setaf 168
echo "======================"
sleep 2
vault kv get -version=1 kv/app-secret
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "TEST FAILING KV GET"
tput setaf 168
echo "==================="
sleep 2
vault kv get kv/app-speaker || true
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1
tput setaf 168
echo "."
sleep 1

tput setaf 168
echo "RETRIEVE LATEST KEY-VALUE"
tput setaf 168
echo "========================="
sleep 3
vault kv get kv/app-secret
sleep 3
tput smso
echo "=========================================="
tput smso
echo "TESTING VAULT ENTERPRISE WITH HSM COMPLETE"
tput smso
echo "==========================================="
