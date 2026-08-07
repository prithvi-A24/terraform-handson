resource "google_compute_firewall" "allow_http" {

  name    = "allow-http-terraform"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["http-server"]
}