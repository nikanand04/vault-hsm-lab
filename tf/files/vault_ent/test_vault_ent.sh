#!/usr/bin/env bash

vault login $(jq -r .root_token <~/vault_init.json)
sleep 2

tput setaf 190
echo "RETRIEVE KEY-VALUE"
tput setaf 190
echo "=================="
sleep 2
vault kv get kv/app-secret
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "DECRYPT CIPHERTEXT"
tput setaf 190
echo "=================="
sleep 2
tput setaf 190
echo "ciphertext = $(cat ciphertext.txt | jq -r '.data.ciphertext')"
sleep 2
tput setaf 190
echo "plaintext = $(vault write -field=plaintext transit/decrypt/hashiconf ciphertext=$(cat ciphertext.txt | jq -r '.data.ciphertext') | base64 --decode)"
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "GENERATE CERTIFICATE"
tput setaf 190
echo "===================="
sleep 2
vault write pki/issue/hashiconf-dot-com \
    common_name=www.hashiconf.com
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "LOOKUP FIRST MYSQL CREDENTIAL LEASE"
tput setaf 190
echo "==================================="
sleep 2
vault write sys/leases/lookup lease_id=$(cat lease_id.txt)
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "GENERATE DYNAMIC MYSQL CREDENTIALS"
tput setaf 190
echo "=================================="
sleep 2
vault read database/creds/hashiconf-role
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "LIST VAULT POLICIES"
tput setaf 190
echo "==================="
sleep 2
vault policy list
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1

tput setaf 190
echo "TEST VAULT POLICY WITH USERPASS AUTH METHOD"
tput setaf 190
echo "==========================================="
sleep 2
vault login -method=userpass \
    username=hc-admin \
    password=hashiconf
sleep 2
tput setaf 190
echo "TEST SUCCESSFUL KV GET"
tput setaf 190
echo "======================"
sleep 2
vault kv get kv/app-secret
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "TEST FAILING KV GET"
tput setaf 190
echo "==================="
sleep 2
vault kv get kv/app-speaker
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput setaf 190
echo "."
sleep 1
tput smso
echo "================================="
tput smso
echo "TESTING VAULT ENTERPRISE COMPLETE"
tput smso
echo "================================="
sleep 2
