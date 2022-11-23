### Variables ###

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

### Resources ###

resource "aws_vpc" "vault" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vault-vpc"
  }
}

resource "aws_internet_gateway" "vault" {
  vpc_id = aws_vpc.vault.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "vault" {
  vpc_id = aws_vpc.vault.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vault.id
  }
}

resource "aws_db_subnet_group" "mysql" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.vault-a.id, aws_subnet.vault-b.id]

  tags = {
    Name = "${var.prefix}-db-subnet-group"
  }
}

resource "aws_subnet" "vault-a" {
  vpc_id            = aws_vpc.vault.id
  cidr_block        = var.subnet_prefix_a
  availability_zone = "${var.region}a"

  tags = {
    name = "${var.prefix}-subnet-a"
  }
}

resource "aws_subnet" "vault-b" {
  vpc_id            = aws_vpc.vault.id
  cidr_block        = var.subnet_prefix_b
  availability_zone = "us-west-2b"

  tags = {
    name = "${var.prefix}-subnet-b"
  }
}

resource "aws_route_table_association" "vault-a" {
  subnet_id      = aws_subnet.vault-a.id
  route_table_id = aws_route_table.vault.id
}

resource "aws_route_table_association" "vault-b" {
  subnet_id      = aws_subnet.vault-b.id
  route_table_id = aws_route_table.vault.id
}
