# Provision CloudHSM
resource "aws_cloudhsm_v2_cluster" "cloudhsm_v2_cluster" {
  hsm_type   = "hsm1.medium"
  subnet_ids = [aws_subnet.vault-a.id]

  tags = {
    Name = "${var.prefix}-vault-cloudhsm"
  }
}

resource "aws_cloudhsm_v2_hsm" "cloudhsm_v2_hsm" {
  cluster_id = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id
  subnet_id  = aws_subnet.vault-a.id
}

# Creates IAM Policy to access provisioned CloudHSM
resource "aws_iam_policy" "vault-hsm-policy" {
  name        = "${var.prefix}-vault-hsm-policy"
  description = "Access CloudHSM from Vault running in EC2"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[{
      "Effect":"Allow",
      "Action":[
         "cloudhsm:*",
         "ec2:CreateNetworkInterface",
         "ec2:DescribeNetworkInterfaces",
         "ec2:DescribeNetworkInterfaceAttribute",
         "ec2:DetachNetworkInterface",
         "ec2:DeleteNetworkInterface",
         "ec2:CreateSecurityGroup",
         "ec2:AuthorizeSecurityGroupIngress",
         "ec2:AuthorizeSecurityGroupEgress",
         "ec2:RevokeSecurityGroupEgress",
         "ec2:DescribeSecurityGroups",
         "ec2:DeleteSecurityGroup",
         "ec2:CreateTags",
         "ec2:DescribeVpcs",
         "ec2:DescribeSubnets",
         "iam:CreateServiceLinkedRole",
         "dynamodb:DescribeLimits",
         "dynamodb:DescribeTimeToLive",
         "dynamodb:ListTagsOfResource",
         "dynamodb:DescribeReservedCapacityOfferings",
         "dynamodb:DescribeReservedCapacity",
         "dynamodb:ListTables",
         "dynamodb:BatchGetItem",
         "dynamodb:BatchWriteItem",
         "dynamodb:CreateTable",
         "dynamodb:DeleteItem",
         "dynamodb:GetItem",
         "dynamodb:GetRecords",
         "dynamodb:PutItem",
         "dynamodb:Query",
         "dynamodb:UpdateItem",
         "dynamodb:Scan",
         "dynamodb:DescribeTable",
         "dynamodb:CreateBackup",
         "dynamodb:RestoreTableFromBackup",
         "dynamodb:PutItem",
         "dynamodb:UpdateItem",
         "dynamodb:DeleteItem",
         "dynamodb:GetItem",
         "dynamodb:Query",
         "dynamodb:Scan",
         "dynamodb:BatchWriteItem",
         "dynamodb:DescribeBackup"
      ],
      "Resource":"*"
   }]
}
EOF
}
