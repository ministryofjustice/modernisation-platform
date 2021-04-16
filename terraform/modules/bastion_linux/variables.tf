##Main
variable "region" {
  type        = string
  description = ""
}

variable "app_name" {
  type        = string
  description = "Name of application"
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-.]{1,61}[A-Za-z0-9]$", var.app_name))
    error_message = "Invalid name for application supplied in variable app_name."
  }
}

variable "business_unit" {
  type        = string
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}

variable "subnet_set" {
  type        = string
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}

variable "environment" {
  type        = string
  description = "application environment"
}

##Bastion
variable "public_key_data" {
  description = "User public keys for specific environment"
}

variable "extra_user_data_content" {
  default     = ""
  description = "Extra user data content for Bastion ec2"
}

variable "allow_ssh_commands" {
  type        = bool
  description = "Allow SSH commands to be specified"
  validation {
    condition     = (var.allow_ssh_commands == true || var.allow_ssh_commands == false)
    error_message = "Variable allow_ssh_commands must be boolean."
  }
}

## S3
variable "bucket_name" {
  type        = string
  description = "Bucket used for bucket log storage and user public keys"
  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9-.]{1,61}[A-Za-z0-9]$", var.bucket_name))
    error_message = "The S3 bucket name is not valid in variable bucket_name."
  }
}

variable "bucket_versioning" {
  type        = bool
  description = "Enable bucket versioning or not"
  validation {
    condition     = (var.bucket_versioning == true || var.bucket_versioning == false)
    error_message = "Variable bucket_versioning must be boolean."
  }
}

variable "bucket_force_destroy" {
  type        = bool
  description = "The bucket and all objects should be destroyed when using true"
  validation {
    condition     = (var.bucket_force_destroy == true || var.bucket_force_destroy == false)
    error_message = "Variable bucket_force_destroy must be boolean."
  }
}

#### Logs
variable "log_auto_clean" {
  type        = bool
  description = "Enable or not the lifecycle"
  validation {
    condition     = (var.log_auto_clean == true || var.log_auto_clean == false)
    error_message = "Variable log_auto_clean must be boolean."
  }
}

variable "log_standard_ia_days" {
  type        = number
  description = "Number of days before moving logs to IA Storage"
}

variable "log_glacier_days" {
  type        = number
  description = "Number of days before moving logs to Glacier"
}

variable "log_expiry_days" {
  type        = number
  description = "Number of days before logs expiration"
}

## Tags / Prefix
variable "tags_common" {
  description = "MOJ required tags"
  type        = map(string)
}

variable "tags_prefix" {
  description = "prefix for name tags"
  type        = string
}
