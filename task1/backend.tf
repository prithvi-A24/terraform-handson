terraform {
  backend "gcs" {
    bucket = "terraform-001-490014-tfstate-demo"
    prefix = "terraform/state"
  }
}