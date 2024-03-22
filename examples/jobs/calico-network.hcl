job "calico-network" {
  type = "system"
  group "calico-node" {
    task "calico-node" {
      driver = "docker"
      config {
        image          = "calico/node:v3.27.2"
        auth_soft_fail = true
        privileged     = true
        network_mode   = "host"
        volumes = [
          "/var/log/calico:/var/log/calico",
          "/var/lib/calico:/var/lib/calico",
          "/var/run/calico:/var/run/calico",
          "/lib/modules:/lib/modules",
          "/run:/run"
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
NODENAME="{{ env "attr.unique.hostname" }}"
IP="{{ env "attr.unique.platform.aws.local-ipv4" }}"
DATASTORE_TYPE="etcdv3"
ETCD_ENDPOINTS="{{- range nomadService "etcd-peer" -}}http://{{ .Address }}:{{ .Port }},{{- end -}}"
CALICO_NETWORKING_BACKEND="bird"
CALICO_DISABLE_FILE_LOGGING="true"
FELIX_LOGSEVERITYSCREEN="info"
FELIX_IPV6SUPPORT="false"
FELIX_HEALTHENABLED="true"
EOF
      }
    }
  }
}

/*
docker run --detach --net=host --privileged --name=calico-node --restart=always \
-e ETCD_DISCOVERY_SRV= \
-e KUBECONFIG= \
-e KUBERNETES_SERVICE_HOST= \
-e KUBERNETES_SERVICE_PORT= \
-e CALICO_MANAGE_CNI="false" \
-e NODENAME=ip-10-100-1-157 \
-e CALICO_NETWORKING_BACKEND=bird \
-e CALICO_DISABLE_FILE_LOGGING="true" \
-e FELIX_IPV6SUPPORT="false" \
-e DATASTORE_TYPE="etcdv3" \
-e ETCD_ENDPOINTS=http://10.100.0.55:2380,http://10.100.1.157:2380,http://10.100.2.13:2380 \
-v /var/log/calico:/var/log/calico \
-v /var/run/calico:/var/run/calico \
-v /var/lib/calico:/var/lib/calico \
-v /lib/modules:/lib/modules \
-v /run:/run \
calico/node:v3.27.2
*/