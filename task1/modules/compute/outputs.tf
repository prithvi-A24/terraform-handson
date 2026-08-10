output "instance_group" {
  value = google_compute_region_instance_group_manager.web_mig.instance_group
}

output "instance_group_manager_id" {
  value = google_compute_region_instance_group_manager.web_mig.id
}

output "instance_template" {
  value = google_compute_instance_template.web_template.self_link
}