locals {
  service = "overseerr"
}

module "proxy" {
  source                   = "../../modules/reverse-proxy"
  container_name           = local.service
  nginx_conf_folder        = var.nginx_conf_folder
  docker_bridge_network_id = var.docker_bridge_network_id

  twingate = {
    remote_network_id = var.twingate_remote_network_id
    public_group_id   = var.twingate_public_group_id
    admin_group_id    = var.twingate_admin_group_id
  }

  proxies = [
    {
      upstream  = local.service
      path      = "/"
      host      = var.overseerr_container_name
      host_port = 5055
    }
  ]
}
