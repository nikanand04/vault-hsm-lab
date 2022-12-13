# Post Provisoner resource to complete the provisioning of lab components

### enterprise vault instance
resource "null_resource" "configure-vault-ent" {
  #   depends_on = [aws_eip_association.vault-ent]

  # triggers = {
  #   build_number = timestamp()
  # }

  provisioner "file" {
    content = templatefile("./files/templates/output.tftpl",
      { hsm_cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id,
        rds_endpoint   = aws_db_instance.vault.endpoint,
        vault_ent_ip   = aws_eip.vault-ent.public_ip,
        vault_hsm_ip   = aws_eip.vault-hsm.public_ip
    })
    destination = "/home/ubuntu/output.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }

  provisioner "file" {
    source      = "./files/vault_ent/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }

  provisioner "file" {
    source      = "./privateKey.pem"
    destination = "/home/ubuntu/privateKey.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
      "chmod +x tf_remote_provision",
      # "./tf_remote_provision",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }
}

### hsm vault instance
resource "null_resource" "configure-vault-hsm" {
  #   depends_on = [aws_eip_association.vault-hsm]

  # triggers = {
  #   build_number = timestamp()
  # }

  provisioner "file" {
    content = templatefile("./files/templates/output.tftpl",
      { hsm_cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id,
        rds_endpoint   = aws_db_instance.vault.endpoint,
        vault_ent_ip   = aws_eip.vault-ent.public_ip,
        vault_hsm_ip   = aws_eip.vault-hsm.public_ip
    })
    destination = "/home/ubuntu/output.txt"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }

  provisioner "file" {
    source      = "./files/vault_hsm/"
    destination = "/home/ubuntu/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-hsm.public_ip
    }
  }

  provisioner "file" {
    source      = "./privateKey.pem"
    destination = "/home/ubuntu/privateKey.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-ent.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g' /etc/ssh/ssh_config",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.vault.private_key_pem
      host        = aws_eip.vault-hsm.public_ip
    }
  }
}
