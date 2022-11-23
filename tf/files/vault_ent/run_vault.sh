#!/usr/bin/env bash

vault operator init -key-shares=1 -key-threshold=1 -format=json >~/vault_init.json
vault operator unseal $(jq -r .unseal_keys_b64[0] <~/vault_init.json)
sleep 5
scp -i privateKey.pem vault_init.json ciphertext.txt lease_id.txt ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value'):~
vault login $(jq -r .root_token <~/vault_init.json)
