# AWS Rolling Update ASG Module

# Example usage

```
module "vpc" {
  source = "github.com/GianvitoBono/terraform-aws-modules//asg-rolling-update?ref=v1.0.0"

  app_name= "test-app"
  ami_name_prefix= "packer-example"

  private_subnets_ids=["subnet-0d342b8a863as5e87","subnet-0c89edf5c65a4b579"]
  public_subnets_ids=["subnet-0d342b8a863ac2e66","subnet-0c792df586524b795"]
  vpc_id="vpc-01d4f75ac601f9c42"
  asg_max_size=2
  asg_min_size=2
  key_name="TestTerraform"
  aws_region="us-east-2"
  env="dev"
  healthcheck_grace_period=300
  asg_desired_capacity=2
  ec2_user_data=""
  asg_ondemand_percentage=0
  asg_ondemand_base_capacity=2
}
```