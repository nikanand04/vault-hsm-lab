
variable "prefix" {
  description = "Prefix that will be added to all taggable resources"
  default     = "hsm-lab"
}

variable "subnet_prefix_a" {
  description = "The address prefix to use for the subnet in availability zone a"
  default     = "10.0.1.0/24"
}

variable "subnet_prefix_b" {
  description = "The address prefix to use for the subnet in availability zone b"
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t2.medium"
}

variable "region" {
  type        = string
  description = "specifies the aws region to provision infrastracture to"
  default     = "us-west-2"
}
