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

You need three devices or vm instances, one in your local network (gateway),
another in your country's network (middle-server), and another in a foreign country (end-server)

## Install

Before continuing to configure the servers, you must run the following command on each
server in order to run sudo without password prompt.

Run on each server:

```sh
echo "${USER} ALL=NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd
```

git clone https://github.com/yunielrc/cac-scripts.git

```sh
cd cac-scripts/packages/triumvirate-ssvpn
cp .env{.sample,}
vim .env          # edit the config
bash configure    # configure the three servers
```

## Usage

- Use 'GATEWAY' as a gateway and dns server for the devices on your network
- if GATEWAY loses access to MIDDLE-SERVER, you have to restart vpn client
running on GATEWAY with the command below:

```sh
ssh GATEWAY_USER@GATEWAY_IP sudo systemctl restart openvpn-client@ovpn-ssclient
```
