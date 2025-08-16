variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_bits" {
  type    = number
  default = 8
}

variable "private_bits" {
  type    = number
  default = 8
}