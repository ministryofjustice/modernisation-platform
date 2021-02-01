##Main
variable "region" {
  type        = string
  description = ""
}

variable "business_unit" {
  type        = string
  description = "Fixed variable to specify business-unit for RAM shared subnets"
}

variable "subnet_set" {
  type        = string
  description = "Fixed variable to specify subnet-set for RAM shared subnets"
}

variable "account_name" {
  type        = string
  description = "account name without environment name excluded - can be used to extract environment from workspace name"
}

##Bastion
variable "bastion_host_key_pair" {
  default     = ""
  description = "Select the key pair to use to launch the bastion host"
}

variable "extra_user_data_content" {
  default     = ""
  description = "Extra user data content for Bastion ec2"
}

variable "allow_ssh_commands" {
  type        = bool
  default     = true
  description = "Extra user data content for Bastion ec2"
}

## S3
variable "bucket_name" {
  default     = "bastion"
  description = "Bucket name were the bastion will store the logs"
}

variable "bucket_versioning" {
  default     = true
  description = "Enable bucket versioning or not"
}

variable "bucket_force_destroy" {
  default     = true
  description = "The bucket and all objects should be destroyed when using true"
}

#### Logs
variable "log_auto_clean" {
  description = "Enable or not the lifecycle"
  default     = true
}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
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
