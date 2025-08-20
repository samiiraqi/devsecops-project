variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "devsecops"
}

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.small"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 3
}

variable "s3_bucket_name" {
  type    = string
  default = "devsecops-tf-state"
}

variable "dynamodb_table_name" {
  type    = string
  default = "devsecops-tf-locks"
}
