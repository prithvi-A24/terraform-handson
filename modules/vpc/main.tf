resource "google_compute_network" "this" {
  name                    = var.name
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  project                 = var.project_id
}

resource "google_compute_subnetwork" "this" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
  project       = var.project_id
}
