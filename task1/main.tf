module "network" {
  source = "./modules/network"

  network = var.network
}

module "compute" {
  source = "./modules/compute"

  machine_type = var.machine_type
  network      = var.network
  region       = var.region
  initial_size = var.initial_size
 service_account_email = module.iam.service_account_email


}

module "autoscaler" {
  source = "./modules/autoscaler"

  region                    = var.region
  min_replicas              = var.min_replicas
  max_replicas              = var.max_replicas
  target_cpu                = var.target_cpu
  instance_group_manager_id = module.compute.instance_group_manager_id
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  instance_group = module.compute.instance_group
}


module "cloudstorage" {
  source = "./modules/cloudstorage"

  bucket_name = "${var.project_id}-app-storage"
  location    = "US"
}
module "secretmanager" {
  source = "./modules/secretmanager"

  secret_name = "app-password"
}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
}