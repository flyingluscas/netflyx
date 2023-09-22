locals {
  nginx_conf_file_path = "${var.nginx_conf_folder}/${var.container_name}.conf"
}

resource "docker_image" "nginx" {
  name = "nginx:alpine-slim"
}

resource "local_file" "nginx_conf" {
  content         = templatefile("${path.module}/nginx.conf.tftpl", { proxies = var.proxies })
  filename        = local.nginx_conf_file_path
  file_permission = "0644"
}

resource "docker_container" "proxy" {
  name    = var.container_name
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  volumes {
    host_path      = local.nginx_conf_file_path
    container_path = "/etc/nginx/conf.d/default.conf"
  }

  networks_advanced {
    name = var.docker_bridge_network_id
  }

  dynamic "networks_advanced" {
    for_each = var.docker_macvlan_network != null ? toset([1]) : toset([])

    content {
      name         = var.docker_macvlan_network.id
      ipv4_address = var.docker_macvlan_network.ipv4
    }
  }

  depends_on = [
    local_file.nginx_conf
  ]
}

module "twingate_resource" {
  count             = var.twingate != null ? 1 : 0
  source            = "../twingate-resource"
  name              = var.container_name
  address           = var.container_name
  remote_network_id = var.twingate.remote_network_id
  public_group_id   = var.twingate.public_group_id
  admin_group_id    = var.twingate.admin_group_id
  web               = true
  ssh               = false
  admin_only        = false
}
