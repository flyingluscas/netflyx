resource "docker_image" "plex" {
  name = "plexinc/pms-docker"
}

resource "docker_container" "plex" {
  name    = "plex-server"
  restart = "unless-stopped"
  image   = docker_image.plex.image_id

  env = [
    "PUID=1000",
    "PGID=1000",
    "UMASK_SET=022",
    "TZ=America/Sao_Paulo",
    "AUTO_UPDATE=true",
    "PLEX_CLAIM=${var.plex_claim_token}"
  ]

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
  }

  volumes {
    host_path      = "${var.data_dir_path}/config/plex"
    container_path = "/config"
  }

  volumes {
    host_path      = "${var.data_dir_path}/media"
    container_path = "/data/media"
  }

  networks_advanced {
    name = var.docker_bridge_network_id
  }
}

module "proxy" {
  source                   = "../../modules/reverse-proxy"
  container_name           = "plex"
  nginx_conf_folder        = var.nginx_conf_folder
  docker_bridge_network_id = var.docker_bridge_network_id

  twingate = {
    remote_network_id = var.twingate_remote_network_id
    public_group_id   = var.twingate_public_group_id
    admin_group_id    = var.twingate_admin_group_id
  }

  docker_macvlan_network = {
    id   = var.docker_macvlan_network_id
    ipv4 = "192.168.0.99"
  }

  proxies = [
    {
      upstream  = "plex"
      path      = "/"
      host      = docker_container.plex.name
      host_port = 32400
    },
  ]
}
