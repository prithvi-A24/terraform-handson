output "load_balancer_ip" {
  value = module.loadbalancer.load_balancer_ip
}

output "instance_group_name" {
  value = module.compute.instance_group
}

output "storage_bucket" {
  value = module.cloudstorage.bucket_name
}