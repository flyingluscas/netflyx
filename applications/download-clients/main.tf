locals {
  services = toset([
    "tv",
    "movies",
  ])
}

module "service" {
  source                   = "../../modules/arr"
  for_each                 = local.services
  name                     = "transmission"
  config_dir_path          = "${var.data_dir_path}/config/transmission/${each.key}"
  container_name           = "transmission-${each.key}-server"
  data_dir_path            = var.data_dir_path
  docker_bridge_network_id = var.docker_bridge_network_id

  providers = {
    docker = docker
  }
}
