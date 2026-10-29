# Find the existing Cloud Platform VPC
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Find the private subnets in that VPC
data "aws_subnets" "this" {
  filter {
    name   = "tag:SubnetType"
    values = ["Private"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

# Get details for each private subnet
data "aws_subnet" "this" {
  for_each = toset(data.aws_subnets.this.ids)
  id       = each.value
}