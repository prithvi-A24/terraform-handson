resource "google_secret_manager_secret" "app_secret" {
  secret_id = var.secret_name

  replication {
    auto {}
  }
}


