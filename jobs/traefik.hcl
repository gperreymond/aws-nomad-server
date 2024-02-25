job "traefik" {
  type        = "system"
  group "traefik" {
    count = 1
    network {
      mode = "host"
      port "http" { static = 80 }
    }
    service {
      name     = "traefik-http"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik-dashboard.rule=PathPrefix(`/api`, `/dashboard`)",
        "traefik.http.routers.traefik-dashboard.service=api@internal"
      ]
    }
    task "traefik" {
      driver = "docker"
      config {
        image = "traefik:v2.11.0"
        ports = ["http"]
        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
        ]
      }
      template {
        data        = <<EOF
entrypoints:
  web:
    address: ':80'
api:
  dashboard: true
  insecure: true
log:
  level: 'DEBUG'
providers:
  nomad:
    exposedByDefault: false
    namespaces:
    - 'default'
    - 'debug'
    endpoint:
      address: 'http://192.168.1.103:4646'
EOF
        destination = "local/traefik.yaml"
      }
      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}