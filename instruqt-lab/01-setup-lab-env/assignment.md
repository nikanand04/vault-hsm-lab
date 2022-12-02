---
slug: setup-lab-env
id: h60ytzxh5fyi
type: challenge
title: "\U0001F3E1 HowTo: Vault w/ Setup AWS Cloud HSM"
teaser: |
  Step by step walkthrough for setting up vault with and HSM
notes:
- type: text
  contents: |
    How to setup Vault Enterprise with HSM Integration
tabs:
- title: Workstation
  type: terminal
  hostname: workstation
- title: HSM
  type: terminal
  hostname: workstation
- title: Text Editor
  type: code
  hostname: workstation
  path: /root/vault-hsm-lab/tf
- title: AWS Console
  type: service
  hostname: cloud-client
  path: /
  port: 80
difficulty: basic
timelimit: 28800
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
