terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.36.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    jinja = {
      source  = "NikolaLohinski/jinja"
      version = "1.17.0"
    }
  }
}