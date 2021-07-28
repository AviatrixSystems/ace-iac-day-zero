# ace-iac-day-zero (Lab 1 and Lab 2)

This repository builds out the following infrastructure for the Aviatrix ACE IaC course:

- Aviatrix Transit in AWS with 2 spokes
- Ubuntu VMs with password authentication (1 per spoke)
- Multi-Cloud Segmentation (2 security domains connected by connection policy)
- Spoke 2 GW configured for Single IP SNAT

Component | Version
--- | ---
Aviatrix Controller | UserConnect-6.4.2783 (6.4)
Aviatrix Terraform Provider | > 2.19.5
Terraform | > 1.0.2
AWS Terraform Provider | > 3.0

### Dependencies

- Software version requirements met
- Aviatrix Controller with Access Accounts defined for AWS
- Sufficient AWS EIPs for region in scope
- Account credentials for AWS defined in environment. The following environment variables will be needed:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY

<img src="ACE IaC.png">

