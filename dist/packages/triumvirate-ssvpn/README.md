# triumvirate-ssvpn

Configures three servers connected in a straight line with vpn + shadowsocks

GATEWAY ⇆ MIDDLE-SERVER ⇆ END-SERVER

GATEWAY       | MIDDLE-SERVER   | END-SERVER
--------------|-----------------|---------
|vpn client   |   ss client  ⇆ | ⇆  ss server
|     ⇅      |   ⇅ vpn client  |    ⇅
|     ⇅      |   ⇅ vpn server  |    ⇅
|ss client ⇆  | ⇆ ss server    | vpn server

## Prerequisites

You need three devices or vm instances, one on your local network (GATEWAY with alpine linux 13.13),
another on your country's intranet (MIDDLE-SERVER with ubuntu 20.04), and another on internet (END-SERVER with ubuntu 20.04)

## Configure

Before continuing to configure the servers, you must run the following command on each ubuntu server in order to run sudo without password prompt:

```sh
echo "${USER} ALL=NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd
```

### Configure only gateway

If you has a backend configured, run the commands below:

```sh
cp <DIR>/middle-server.ovpn ~/middle-server.ovpn
ssh-copy-id <GATEWAY_USER>@<GATEWAY_IP>
wget -qO - https://git.io/Jt523?=configure-gateway |
  PROXY_URL='http://<user>:<password>@<ip>:<port>' \
  MIDDLE_SERVER_IP='<instance-ip>' \
  MIDDLE_SERVER_SS_PORT=443 \
  MIDDLE_SERVER_SS_PASSWORD='<password>' \
  MIDDLE_SERVER_OPENVPN_CLIENT_NAME=middle-server \
  MIDDLE_SERVER_OVPN_PROFILE_LOCAL_PATH=~/middle-server.ovpn \
  GATEWAY_USER=root \
  GATEWAY_IP='<instance-ip>' \
  GATEWAY_GATEWAY_IP='<your-network-router-ip, eg: 192.168.1.1>' \
  GATEWAY_NETWORK='<your-network, eg: 192.168.1.0/24>' \
  GATEWAY_OVPN_CLIENT_PROFILE_CUSTOM='# your comment
  route <ip that you want to pass outside the VPN> 255.255.255.255  net_gateway' \
  bash
rm ~/middle-server.ovpn
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below for autostart it:

```sh
wget -qO - https://git.io/Jt5Vt?=configure-local |
  GATEWAY_VBOX_NAME='<virtual-box-vm-name-without-spaces>' \
  bash
```

### Configure all servers

Run in your pc:

```sh
git clone https://github.com/yunielrc/cac-scripts.git
cd cac-scripts/packages/triumvirate-ssvpn
cp .env{.sample,}
vim .env                  # edit the config
bash configure-backend    # configure middle and end server
bash configure-gateway    # configure gateway server
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below for autostart it:

```sh
bash configure-local
```

## Usage

- Use 'GATEWAY' as a gateway and dns server for the devices on your network
