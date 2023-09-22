locals {
  services = toset([
    "sonarr",
    "radarr",
    "overseerr",
    "prowlarr",
    "bazarr",
    "tautulli",
  ])
}

module "service" {
  source                   = "../../modules/arr"
  for_each                 = local.services
  name                     = each.key
  data_dir_path            = var.data_dir_path
  docker_bridge_network_id = var.docker_bridge_network_id

  providers = {
    docker = docker
  }
}
