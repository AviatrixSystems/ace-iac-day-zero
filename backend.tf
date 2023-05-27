terraform {
  required_version = ">= 1.4.6"
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "aldrinAviatrix"
    workspaces {
      name = "ace-iac-day-zero"
    }
  }
}
