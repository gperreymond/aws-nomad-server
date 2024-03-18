job "whoami" {
  group "whoami" {
    count = 1
    network {
      port "http" {
        to = 80
      }
    }
    task "whoami" {
      driver = "docker"
      config {
        image          = "traefik/whoami:v1.10.1"
        ports          = ["http"]
        auth_soft_fail = true
        network_mode   = "bridge"
      }
      service {
        name     = "whoami-http"
        provider = "nomad"
        port     = "http"
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
