load test_helper

@test 'configure_end_server should install openvpn + sss server' {
  [[ -f "$END_SERVER_OVPN_PROFILE_LOCAL_PATH" ]] &&
    rm -f "$END_SERVER_OVPN_PROFILE_LOCAL_PATH"

  configure_end_server

  ssh "${END_SERVER_USER}@${END_SERVER_IP}" <<-'SSHEOF'
    set -euEo pipefail

    [[ -n "$(sudo docker ps --all --quiet --filter name=ssserver)" ]]
    [[ -n "$(sudo docker ps --all --quiet --filter name=openvpn)" ]]
SSHEOF

  [[ -f "$END_SERVER_OVPN_PROFILE_LOCAL_PATH" ]]
}

@test 'configure_middle_server should install openvpn + sss server, openvpn client + ssclient' {
  [[ -f "$MIDDLE_SERVER_OVPN_PROFILE_LOCAL_PATH" ]] &&
    rm -f "$MIDDLE_SERVER_OVPN_PROFILE_LOCAL_PATH"

  configure_middle_server

  ssh "${MIDDLE_SERVER_USER}@${MIDDLE_SERVER_IP}" <<-SSHEOF
    set -euEo pipefail

    # CHECKS: >> CONFIGURES DNS
    sudo apt update -y
    sudo apt install -y pcre2-utils
    systemd-resolve --status | pcre2grep -M '\s*Current DNS Server: 1\.1\.1\.1\s*\n\s*DNS Servers: 1\.1\.1\.1\s*\n\s*1\.0\.0\.1'

    # CHECKS: >> INSTALL AND CONFIGURE: OPENVPN CLIENT + SHADOWSOCKS CLIENT to end-server

    ## CHECKS: Configures end-server.ovpn profile
    pcre2grep -M '\s*route\s+152\.206\.0\.0\s+255\.254\.0\.0\s+net_gateway\s*\n\s*#.*\n\s*persist-tun\s*\n\s*persist-key\s*' ~/"${END_SERVER_OPENVPN_CLIENT_NAME}.ovpn"

    systemctl status openvpn-client@ovpn-ssclient
    [[ -n "\$(sudo docker ps --all --quiet --filter name=ssclient)" ]]

    dig +short myip.opendns.com @resolver1.opendns.com | grep -q "$END_SERVER_IP"

    ## TODO: test traffic route with traceroute

    # CHECKS: >> INSTALLS AND CONFIGURES: OPENVPN SERVER + SHADOWSOCKS SERVER for gateway client
    [[ -n "\$(sudo docker ps --all --quiet --filter name=ssserver)" ]]
    [[ -n "\$(sudo docker ps --all --quiet --filter name=openvpn)" ]]

SSHEOF

  [[ -f "$MIDDLE_SERVER_OVPN_PROFILE_LOCAL_PATH" ]]
}

@test 'configure_gateway should install openvpn + sss client' {
  skip
  configure_gateway

  ssh "${GATEWAY_USER}@${GATEWAY_IP}" <<-SSHEOF
    set -euEo pipefail

    #
    # CHECK: Upload files
    #
    [[ -d /tmp/gateway ]]

    #
    # CHECK: Copies middle-server.ovpn profile from local to gateway
    #
    [[ -f ~/"${MIDDLE_SERVER_OPENVPN_CLIENT_NAME}.ovpn" ]]

    #
    #  CHECK: onfigures Network
    #
    readonly nic="\$(ip r | grep '^default' | cut -d' ' -f5)"
    [[ "\$(ip r | grep "\${nic}.*kernel" | cut -d' ' -f9)" == "$GATEWAY_IP" ]]
    [[ "\$(ip r | grep '^default' | cut -d' ' -f3)" == "$GATEWAY_GATEWAY_IP" ]]

    #
    # Installs and Configures: openvpn client + shadowsocks client to middle-server
    #

    systemctl status openvpn-client@ovpn-ssclient
    [[ -n "\$(sudo docker ps --all --quiet --filter name=ssclient)" ]]

    #
    # CHECKS: Install dnsmasq
    #
    systemctl status dnsmasq

    #
    # CHECKS: Enables ipv4 forwarding
    #
    [[ "$(sysctl net.ipv4.ip_forward)" == 'net.ipv4.ip_forward = 1' ]]

    #
    # CHECKS: Installs vpn gateway iptables
    #
    systemctl status vpn-router-iptable-rules
    sleep 3
    # dig +short myip.opendns.com @resolver1.opendns.com | grep -q "$END_SERVER_IP"

    ## TODO: test traffic route with traceroute
SSHEOF
}

@test 'configure_gateway_alpine should install openvpn + sss client' {
  configure_gateway_alpine

  ssh "${GATEWAY_USER}@${GATEWAY_IP}" <<-SSHEOF
    set -eu

    #
    # CHECK: Upload files
    #
    [ -d /tmp/gateway ]

    #
    # CHECK: Installs & configures shadowsocks client (sslocal)
    #
    rc-service sslocal status

    #
    # CHECK: Installs & configure openvpn client
    #
    rc-service openvpn-client-sslocal status

    #
    # CHECKS: Installs dnsmasq
    #
    rc-service dnsmasq status

    #
    # CHECKS: Installs vpn gateway iptables
    #
    rc-service vpn-router-iptable-rules status

    # #
    # #  CHECK: Configures Network
    # #
    # readonly nic="\$(ip r | grep '^default' | cut -d' ' -f5)"
    # [ "\$(ip r | grep "\${nic}.*kernel" | cut -d' ' -f9)" = "$GATEWAY_IP" ]
    # [ "\$(ip r | grep '^default' | cut -d' ' -f3)" = "$GATEWAY_GATEWAY_IP" ]
    wget -qO - ifconfig.me
    # wget -qO - ifconfig.me | grep -q "$END_SERVER_IP"

    ## TODO: test traffic route with traceroute
SSHEOF
}

@test 'configure_local_pc should Install gateway virtualbox vm service for autostart' {
  skip
  configure_local_pc
  systemctl status "vbox-vm-start@${GATEWAY_VBOX_NAME}"
}