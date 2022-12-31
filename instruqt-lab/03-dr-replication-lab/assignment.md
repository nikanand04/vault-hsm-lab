---
slug: dr-replication-lab
id: odxnzh17ko6u
type: challenge
title: "\U0001F3E1 HowTo: Setup DR Replication"
teaser: |
  Walkthrough for setting up vault DR replication
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

Manage Infrastructure
========================

## SSH to Vault Enterprise Basic Node
```
ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_ent_ip.value')
```