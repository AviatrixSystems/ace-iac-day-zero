variable "username" {
  type    = string
  default = "admin"
}

variable "password" {
  type = string
}

variable "controller_ip" {
  type = string
}

variable "prefix" {
  type    = bool
  default = false
}

variable "suffix" {
  type    = bool
  default = false
}

variable "aws_account_name" {
}

variable "aws_transit_instance_size" {
  type    = string
  default = "c5.xlarge"
}

variable "aws_transit1_region" {
  default = "ca-central-1"
}

variable "aws_transit1_name" {
  default = "ace-aws-ca-central-1-transit"
}

variable "aws_transit1_cidr" {
  default = "10.1.200.0/23"
}

variable "aws_spoke1_region" {
  default = "ca-central-1"
}

variable "aws_spoke1_name" {
  default = "ace-aws-ca-central-1-spoke1"
}

variable "aws_spoke1_cidr" {
  default = "10.1.211.0/24"
}

variable "aws_spoke2_region" {
  default = "ca-central-1"
}

variable "aws_spoke2_name" {
  default = "ace-aws-ca-central-1-spoke2"
}

variable "aws_spoke2_cidr" {
  default = "10.1.212.0/24"
}

variable "aws_test_instance_size" {
  default = "t3.micro"
}

variable "CA_ec2_key_name" {
  default = "ACE"
}

variable "insane" {
  type    = bool
  default = true
}

variable "ha_enabled" {
  type    = bool
  default = false
}