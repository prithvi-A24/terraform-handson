module "vpc" {
  source = "./modules/vpc"

  name        = var.vpc_name
  project_id  = var.project_id
  subnet_name = var.subnet_name
  subnet_cidr = var.subnet_cidr
  region      = var.region
}

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = module.vpc.subnet_self_link

    access_config {
    }
  }
}