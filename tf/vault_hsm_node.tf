resource "aws_eip" "vault-hsm" {
  instance = aws_instance.vault-hsm.id
  vpc      = true
}

resource "aws_eip_association" "vault-hsm" {
  instance_id   = aws_instance.vault-hsm.id
  allocation_id = aws_eip.vault-hsm.id
}

resource "aws_instance" "vault-hsm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.vault.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.vault-a.id
  vpc_security_group_ids      = [aws_security_group.vault.id, aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.vault-hsm-instance-profile.name

  tags = {
    Name = "${var.prefix}-vault-hsm-instance"
  }
}

# Creates Role, referencing "vault-hsm-policy"
resource "aws_iam_role" "vault-hsm-role" {
  name = "${var.prefix}-vault-hsm-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attaches "vault-hsm-policy" to "vault-hsm-role"
resource "aws_iam_role_policy_attachment" "vault-hsm-policy-attach" {
  role       = aws_iam_role.vault-hsm-role.name
  policy_arn = aws_iam_policy.vault-hsm-policy.arn
}

resource "aws_iam_instance_profile" "vault-hsm-instance-profile" {
  name = "${var.prefix}-vault-hsm-instance-profile"
  role = aws_iam_role.vault-hsm-role.name
}
