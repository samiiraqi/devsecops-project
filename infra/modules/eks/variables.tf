variable "name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "vpc_id" {
  type = string
}

variable "cluster_subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "min_size" {
  type    = number
  default = 2
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}
