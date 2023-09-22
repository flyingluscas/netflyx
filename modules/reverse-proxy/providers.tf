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
