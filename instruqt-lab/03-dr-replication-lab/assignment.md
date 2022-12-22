---
slug: dr-replication-lab
id:
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
timelimit: 14400
---

Manage Infrastructure
========================

## SSH to Vault Enterprise Basic Node
```
ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_ent_ip.value')
```