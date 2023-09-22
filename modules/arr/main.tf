resource "docker_image" "arr" {
  name = "linuxserver/${var.name}"
}

resource "docker_container" "arr" {
  name    = var.container_name != null ? var.container_name : "${var.name}-server"
  image   = docker_image.arr.image_id
  restart = "unless-stopped"

  env = [
    "PUID=1000",
    "PGID=1000",
    "UMASK_SET=022",
    "TZ=America/Sao_Paulo",
    "AUTO_UPDATE=true",
  ]

  volumes {
    host_path      = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  volumes {
    host_path      = var.config_dir_path != null ? var.config_dir_path : "${var.data_dir_path}/config/${var.name}"
    container_path = "/config"
  }

  volumes {
    host_path      = var.data_dir_path
    container_path = "/data"
  }

  networks_advanced {
    name = var.docker_bridge_network_id
  }
}
