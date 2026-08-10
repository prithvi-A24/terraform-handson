output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.this.id
}

output "vpc_self_link" {
  description = "The self link of the VPC"
  value       = google_compute_network.this.self_link
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.this.id
}

output "subnet_self_link" {
  description = "The self link of the subnet"
  value       = google_compute_subnetwork.this.self_link
}
