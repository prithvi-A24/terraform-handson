variable "region" {
  type = string
}

variable "instance_group_manager_id" {
  type = string
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

variable "target_cpu" {
  type = number
}