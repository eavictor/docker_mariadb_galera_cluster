#!/usr/bin/env bash

# Check user run this script with admin privilege
if [[ $EUID -ne 0 ]]
  then echo "Please run as root"
  exit 1
fi

# Install curl
apt update
apt install curl -y

# Install weave
curl -L git.io/weave -o /usr/local/bin/weave
chmod a+x /usr/local/bin/weave
mkdir -p /etc/sysconfig/

# Create peer file with the ip address or hostnames /etc/sysconfig/weave
cat > /etc/sysconfig/weave << EOF
PEERS="$@"
EOF

# Create Weave systemd unit file :
cat > /etc/systemd/system/weave.service << EOF
[Unit]
Description=Weave Network
Documentation=http://docs.weave.works/weave/latest_release/
Requires=docker.service
After=docker.service
[Service]
EnvironmentFile=-/etc/sysconfig/weave
ExecStartPre=/usr/local/bin/weave launch --no-restart \${PEERS}
ExecStart=/usr/bin/docker attach weave
ExecStop=/usr/local/bin/weave stop
[Install]
WantedBy=multi-user.target
EOF

# Start and Enable weave service on boot
/usr/local/bin/weave reset
systemctl daemon-reload
systemctl start weave
systemctl enable weave

# Show weave status
systemctl status weave
echo "Targets :"
weave status targets
echo "Connections :"
weave status connections
echo "Peers :"
weave status peers

exit 0