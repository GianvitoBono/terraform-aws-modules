# AWS VPC Module

## Usage example:

```

module "vpc" {
  source = "github.com/GianvitoBono/terraform-aws-modules//vpc?ref=v1.0.0"

  # Name of the application this is needed to name all the resources
  app_name = "test_app"

  # CIDR block for the VPC creation
  cidr_block = "10.100.0.0/16"

  # Description of all the needed subnets
  subnets = [{
      "cidr": "10.100.11.0/24"    # CIDR of the subnet
      "is_private": false         # If true will create a private subnet behind a NAT Gateway
      "name": "Public Subnet 1"   # Name of the subnet (you will see in the AWS console)
      "auto_assing_pip": true     # Decide if the resources launced in this subnet will have the possibiliti to attach a random public IP on startup (default false)
      "tf_res_id": "pub-sub-1"    # Unique ID for the subnet, this will be used only from terraform to bind with the AWS subnet ID when created (dont modify after creation, this will delete the subnet)
  }
  {
      "cidr": "10.100.21.0/24"
      "is_private": true
      "name": "Private Subnet 1"
      "auto_assing_pip": false
      "tf_res_id": "priv-sub-1"
  }]

  env = "dev"                     # Application enviroment, thi will be used in the tags of all the taggable resources
  multi_az_nat = false            # Set this to true to have a redundant NAT Gateway (default false)
}
```