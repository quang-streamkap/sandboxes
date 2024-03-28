output "runner" {
  value = {}
}

output "vpn" {
  value = {
    name = module.network.vnet_name
    subnet_ids = module.network.vnet_subnets
  }
}