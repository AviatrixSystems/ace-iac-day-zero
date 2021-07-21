// ACE-ops Core Aviatrix Infrastructure

# Private Key creation
resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "aws_canada_key" {
  provider   = aws.canada
  key_name   = var.CA_ec2_key_name
  public_key = tls_private_key.avtx_key.public_key_openssh
}

# AWS Transit Modules
module "aws_transit_1" {
  source              = "terraform-aviatrix-modules/aws-transit/aviatrix"
  version             = "4.0.1"
  account             = var.aws_account_name
  region              = var.aws_transit1_region
  name                = var.aws_transit1_name
  cidr                = var.aws_transit1_cidr
  ha_gw               = var.ha_enabled
  prefix              = var.prefix
  suffix              = var.suffix
  insane_mode         = false
  instance_size       = var.aws_transit_instance_size
  enable_segmentation = true
}

# AWS Spoke Modules
module "aws_spoke_1" {
  source          = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version         = "4.0.1"
  account         = var.aws_account_name
  region          = var.aws_spoke1_region
  name            = var.aws_spoke1_name
  cidr            = var.aws_spoke1_cidr
  ha_gw           = var.ha_enabled
  prefix          = var.prefix
  suffix          = var.suffix
  security_domain = aviatrix_segmentation_security_domain.BU1.domain_name
  transit_gw      = module.aws_transit_1.transit_gateway.gw_name
}

module "aws_spoke_2" {
  source          = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version         = "4.0.1"
  account         = var.aws_account_name
  region          = var.aws_spoke2_region
  name            = var.aws_spoke2_name
  cidr            = var.aws_spoke2_cidr
  ha_gw           = var.ha_enabled
  prefix          = var.prefix
  suffix          = var.suffix
  security_domain = aviatrix_segmentation_security_domain.BU2.domain_name
  transit_gw      = module.aws_transit_1.transit_gateway.gw_name
  single_ip_snat  = true
}


resource "aviatrix_fqdn" "fqdn_filter" {
  fqdn_tag     = "APP-RULES"
  fqdn_mode    = "white"
  fqdn_enabled = true
  gw_filter_tag_list {
    gw_name = module.aws_spoke_2.spoke_gateway.gw_name
  }

  manage_domain_names = false
}

resource "aviatrix_fqdn_tag_rule" "tcp" {
  for_each      = local.egress_rules.tcp
  fqdn_tag_name = aviatrix_fqdn.fqdn_filter.fqdn_tag
  fqdn          = each.key
  protocol      = "tcp"
  port          = each.value
  depends_on    = [aviatrix_fqdn.fqdn_filter]
}

resource "aviatrix_fqdn_tag_rule" "udp" {
  for_each      = local.egress_rules.udp
  fqdn_tag_name = aviatrix_fqdn.fqdn_filter.fqdn_tag
  fqdn          = each.key
  protocol      = "udp"
  port          = each.value
  depends_on    = [aviatrix_fqdn.fqdn_filter]
}


# Multi-Cloud Segmentation
resource "aviatrix_segmentation_security_domain" "BU1" {
  domain_name = "BU1"
  depends_on = [
    module.aws_transit_1
  ]
}
resource "aviatrix_segmentation_security_domain" "BU2" {
  domain_name = "BU2"
  depends_on = [
    module.aws_transit_1
  ]
}
resource "aviatrix_segmentation_security_domain_connection_policy" "BU1_BU2" {
  domain_name_1 = "BU1"
  domain_name_2 = "BU2"
  depends_on    = [aviatrix_segmentation_security_domain.BU1, aviatrix_segmentation_security_domain.BU2]
}
