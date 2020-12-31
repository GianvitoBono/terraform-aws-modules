data "aws_ami" "selected" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.ami_name_prefix}*"]
  }
}