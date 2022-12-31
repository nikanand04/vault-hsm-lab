---
slug: hsm-lab
id: efmmnmgdaxj5
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
- title: vault ent
  type: terminal
  hostname: vault-ent
  cmd: ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_ent_ip.value')
- title: vault hsm
  type: terminal
  hostname: vault-hsm
  cmd: ssh -i privateKey.pem ubuntu@$(cat output.txt | jq -r '.vault_hsm_ip.value')
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

## Configure and Start Vault Service with HSM Integration
```
sudo apt update -y
sudo apt install awscli jq unzip -y
```
```
chmod +x *.sh
source ~/.bashrc
```

## Export Environment Variables
```
export HSM_CLUSTER_ID=$(cat output.txt | jq -r .hsm_cluster_id.value)
export AWS_DEFAULT_REGION=us-west-2
```

## Generate CSR
```
aws cloudhsmv2 describe-clusters --filters clusterIds=${HSM_CLUSTER_ID} \
  --output text --query 'Clusters[].Certificates.ClusterCsr' > ClusterCsr.csr
```

## Generate Key
```
openssl genrsa -aes256 -out customerCA.key 2048
```

## Generate CA Cert
```
openssl req -new -x509 -days 3652 -key customerCA.key -out customerCA.crt
```

## Generate HSM Cert
```
openssl x509 -req -days 3652 -in ClusterCsr.csr \
  -CA customerCA.crt -CAkey customerCA.key -CAcreateserial \
  -out CustomerHsmCertificate.crt
```

## Initialize HSM Cluster
```
aws cloudhsmv2 initialize-cluster --cluster-id ${HSM_CLUSTER_ID} \
  --signed-cert file://CustomerHsmCertificate.crt \
  --trust-anchor file://customerCA.crt
```

## Check periodically until it shows `INITIALIZED`
```
watch aws cloudhsmv2 describe-clusters \
      --filters clusterIds=${HSM_CLUSTER_ID} \
      --output text \
      --query 'Clusters[].State'
```
Press `Ctrl+C` to exit out of this watch.

## Find and Save the IP address of the CloudHSM
```
export HSM_IP=$(aws cloudhsmv2 describe-clusters \
      --filters clusterIds=${HSM_CLUSTER_ID} \
      --query 'Clusters[].Hsms[] .EniIp' | jq -r .[])
```

## Install the HSM Client
```
wget https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Bionic/cloudhsm-client_latest_u18.04_amd64.deb
sudo apt install ./cloudhsm-client_latest_u18.04_amd64.deb -y
```
```
sudo /opt/cloudhsm/bin/configure -a $HSM_IP
sudo mv customerCA.crt /opt/cloudhsm/etc/customerCA.crt
```

## Configure HSM User
```
/opt/cloudhsm/bin/cloudhsm_mgmt_util /opt/cloudhsm/etc/cloudhsm_mgmt_util.cfg
```
```
loginHSM PRECO admin password
changePswd PRECO admin hashivault
```
Press `y` then `Enter` when prompted.

```
logoutHSM
loginHSM CO admin hashivault
createUser CU vault Password1
```
Press `y` then `Enter` when prompted.

```
quit
```

## Install PKCS #11 Library
```
sudo service cloudhsm-client start
wget https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Bionic/cloudhsm-client-pkcs11_latest_u18.04_amd64.deb
sudo apt install ./cloudhsm-client-pkcs11_latest_u18.04_amd64.deb -y
```

## Install Vault Enterprise with HSM Integration
```
./install_vault_hsm.sh
```

## Initialize and Unseal Vault Enterprise with HSM Integration
```
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.bashrc
source ~/.bashrc
./run_vault_hsm.sh
```

## Navigate to the `HSM` tab.

## Check Replication Status, looking for `"connection_status": "disconnected"`
```
vault read -format=json sys/replication/status | jq '.data.dr.primaries'
```

## Promote Vault Enterprise with HSM (DR Secondary)
```
vault write -f /sys/replication/dr/secondary/promote dr_operation_token=${DR_OPERATION_TOKEN}
```

## Check Replication Status, where the mode is `"primary"`
```
vault read -format=json sys/replication/status | jq '.data.dr'
```

## Test Vault Login with Original Root Token
```
vault login $(jq -r .root_token < vault_init.json)
```

## Final Testing
```
test_vault_hsm.sh
```