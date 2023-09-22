terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }

    twingate = {
      source  = "Twingate/twingate"
      version = "1.2.2-rc1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "twingate" {
  api_token = var.twingate_api_key
  network   = var.twingate_network_name
}
