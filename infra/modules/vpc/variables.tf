variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2

  validation {
    condition     = var.az_count > 0 && var.az_count <= 6
    error_message = "az_count must be between 1 and 6."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
