terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # Leave version open; your lockfile will pin (v6 is OK)
    }
  }
}
