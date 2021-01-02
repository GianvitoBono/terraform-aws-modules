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
  key_name="SampleKey"
  aws_region="us-east-2"
  env="dev"
  healthcheck_grace_period=300
  asg_desired_capacity=2
  asg_ondemand_percentage=0
  asg_ondemand_base_capacity=2
}
```

## Variables

| Var Name                          | Type         | Description                                                                                                | Default Value        |
|-----------------------------------|--------------|------------------------------------------------------------------------------------------------------------|----------------------|
| app_name                          | string       | Application name and tag, this will be used to name resources                                              | "sample-app"         |
| aws_region                        | string       | AWS Region where all the resources will be created                                                         | "us-east-1"          |
| env                               | string       | Enviroment name (prod, dev, stage, etc..), used for tagging and naming resources                           | "test"               |
| private_subnets_ids               | list(string) | List of private subnets ids where the application shoud run                                                | defaults = []        |
| public_subnets_ids                | list(string) | List of public subnets ids where the load balancer shoud run                                               | []                   |
| vpc_id                            | string       | VPC id where the resources will be deployed                                                                | ""                   |
| ami_name_prefix                   | string       | This will be used as a filter to choose the AMI for the lauch template                                     | "sample-app"         |
| key_name                          | string       | Key name used for the EC2 istances                                                                         | ""                   |
| ec2_user_data                     | string       | EC2 user data to add to the lauch group, default = empty                                                   | ""                   |
| instance_type                     | string       | Default EC2 instance type to be used in the launch_configuration                                           | "t2.micro"           |
| asg_max_size                      | number       | Maximum number of EC2 istance running in the ASG (default 2)                                               | 2                    |
| asg_min_size                      | number       | Minimum number of EC2 istance running in the ASG (default 2)                                               | 1                    |
| healthcheck_grace_period          | number       | Heat check grace period for the ASG, default 300                                                           | 300                  |
| asg_desired_capacity              | number       | Desired capacity for the ASG. default = 1                                                                  | 1                    |
| instance_type_override            | list(string) | List of EC2 instance types to overwrite on launch_configuration                                            | []                   |
| asg_ondemand_percentage           | number       | Percentage of the on-demand capacity for the ASG, default = 20, so 20% on-demand 80% spot                  | 20                   |
| asg_ondemand_base_capacity        | number       | Number of base on-demand EC2, default = 1                                                                  | 1                    |
| asg_spot_allocation_strategy      | string       | ASG spot allocation strategy, this can be lowest-price or capacity-optimized, default = capacity-optimized | "capacity-optimized" |
| lb_port                           | number       | Exposed load balancer port                                                                                 | "80"                 |
| lb_protocol                       | string       | Protocol for the load balancer                                                                             | "HTTP"               |
| asg_target_port                   | number       | Port that expose the service in the target EC2 istances                                                    | "80"                 |
| asg_target_protocol               | string       | Protocol for the load balancer                                                                             | "HTTP"               |
| lb_certificate_arn                | string       | Load balancer HTTPS listner certificate arn                                                                | ""                   |
| lb_enable_http_to_https_redirect  | bool         | If true enable an http listener that redirect the traffic to https                                         | false                |
| lb_heathcheck_enabled             | bool         | Enable or disable healtcheck                                                                               | true                 |
| lb_heathcheck_interval            | number       | Healtcheck interval                                                                                        | 30                   |
| lb_heathcheck_path                | string       | Healtcheck target path                                                                                     | "/"                  |
| lb_heathcheck_healthy_threshold   | number       | Number of passed healthcheck for defining that an istance is healty                                        | 3                    |
| lb_heathcheck_unhealthy_threshold | number       | Number of failed healthcheck for defining that an istance is unhealty                                      | 2                    |
| lb_heathcheck_matcher             | string       | Responces healthcheck has to match to define that the istance is responding correctly                      | "200-399"            |


## Outputs

| Output                       | Description                                                                   |
|------------------------------|-------------------------------------------------------------------------------|
| alb_dns                      | Application Load Balancer DNS name                                            |
| alb_arn                      | Application Load Balancer ARN                                                 |
| istance_sg_id                | ID of the securirty gropus attached to the Auto Scaling Group istances        |
| loadbalancer_sg_id           | ID of the securirty gropus attached to the Application Load Balancer          |
| cloudformation_stack_id      | Stack ID of the CloudFormation stack used for the rolling update feature      |
| cloudformation_stack_outputs | Stack outputs of the CloudFormation stack used for the rolling update feature |
| launch_tamplate_id           | EC2 launch template ID                                                        |
| target_group_arn             | Load Balancer target group ARN                                                |

