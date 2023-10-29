resource "docker_image" "homepage" {
  name = "ghcr.io/gethomepage/homepage"
}

resource "docker_container" "homepage" {
  name    = "homepage-server"
  restart = "unless-stopped"
  image   = docker_image.homepage.image_id

  env = [
    "PUID=1000",
    "PGID=1000",
    "UMASK_SET=022",
    "TZ=America/Sao_Paulo",
    "AUTO_UPDATE=true",
  ]

  volumes {
    host_path      = "${var.data_dir_path}/config/homepage"
    container_path = "/app/config"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name = var.docker_bridge_network_id
  }
}

module "proxy" {
  source                   = "../../modules/reverse-proxy"
  container_name           = "fly.server"
  nginx_conf_folder        = var.nginx_conf_folder
  docker_bridge_network_id = var.docker_bridge_network_id

  twingate = {
    remote_network_id = var.twingate_remote_network_id
    public_group_id   = var.twingate_public_group_id
    admin_group_id    = var.twingate_admin_group_id
  }

  proxies = [
    {
      upstream  = "homepage"
      path      = "/"
      host      = docker_container.homepage.name
      host_port = 3000
    },
    {
      upstream  = "radarr"
      path      = "/radarr"
      host      = var.radarr_container_name
      host_port = 7878
    },
    {
      upstream  = "sonarr"
      path      = "/sonarr"
      host      = var.sonarr_container_name
      host_port = 8989
    },
    {
      upstream  = "prowlarr"
      path      = "/prowlarr"
      host      = var.prowlarr_container_name
      host_port = 9696
    },
    {
      upstream  = "bazarr"
      path      = "/bazarr"
      host      = var.bazarr_container_name
      host_port = 6767
    },
    {
      upstream  = "tautulli"
      path      = "/tautulli"
      host      = var.tautulli_container_name
      host_port = 8181
    },
  ]
}
