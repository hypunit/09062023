# AWS Region
variable "region" {
    type = string
    default = "ap-south-1"
}

#AWS Key
variable "access_key" {
    type = string
}

#AWS Secret
variable "secret_key" {
    type = string
}

# table-name is for dynamodb table
variable "table-name" {
  type        = string
  default     = "short-url"
  description = "Table Name you want to use for dynamoDB"
}

# environment is to specify stage of app
variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment, e.g. 'prod', 'staging', 'dev'"
}
