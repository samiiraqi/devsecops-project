module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs

  public_subnets = [
    for i, _ in var.azs : cidrsubnet(var.vpc_cidr, var.public_bits, i)
  ]

  private_subnets = [
    for i, _ in var.azs : cidrsubnet(var.vpc_cidr, var.private_bits, i + 10)
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/elb"            = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }
}