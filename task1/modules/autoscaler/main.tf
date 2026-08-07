resource "google_compute_region_autoscaler" "web_autoscaler" {

  name   = "web-autoscaler"
  region = var.region
  target = var.instance_group_manager_id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.target_cpu
    }
  }
}