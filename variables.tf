variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "terraform-001-490014"
}

variable "region" {
  description = "The GCP region for the subnet"
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "demo-vpc"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "demo-subnet"
}

variable "subnet_cidr" {
  description = "The CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "demo-vm"
}

variable "vm_machine_type" {
  description = "The machine type for the VM"
  type        = string
  default     = "e2-micro"
}

variable "zone" {
  description = "The zone where the VM will be created"
  type        = string
  default     = "us-central1-a"
}
