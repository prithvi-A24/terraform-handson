resource "google_compute_health_check" "http_health_check" {

  name = "http-basic-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "backend_service" {

  name                  = "lb-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"

  health_checks = [
    google_compute_health_check.http_health_check.id
  ]

  backend {
    group = var.instance_group
  }
}

resource "google_compute_url_map" "url_map" {

  name            = "lb-url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {

  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_address" "lb_ip" {

  name = "lb-ip-address"
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {

  name        = "http-forwarding-rule"
  ip_protocol = "TCP"
  port_range  = "80"

  target     = google_compute_target_http_proxy.http_proxy.id
  ip_address = google_compute_global_address.lb_ip.address
}