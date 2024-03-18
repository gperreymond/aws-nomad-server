job "flannel-network" {
  type = "system"
  group "flannel" {
    task "flanneld" {
      driver = "docker"
      config {
        image = "docker.io/flannel/flannel:v0.24.3"
        args = [
          "-iface=${NODE_IP}",
          "-etcd-endpoints=${ETCD_ENDPOINTS}"
        ]
        auth_soft_fail = true
        privileged     = true
        network_mode   = "host"
      }
      resources {
        cpu    = 500
        memory = 256
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
