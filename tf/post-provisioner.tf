# Post Provisoner resource to complete the provisioning of lab components

### enterprise vault instance
resource "null_resource" "configure-vault-ent" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.vault.private_key_pem
    host        = aws_eip.vault-ent.public_ip
  }

  provisioner "file" {
    content = templatefile("./files/templates/output.tftpl",
      { hsm_cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id,
        rds_endpoint   = aws_db_instance.vault.endpoint,
        vault_ent_ip   = aws_eip.vault-ent.public_ip,
        vault_hsm_ip   = aws_eip.vault-hsm.public_ip
    })
    destination = "/home/ubuntu/output.txt"
  }

  provisioner "file" {
    source      = "./files/vault_ent/"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = "./privateKey.pem"
    destination = "/home/ubuntu/privateKey.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
      "chmod +x tf_remote_provision",
      "./tf_remote_provision",
    ]
  }
}

### hsm vault instance
resource "null_resource" "configure-vault-hsm" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.vault.private_key_pem
    host        = aws_eip.vault-hsm.public_ip
  }

  provisioner "file" {
    content = templatefile("./files/templates/output.tftpl",
      { hsm_cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id,
        rds_endpoint   = aws_db_instance.vault.endpoint,
        vault_ent_ip   = aws_eip.vault-ent.public_ip,
        vault_hsm_ip   = aws_eip.vault-hsm.public_ip
    })
    destination = "/home/ubuntu/output.txt"
  }

  provisioner "file" {
    source      = "./files/vault_hsm/"
    destination = "/home/ubuntu/"
  }

  provisioner "file" {
    source      = "./privateKey.pem"
    destination = "/home/ubuntu/privateKey.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
    ]
  }
}

### generate outputs
resource "null_resource" "client-nodes" {
  provisioner "local-exec" {
    command = "chmod +x save_output.sh && ./save_output.sh"
    environment = {
      HSM_CLUSTER_ID = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id,
      RDS_ENDPOINT   = aws_db_instance.vault.endpoint,
      VAULT_ENT_IP   = aws_eip.vault-ent.public_ip,
      VAULT_HSM_IP   = aws_eip.vault-hsm.public_ip
    }
  }
}
