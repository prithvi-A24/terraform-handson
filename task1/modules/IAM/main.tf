resource "google_service_account" "mig_vm" {
  account_id   = "mig-vm-sa"
  display_name = "MIG VM Service Account"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.mig_vm.email}"
}