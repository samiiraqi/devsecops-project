variable "name" { type = string }

variable "cidr" {
  type        = string
  description = "VPC CIDR (e.g., 10.0.0.0/16)"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "public_subnet_map" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.0.0/24"
    "us-east-1b" = "10.0.1.0/24"
  }
}

variable "private_subnet_map" {
  type = map(string)
  default = {
    "us-east-1a" = "10.0.100.0/24"
    "us-east-1b" = "10.0.101.0/24"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
