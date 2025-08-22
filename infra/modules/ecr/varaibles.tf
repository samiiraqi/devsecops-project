variable "repository_name" {
  type = string
}

variable "create_kms_key" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
