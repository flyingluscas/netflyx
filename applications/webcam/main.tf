resource "docker_image" "mediamtx" {
  name = "bluenviron/mediamtx:latest-ffmpeg"
}

resource "docker_container" "webcam" {
  name    = "webcam"
  image   = docker_image.mediamtx.image_id
  restart = "unless-stopped"

  env = [
    "MTX_PROTOCOLS=tcp",
    "MTX_PATHS_CAM_RUNONINIT=ffmpeg -f v4l2 -r 30 -i /dev/video0 -pix_fmt yuv420p -preset ultrafast -b:v 800000 -f rtsp rtsp://localhost:$RTSP_PORT/$MTX_PATH",
    "MTX_PATHS_CAM_RUNONINITRESTART=yes",
    "MTX_PATHS_CAM_RUNONDEMANDRESTART=yes",
  ]

  devices {
    host_path      = "/dev/media0"
    container_path = "/dev/media0"
  }

  devices {
    host_path      = "/dev/video0"
    container_path = "/dev/video0"
  }

  devices {
    host_path      = "/dev/video1"
    container_path = "/dev/video1"
  }

  networks_advanced {
    name = var.docker_bridge_network_id
  }
}

module "twingate_resource" {
  source            = "../../modules/twingate-resource"
  name              = "webcam"
  address           = docker_container.webcam.name
  remote_network_id = var.twingate_remote_network_id
  public_group_id   = var.twingate_public_group_id
  admin_group_id    = var.twingate_admin_group_id
  web               = true
  web_ports         = [8554]
  ssh               = false
  admin_only        = true
}
