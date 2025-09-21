variable "role_name" { 
  type = string
   }

variable "subjects" {
  type = list(string)
}

variable "ecr_repo_arn" { type = string }

variable "allow_ecr_actions" {
  type = list(string)
}

variable "allow_eks_actions" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
