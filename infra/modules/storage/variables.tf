variable "bucket_name" {
  description = "Exact S3 bucket name to create"
  type        = string
}

variable "create_kms" {
  description = "NOT used. SSE-S3 (AES256) only."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow destroying non-empty bucket"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
