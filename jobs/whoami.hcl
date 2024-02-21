job "whoami" {
  region      = "europe"
  datacenters = ["infra"]
  namespace   = "debug"
  group "whoami" {
    count = 3
    network {
      mode = "bridge"
      port "http" { to = 80 }
    }
    service {
      name     = "whoami-http"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.whoami.rule=PathPrefix(`/service/debug/whoami`)",
      ]
    }
    task "whoami" {
      driver = "docker"
      config {
        image = "traefik/whoami:v1.10.1"
        ports = ["http"]
      }
      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}