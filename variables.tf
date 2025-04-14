variable "username" {
  default = "admin"
}

variable "password" {
}

variable "controller_ip" {
}

variable "ace_password" {
}

variable "aws_account_name" {
  default = "aws-account"
}

variable "aws_transit_instance_size" {
  default = "t3.micro"
}

variable "aws_transit1_region" {
  default = "us-east-2"
}

variable "aws_transit1_name" {
  default = "ace-iac-transit"
}

variable "aws_transit1_cidr" {
  default = "10.1.200.0/23"
}

variable "aws_spoke_instance_size" {
  default = "t3.micro"
}

variable "aws_spoke1_region" {
  default = "us-east-2"
}

variable "aws_spoke1_name" {
  default = "ace-iac-spoke1"
}

variable "aws_spoke1_cidr" {
  default = "10.1.211.0/24"
}

variable "aws_test_instance_size" {
  default = "t2.micro"
}

variable "azure_account_name" {
  default = "azure-account"
}

variable "azure_subscription_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "azure_spoke_instance_size" {
  default = "Standard_B1ms"
}

variable "azure_spoke2_region" {
  default = "Canada Central"
}

variable "azure_spoke2_name" {
  default = "ace-iac-spoke2"
}

variable "azure_spoke2_cidr" {
  default = "10.1.212.0/24"
}

variable "azure_test_instance_size" {
  default = "Standard_B1ms"
}

variable "ace_ec2_key_name" {
  default = "ACE"
}

variable "ha_enabled" {
  type    = bool
  default = false
}

