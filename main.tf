module "docker_networks" {
  source               = "./resources/docker-networks"
  bridge_network_name  = "twingate"
  macvlan_network_name = "physical"
}

module "twingate_network" {
  source              = "./resources/twingate-network"
  remote_network_name = "home"
}

module "twingate_admin_group" {
  source        = "./resources/twingate-admin-group"
  admin_user_id = var.twingate_admin_user_id
}

module "twingate_connector" {
  source                           = "./applications/twingate-connector"
  docker_bridge_network_id         = module.docker_networks.bridge_network_id
  twingate_network_name            = var.twingate_network_name
  twingate_connector_access_token  = module.twingate_network.connector_access_token
  twingate_connector_refresh_token = module.twingate_network.connector_refresh_token
}

module "arrs" {
  source                   = "./applications/arrs"
  docker_bridge_network_id = module.docker_networks.bridge_network_id
  data_dir_path            = var.data_dir_path

  providers = {
    docker = docker
  }
}

module "download_clients" {
  source                   = "./applications/download-clients"
  docker_bridge_network_id = module.docker_networks.bridge_network_id
  data_dir_path            = var.data_dir_path

  providers = {
    docker = docker
  }
}

module "overseerr_proxy" {
  source                     = "./applications/overseerr-proxy"
  docker_bridge_network_id   = module.docker_networks.bridge_network_id
  nginx_conf_folder          = var.nginx_conf_folder
  overseerr_container_name   = module.arrs.services.overseerr.container_name
  twingate_remote_network_id = module.twingate_network.remote_network_id
  twingate_admin_group_id    = module.twingate_admin_group.admin_group_id
  twingate_public_group_id   = var.twingate_public_group_id
}

module "transmission_proxies" {
  source                     = "./applications/transmission-proxies"
  docker_bridge_network_id   = module.docker_networks.bridge_network_id
  nginx_conf_folder          = var.nginx_conf_folder
  movies_container_name      = module.download_clients.services.movies.container_name
  tv_container_name          = module.download_clients.services.tv.container_name
  twingate_remote_network_id = module.twingate_network.remote_network_id
  twingate_admin_group_id    = module.twingate_admin_group.admin_group_id
  twingate_public_group_id   = var.twingate_public_group_id
}

module "homepage" {
  source                     = "./applications/homepage"
  docker_bridge_network_id   = module.docker_networks.bridge_network_id
  nginx_conf_folder          = var.nginx_conf_folder
  data_dir_path              = var.data_dir_path
  radarr_container_name      = module.arrs.services.radarr.container_name
  sonarr_container_name      = module.arrs.services.sonarr.container_name
  prowlarr_container_name    = module.arrs.services.prowlarr.container_name
  bazarr_container_name      = module.arrs.services.bazarr.container_name
  tautulli_container_name    = module.arrs.services.tautulli.container_name
  twingate_remote_network_id = module.twingate_network.remote_network_id
  twingate_admin_group_id    = module.twingate_admin_group.admin_group_id
  twingate_public_group_id   = var.twingate_public_group_id
}

module "plex" {
  source                     = "./applications/plex"
  docker_bridge_network_id   = module.docker_networks.bridge_network_id
  docker_macvlan_network_id  = module.docker_networks.macvlan_network_id
  data_dir_path              = var.data_dir_path
  nginx_conf_folder          = var.nginx_conf_folder
  plex_claim_token           = var.plex_claim_token
  twingate_remote_network_id = module.twingate_network.remote_network_id
  twingate_admin_group_id    = module.twingate_admin_group.admin_group_id
  twingate_public_group_id   = var.twingate_public_group_id
}

module "arthur" {
  source            = "./modules/twingate-resource"
  name              = "arthur"
  address           = "192.168.0.151"
  alias             = "arthur.local"
  remote_network_id = module.twingate_network.remote_network_id
  public_group_id   = var.twingate_public_group_id
  admin_group_id    = module.twingate_admin_group.admin_group_id
  admin_only        = true
  web               = false
  ssh               = true
}
