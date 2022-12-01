#!/usr/bin/env bash

sudo apt update -y
sudo apt install awscli jq unzip -y

HSM_CLUSTER_ID="$(jq <output.txt -r .hsm_cluster_id.value)"
export HSM_CLUSTER_ID
AWS_DEFAULT_REGION=us-west-2
export AWS_DEFAULT_REGION

# Create pki CA to cloudHSM csr
wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.1.1/EasyRSA-3.1.1.tgz
tar -xvf EasyRSA-3.1.1.tgz -C keys --strip-components 1
rm -f EasyRSA-3.1.1.tgz

aws cloudhsmv2 describe-clusters --filters clusterIds="${HSM_CLUSTER_ID}" \
  --output text --query 'Clusters[].Certificates.ClusterCsr' >${PWD}/keys/ClusterCsr.csr

cd ${PWD}/keys
./easyrsa init-pki
cp vars.auto pki/vars
./easyrsa build-ca nopass

openssl x509 -req -days 3652 -in ClusterCsr.csr \
  -CA pki/ca.crt -CAkey pki/private/ca.key -CAcreateserial \
  -out CustomerHsmCertificate.crt

# initialize cloudhsm with signed cert
aws cloudhsmv2 initialize-cluster --cluster-id "${HSM_CLUSTER_ID}" \
  --signed-cert file://CustomerHsmCertificate.crt \
  --trust-anchor file://pki/ca.crt

# Check periodically until it shows INITIALIZED
CLUSTER_INIT="NOT INITIALIZED"
spinner='⣾⣿⣽⣿⣻⣿⢿⣿⡿⣿⣿⢿⣿⡿⣿⣟⣿⣯⣿⣷⣿⣾⣷⣿'
# spinner='🌕 🌖 🌗 🌘 🌑 🌒 🌓 🌔 🌕'
spinlen=${#spinner}
char=0

while [ ! "${CLUSTER_INIT}" = "INITIALIZED" ]; do
  CLUSTER_INIT="$(aws cloudhsmv2 describe-clusters --filters clusterIds="${HSM_CLUSTER_ID}" | jq -r '.Clusters[] | .State')"
  char=$(((char + 1) % spinlen))
  printf "%s" "${spinner:$char:1}"
done
#  aws cloudhsmv2 describe-clusters --filters clusterIds="${HSM_CLUSTER_ID}" | jq -r '.Clusters[] | .State'

#Finds the IP address of the CloudHSM
HSM_IP=$(aws cloudhsmv2 describe-clusters \
  --filters clusterIds="${HSM_CLUSTER_ID}" \
  --query 'Clusters[].Hsms[] .EniIp' | jq -r .[])
export HSM_IP

# instruction for ClouHSM-client install
# ref. https://docs.aws.amazon.com/cloudhsm/latest/userguide/cmu-install-and-configure-client-linux.html
wget https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Bionic/cloudhsm-client_latest_u18.04_amd64.deb
sudo apt install ./cloudhsm-client_latest_u18.04_amd64.deb -y

sudo /opt/cloudhsm/bin/configure -a "${HSM_IP}"

sudo cp pki/ca.crt /opt/cloudhsm/etc/customerCA.crt
sudo chmod 644 /opt/cloudhsm/etc/customerCA.crt

### requires interaction
# /opt/cloudhsm/bin/cloudhsm_mgmt_util /opt/cloudhsm/etc/cloudhsm_mgmt_util.cfg
# loginHSM PRECO admin password
# changePswd PRECO admin hashivault
# logoutHSM
# loginHSM CO admin hashivault
# createUser CU vault Password1
# quit
### end interaction

### non-interactive method
wget https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Bionic/cloudhsm-cli_latest_u18.04_amd64.deb
sudo apt install ./cloudhsm-cli_latest_u18.04_amd64.deb -y
sudo /opt/cloudhsm/bin/configure-cli -a "${HSM_IP}"
CLOUDHSM_ROLE=admin
CLOUDHSM_PIN=admin:hashivault
sudo CLOUDHSM_ROLE=${CLOUDHSM_ROLE} CLOUDHSM_PIN=${CLOUDHSM_PIN} /opt/cloudhsm/bin/cloudhsm-cli cluster activate --password hashivault
sudo CLOUDHSM_ROLE=${CLOUDHSM_ROLE} CLOUDHSM_PIN=${CLOUDHSM_PIN} /opt/cloudhsm/bin/cloudhsm-cli user create --username vault --role crypto-user --password Password1
sudo CLOUDHSM_ROLE=${CLOUDHSM_ROLE} CLOUDHSM_PIN=${CLOUDHSM_PIN} /opt/cloudhsm/bin/cloudhsm-cli user list | jq -r '.data.users[] | .username'

# Install PKCS #11 Library
wget https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Bionic/cloudhsm-client-pkcs11_latest_u18.04_amd64.deb
sudo apt install ./cloudhsm-client-pkcs11_latest_u18.04_amd64.deb -y
sudo service cloudhsm-client start
