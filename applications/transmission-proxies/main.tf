module "movies_proxy" {
  source                   = "../../modules/reverse-proxy"
  container_name           = "transmission.movies"
  nginx_conf_folder        = var.nginx_conf_folder
  docker_bridge_network_id = var.docker_bridge_network_id

  twingate = {
    remote_network_id = var.twingate_remote_network_id
    public_group_id   = var.twingate_public_group_id
    admin_group_id    = var.twingate_admin_group_id
  }

  proxies = [
    {
      upstream = "transmission_movies"
      path     = "/"
      host     = var.movies_container_name
      port     = 9091
    }
  ]
}

module "tv_proxy" {
  source                   = "../../modules/reverse-proxy"
  container_name           = "transmission.tv"
  nginx_conf_folder        = var.nginx_conf_folder
  docker_bridge_network_id = var.docker_bridge_network_id

  twingate = {
    remote_network_id = var.twingate_remote_network_id
    public_group_id   = var.twingate_public_group_id
    admin_group_id    = var.twingate_admin_group_id
  }

  proxies = [
    {
      upstream = "transmission_tv"
      path     = "/"
      host     = var.tv_container_name
      port     = 9091
    }
  ]
}
