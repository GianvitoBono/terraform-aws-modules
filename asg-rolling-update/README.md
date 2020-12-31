# AWS Rolling Update ASG Module

## Example usage

```hcl
module "asg-rolling-update" {
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

## Variables

| Var Name                     | Type         | Description                                                                                                |
|------------------------------|--------------|------------------------------------------------------------------------------------------------------------|
| app_name                     | string       | Application name and tag, this will be used to name resources                                              |
| ami_name_prefix              | string       | This will be used as a filter to choose the AMI for the lauch template                                     |
| private_subnets_ids          | list(string) | List of private subnets ids where the application shoud run                                                |
| public_subnets_ids           | list(string) | List of public subnets ids where the load balancer shoud run                                               |
| vpc_id                       | string       | VPC id where the resources will be deployed                                                                |
| asg_max_size                 | number       | Maximum number of EC2 istance running in the ASG (default 2)                                               |
| asg_min_size                 | number       | Minimum number of EC2 istance running in the ASG (default 2)                                               |
| key_name                     | string       | Key name used for the EC2 istances                                                                         |
| aws_region                   | string       | AWS Region where all the resources will be created                                                         |
| env                          | string       | Enviroment name (prod, dev, stage) default is prod, used for tags                                          |
| healthcheck_grace_period     | number       | Heat check grace period for the ASG, default 300                                                           |
| asg_desired_capacity         | number       | Desired capacity for the ASG. default = 1                                                                  |
| ec2_user_data                | string       | EC2 user data to add to the lauch group, default = empty                                                   |
| instance_type_override       | list(string) | List of EC2 instance types to overwrite on launch_configuration                                            |
| instance_type                | string       | Default EC2 instance type to be used in the launch_configuration                                           |
| asg_ondemand_percentage      | number       | Percentage of the on-demand capacity for the ASG, default = 20, so 20% on-demand 80% spot                  |
| asg_ondemand_base_capacity   | number       | Number of base on-demand EC2, default = 1                                                                  |
| asg_spot_allocation_strategy | string       | ASG spot allocation strategy, this can be lowest-price or capacity-optimized, default = capacity-optimized |

## Outputs

The only output of this module is alb_dns, that is the DNS of the load balancer that serve the content for the ASG
