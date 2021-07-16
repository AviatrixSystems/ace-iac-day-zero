terraform {
  required_version = ">= 1.0.2"
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hoodbu"
    workspaces {
      name = "ace-iac"
    }
  }
}
