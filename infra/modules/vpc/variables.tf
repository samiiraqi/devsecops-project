variable "name" {
  description = "Base name for resources"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "az_count" {
  description = "Number of AZs to use (1-3 typical)"
  type        = number
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
