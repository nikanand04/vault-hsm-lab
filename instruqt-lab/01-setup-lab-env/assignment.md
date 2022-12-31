---
slug: setup-lab-env
id: a7pyxrdf0ekc
type: challenge
title: "\U0001F3E1 Build lab environment"
teaser: |
  Use terraform to deploy a lab where you will build a vault enterprise environment
notes:
- type: text
  contents: |
    How to setup Vault Enterprise with HSM Integration
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: vault ent
  type: terminal
  hostname: vault-ent
- title: vault hsm
  type: terminal
  hostname: vault-hsm
- title: Text Editor
  type: code
  hostname: workstation
  path: /root/vault-hsm-lab/tf
difficulty: basic
timelimit: 14400
---

Provision Infrastructure
========================

## Provision Infrastructure
```
terraform init
terraform apply -auto-approve
```

## Save Output
```
chmod +x *.sh
./save_output.sh
```

## SSH to Vault Enterprise Basic Node
```
ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_ent_ip.value')
```

## SSH to Vault HSM Node
```
ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value')
```

## Enable Scripts
```
chmod +x *.sh
```

## Cleanup Lab Environment
```
terraform apply -destroy -auto-approve
```

Setup Vault Enterprise with HSM
=================================
## Navigate to the `HSM` tab.

## SSH to Vault HSM Node
```
ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value')
```
