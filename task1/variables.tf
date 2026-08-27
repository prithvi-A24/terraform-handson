variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Deployment zone"
  type        = string
  default     = "us-east1"
}

variable "machine_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-micro"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "min_replicas" {
  description = "Minimum number of VM instances"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of VM instances"
  type        = number
  default     = 4
}

variable "target_cpu" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 0.30
}

variable "initial_size" {
  description = "Initial size of the Managed Instance Group"
  type        = number
  default     = 2
}