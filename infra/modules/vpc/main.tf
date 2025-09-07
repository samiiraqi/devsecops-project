data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name    = "${var.name}-vpc"
    
  })
}

# Public subnets
resource "aws_subnet" "public" {
  for_each          = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, 8, index(local.azs, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name    = "${var.name}-public-${each.key}"
    
  })
}

# Private subnets (no NAT; no internet egress)
resource "aws_subnet" "private" {
  for_each          = toset(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, 8, 100 + index(local.azs, each.key))
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name    = "${var.name}-private-${each.key}"
    
  })
}

# One IGW for the VPC (no NAT anywhere)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name    = "${var.name}-igw"
    
  })
}

# One public route table per AZ, default route to IGW
resource "aws_route_table" "public" {
  for_each = aws_subnet.public
  vpc_id   = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name    = "${var.name}-public-rt-${each.key}"
   
  })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[each.key].id
}
