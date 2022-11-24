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

tput setaf 3
echo "CONFIGURING KEY-VALUE SECRETS ENGINE"
tput setaf 3
echo "===================================="
sleep 1
vault secrets enable -version=2 kv
vault kv put kv/app-secret event=HashiConf topic=Vault date=11-17-2022
vault kv put kv/app-user name="developer"
vault kv get kv/app-secret

tput setaf 3
echo "CONFIGURING TRANSIT SECRETS ENGINE"
tput setaf 3
echo "=================================="
sleep 1
vault secrets enable transit
vault write -f transit/keys/hashiconf
vault write transit/encrypt/hashiconf plaintext=$(base64 <<<"Welcome to HashiConf 2022!")
vault write transit/encrypt/hashiconf plaintext=$(base64 <<<"Welcome to HashiConf 2022!") -format=json >ciphertext.txt
tput setaf 3
echo "Encrypting plaintext: \"Welcome to hashiconf 2022!\""
sleep 1
tput setaf 3
echo "into ciphertext: $(cat ciphertext.txt | jq -r '.data.ciphertext')"
sleep 1
tput setaf 3
echo "And decrypting ciphertext back to plaintext"
sleep 1
tput setaf 3
echo "vault write -field=plaintext transit/decrypt/hashiconf ciphertext=$(cat ciphertext.txt | jq -r '.data.ciphertext') | base64 --decode"
vault write -field=plaintext transit/decrypt/hashiconf ciphertext=$(cat ciphertext.txt | jq -r '.data.ciphertext') | base64 --decode
sleep 2

tput setaf 3
echo "CONFIGURING PKI SECRETS ENGINE"
tput setaf 3
echo "=============================="
sleep 1
vault secrets enable pki
vault write pki/root/generate/internal \
    common_name=hashiconf.com \
    ttl=720h
vault write pki/config/urls \
    issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
    crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
vault write pki/roles/hashiconf-dot-com \
    allowed_domains=hashiconf.com \
    allow_subdomains=true \
    max_ttl=72h
vault write pki/issue/hashiconf-dot-com \
    common_name=www.hashiconf.com

tput setaf 3
echo "CONFIGURING DATABASE SECRETS ENGINE"
tput setaf 3
echo "==================================="
sleep 1
vault secrets enable database
vault write database/config/my-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp($(cat output.txt | jq -r '.rds_endpoint.value'))/" \
    allowed_roles="developer-role" \
    username="hcadmin" \
    password="migrateVault!"
vault write database/roles/developer-role \
    db_name=my-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="8h" \
    max_ttl="24h"
tput setaf 3
echo "GENERATE MYSQL DATABASE CREDENTIALS AND STORE LEASE ID"
tput setaf 3
echo "======================================================"
sleep 1
vault read database/creds/developer-role -format=json | jq -r '.lease_id' >lease_id.txt
sleep 1
tput setaf 3
echo "Lease ID = $(cat lease_id.txt)"
sleep 1

tput setaf 3
echo "CREATE VAULT POLICY"
tput setaf 3
echo "==================="
sleep 1
vault policy write hashiconf-policy - <<EOF
path "kv/data/*" {
  capabilities = ["create", "update","read"]
}

path "kv/data/app-user" {
  capabilities = ["deny"]
}
EOF
sleep 1
tput setaf 3
echo "CREAT USERPASS AUTH METHOD WITH \"hashiconf-policy\""
tput setaf 3
echo "====================================================="
sleep 1
vault auth enable userpass
vault write auth/userpass/users/hc-admin \
    password=hashiconf \
    policies=hashiconf-policy
sleep 1
tput setaf 3
echo "LOGIN WITH USERPASS AUTH METHOD"
tput setaf 3
echo "==============================="
sleep 1
vault login -method=userpass \
    username=hc-admin \
    password=hashiconf
sleep 1
tput setaf 3
echo "TEST SUCCESSFUL KV GET"
tput setaf 3
echo "======================"
sleep 1
vault kv get kv/app-secret
sleep 1
tput setaf 3
echo "TEST FAILING KV GET"
tput setaf 3
echo "==================="
sleep 1
vault kv get kv/app-user
sleep 2

scp -i privateKey.pem vault_init.json ciphertext.txt lease_id.txt ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value'):~
