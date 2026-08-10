variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "routing_mode" {
  description = "Routing mode for the VPC"
  type        = string
  default     = "REGIONAL"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "region" {
  description = "Region where the subnet will be created"
  type        = string
}
