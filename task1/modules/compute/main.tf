resource "google_compute_instance_template" "web_template" {

  name_prefix  = "nginx-template-"
  machine_type = var.machine_type

  tags = ["http-server"]

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = var.network

    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  service_account {
    email  = var.service_account_email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


resource "google_compute_region_instance_group_manager" "web_mig" {

  name               = "instance-group-1"
  region             = var.region
  base_instance_name = "web"

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  target_size = var.initial_size

  named_port {
    name = "http"
    port = 80
  }

  lifecycle {
    ignore_changes = [
      target_size
    ]
  }
}