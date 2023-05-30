terraform {
  required_version = ">= 1.2.0"
  backend "remote" {
    hostname = "app.terraform.io"
    # organization = "<replace-with-your-Terraform-Cloud-organization-and-uncomment>"
    workspaces {
      name = "ace-iac-day-zero"
    }
  }
}
