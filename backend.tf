terraform {
  required_version = ">= 1.0.2"
  backend "remote" {
    hostname     = "app.terraform.io"
    # organization = "<replace-with-your-Terraform-Cloud-workspace-and-uncomment>"
    workspaces {
      name = "ace-iac"
    }
  }
}
