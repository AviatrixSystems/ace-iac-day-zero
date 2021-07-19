##################################################################
# Data source to get AMI details
##################################################################
data "aws_ami" "ubuntu" {
  provider    = aws.canada
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu2" {
  provider    = aws.canada
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "amazon_linux" {
  provider    = aws.canada
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}

locals {
  bu1_bastion_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "BU1-Bastion"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install traceroute unzip build-essential git gcc hping3 apache2 net-tools
sudo apt autoremove
sudo /etc/init.d/ssh restart
sudo echo "<html><h1>Aviatrix is awesome</h1></html>" > /var/www/html/index.html 
EOF
}

locals {
  bu2_app_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "BU2-App"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo /etc/init.d/ssh restart
EOF
}

module "security_group_1" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke1"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_1.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  providers = {
    aws = aws.canada
  }
}

module "security_group_2" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 3.0"
  name                = "security_group_spoke2"
  description         = "Security group for example usage with EC2 instance"
  vpc_id              = module.aws_spoke_2.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  providers = {
    aws = aws.canada
  }
}

module "aws_spoke_bastion" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  instance_type               = var.aws_test_instance_size
  name                        = "${var.aws_spoke1_name}-bastion"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.CA_ec2_key_name
  instance_count              = 1
  subnet_id                   = module.aws_spoke_1.vpc.public_subnets[0].subnet_id
  vpc_security_group_ids      = [module.security_group_1.this_security_group_id]
  associate_public_ip_address = true
  user_data_base64            = base64encode(local.bu1_bastion_user_data)
  providers = {
    aws = aws.canada
  }
}

module "aws_spoke_app" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  instance_type          = var.aws_test_instance_size
  name                   = "${var.aws_spoke2_name}-app"
  ami                    = data.aws_ami.ubuntu.id
  key_name               = var.CA_ec2_key_name
  instance_count         = 1
  # subnet_id              = module.aws_spoke_2.vpc.public_subnets[0].subnet_id
  subnet_id              = module.aws_spoke_2.vpc.private_subnets[0].subnet_id
  vpc_security_group_ids = [module.security_group_2.this_security_group_id]
  # associate_public_ip_address = true
  associate_public_ip_address = false
  user_data_base64            = base64encode(local.bu2_app_user_data)
  providers = {
    aws = aws.canada
  }
}

output "aws_spoke1_bastion_public_ip" {
  value = module.aws_spoke_bastion.public_ip
}

output "aws_spoke1_bastion_private_ip" {
  # value = aws_instance.aws_spoke_1.private_ip
  value = module.aws_spoke_bastion.private_ip
}

output "aws_spoke2_app_private_ip" {
  # value = aws_instance.aws_spoke_2.private_ip
  value = module.aws_spoke_app.private_ip
}