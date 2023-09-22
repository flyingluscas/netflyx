resource "docker_image" "twingate" {
  name = "twingate/connector"
}

resource "docker_container" "twingate" {
  name    = "twingate-connector"
  image   = docker_image.twingate.image_id
  restart = "unless-stopped"
  env = [
    "TWINGATE_NETWORK=${var.twingate_network_name}",
    "TWINGATE_ACCESS_TOKEN=${var.twingate_connector_access_token}",
    "TWINGATE_REFRESH_TOKEN=${var.twingate_connector_refresh_token}",
    "TWINGATE_LABEL_HOSTNAME=server",
    "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt",
    "TWINGATE_API_ENDPOINT=/connector.stock",
    "TWINGATE_LOG_LEVEL=3",
  ]

  networks_advanced {
    name = var.docker_bridge_network_id
  }
}
