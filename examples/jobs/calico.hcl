job "calico-network" {
  type = "system"
  group "calico-node" {
    task "calico-node" {
      driver = "docker"
      config {
        image = "calico/node:v3.27.2"
        args = [
          "-felix"
        ]
        auth_soft_fail = true
        privileged     = true
        network_mode   = "host"
        volumes = [
          "/var/log/calico:/var/log/calico",
          "/var/lib/calico:/var/lib/calico",
          "/var/run/calico:/var/run/calico",
          "/run/docker/plugins:/run/docker/plugins",
          "/lib/modules:/lib/modules"
        ]
      }
      resources {
        cpu    = 100
        memory = 64
      }
      template {
        destination = "local/env.conf"
        env         = true
        change_mode = "restart"
        data        = <<EOF
NODE_IP="{{env "attr.unique.platform.aws.local-ipv4"}}"
ETCD_ENDPOINTS=http://{{env "attr.unique.platform.aws.local-ipv4"}}:2379
EOF
      }
    }
  }
}
