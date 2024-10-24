terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "3.1.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
  required_version = "1.5.7"
}
