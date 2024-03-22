job "nomad-vxlan" {
  type = "sysbatch"
  periodic {
    crons            = ["* * * * *"]
    prohibit_overlap = true
  }
  group "vxlan-net" {
    task "prepare" {
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args    = ["local/prepare.sh"]
      }
      template {
        destination = "local/prepare.sh"
        change_mode = "restart"
        data        = <<EOF
#!/bin/bash

NETWORK_NAME="vxlan-net"
NETWORK_SUBNET="192.168.0.0/16"

if docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
  echo "[WARN] docker network '$NETWORK_NAME' already exists"
else
  echo "[INFO] docker network '$NETWORK_NAME' does not exist, work in progress..."
  docker network create --subnet $NETWORK_SUBNET $NETWORK_NAME
  if [ $? -eq 0 ]; then
    echo "[INFO] docker network '$NETWORK_NAME' created"
  else
    echo "[ERROR] an error occured when trying to create docker network '$NETWORK_NAME'"
    exit 1
  fi
fi
EOF
      }
      identity {
        env  = true
        file = true
      }
      resources {
        cpu    = 10
        memory = 32
      }
    }
  }
}
