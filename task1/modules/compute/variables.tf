variable "machine_type" {
  type = string
}

variable "network" {
  type = string
}

variable "region" {
  type = string
}

variable "initial_size" {
  type = number
}

variable "service_account_email" {
  description = "Service Account attached to MIG instances"
  type        = string
}
