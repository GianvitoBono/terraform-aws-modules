locals {
  public_subnets  = { for subnet in var.subnets : subnet.tf_res_id => subnet if subnet.is_private == false }
  private_subnets = { for subnet in var.subnets : subnet.tf_res_id => subnet if subnet.is_private == true }
}


resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    "Name" = "${var.app_name}-${var.env}-vpc"
    "Env"  = var.env
    "App"  = var.app_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.app_name}-${var.env}-igw"
    "Env"  = var.env
    "App"  = var.app_name
  }
}

resource "aws_subnet" "private_subnet" {
  for_each                = { for subnet in local.private_subnets : subnet.tf_res_id => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.all.names[index(keys(local.private_subnets), each.key) % 3]

  tags = {
    "Name" = each.value.name
    "App"  = var.app_name
    "Env"  = var.env
  }
}

resource "aws_subnet" "public_subnet" {
  for_each                = { for subnet in local.public_subnets : subnet.tf_res_id => subnet }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.auto_assing_pip
  availability_zone = data.aws_availability_zones.all.names[index(keys(local.private_subnets), each.key) % 3]

  tags = {
    "Name" = each.value.name
    "App"  = var.app_name
    "Env"  = var.env
  }
}

resource "aws_eip" "nat-gateway-eip" {
  count = var.multi_az_nat ? length(local.public_subnets) : 1
  vpc   = true

  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "${var.app_name}-${var.env}-nat-gw-${count.index + 1}-eip"
    "App"  = var.app_name
    "Env"  = var.env
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count         = var.multi_az_nat ? 2 : 1
  allocation_id = element(aws_eip.nat-gateway-eip, count.index).id
  subnet_id     = aws_subnet.public_subnet[keys(aws_subnet.public_subnet)[count.index]].id

  tags = {
    "Name" = "${var.app_name}-${var.env}-nat-gw-${count.index + 1}"
    "App"  = var.app_name
    "Env"  = var.env
  }
}

resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "${var.app_name}-${var.env}-pub-rt"
    "App"  = var.app_name
    "Env"  = var.env
  }
}

resource "aws_route_table" "priv-route-table" {
  vpc_id = aws_vpc.main.id
  count = var.multi_az_nat ? 2 : 1

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[count.index].id
  }

  tags = {
    "Name" = "${var.app_name}-${var.env}-${count.index + 1}-priv-rt"
    "App"  = var.app_name
    "Env"  = var.env
  }

  depends_on = [ aws_nat_gateway.nat-gw ]
}

resource "aws_route_table_association" "pub-rt-assoc" {
  for_each = aws_subnet.public_subnet
  subnet_id = each.value.id
  route_table_id = aws_route_table.pub-route-table.id
}

resource "aws_route_table_association" "priv-rt-assoc" {
  count = length(local.private_subnets)
  subnet_id = aws_subnet.private_subnet[keys(aws_subnet.private_subnet)[count.index]].id
  route_table_id = length(aws_route_table.priv-route-table) > 1 ? aws_route_table.priv-route-table[count.index % 2].id : aws_route_table.priv-route-table[0].id
}

data "aws_availability_zones" "all" {}