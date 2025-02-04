#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: jpmurray
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://beets.readthedocs.io

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

APPLICATION="beets"
APPLICATION_WEB="beets-web"
MUSIC_FOLDER="/opt/beets/music/"
LIBRARY_FOLDER="/opt/beets/data/"
CONFIG_PATH="/opt/beets/config.yaml"
LIBRARY_PATH="${LIBRARY_FOLDER}/musiclibrary.db"

msg_info "Installing Dependencies"
$STD apt-get install -y \
  python-dev-is-python3 \
  python3-pip
msg_ok "Installed Dependencies"

msg_info "Installing ${APPLICATION}"
IPADDRESS=$(hostname -I | awk '{print $1}')
$STD pip install beets
$STD export CONFIG_PATH="$(beet config -p)"
$STD touch $CONFIG_PATH
$STD mkdir -p ${MUSIC_FOLDER}
$STD mkdir -p ${LIBRARY_FOLDER}

cat <<EOF >$CONFIG_PATH
directory: ${MUSIC_FOLDER}
library: ${LIBRARY_PATH}
plugins: web
EOF

msg_ok "Installed ${APPLICATION}"

msg_ok "Installing ${APPLICATION} web plugin"
$STD pip install "beets[web]"
msg_ok "Installed beets"

msg_info "Creating Service for ${APPLICATION} web"
cat <<EOF >/etc/systemd/system/beets-web.service
[Unit]
Description=beets-web Service
After=network.target

[Service]
ExecStart=beet web
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now beets-web.service
msg_ok "Service created and started"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

msg_info "Configuration file location :"
beet config -p
msg_ok "Printed"