#!/usr/bin/env bash

#source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
source <(curl -s https://raw.githubusercontent.com/jpmurray/ProxmoxVE/refs/heads/add-scripts-beets/misc/build.func)

# Copyright (c) 2021-2025 community-scripts ORG
# Author: jpmurray
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://beets.readthedocs.io

# App Default Values
APP="beets"
var_tags="media"
var_cpu="1"
var_ram="512"
var_disk="8"
var_os="ubuntu"
var_version="24.04"
var_unprivileged="0"

# App Output & Base Settings
header_info "$APP"
base_settings

# Core
variables
color
catch_errors

function update_script() {
    header_info
    check_container_storage
    check_container_resources

    if [[ ! -d /opt/beets ]]; then
        msg_error "No ${APP} Installation Found!"
        exit
    fi

    CURRENT_VERSION="pip index versions beets | grep "INSTALLED" | awk '{print $2}'"
    AVAILABLE_VERSION="pip index versions beets | grep "LATEST" | awk '{print $2}'"

    if [[ "${CURRENT_VERSION}" != "AVAILABLE_VERSION" ]]; then
        msg_info "Updating ${APP} to v${RELEASE}"
        pip install beets -U &>/dev/null
        msg_info "Updating ${APP} LXC"
        apt-get update &>/dev/null
        apt-get -y upgrade &>/dev/null
        msg_ok "Updated Successfully"
    else
        msg_ok "No update required. ${APP} is already at ${RELEASE}."
    fi

    exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8337${CL}"
