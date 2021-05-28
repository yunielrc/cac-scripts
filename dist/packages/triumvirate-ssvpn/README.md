# triumvirate-ssvpn

Configures three servers connected in a straight line with vpn + shadowsocks

GATEWAY ⇆ MIDDLE-SERVER ⇆ END-SERVER

GATEWAY           |  MIDDLE-SERVER    | END-SERVER
------------------|-------------------|---------
|**_vpn client (0)_**   | ss client (2)  ⇆  | ⇆  ss server (2)
|     ⇅          |      ⇅            |    ⇅
|     ⇅          | ⇅ vpn client (2)  | ⇅ vpn server (2)
|ss client (1) ⇆ | ⇆ ss server (1)   | **_⇅ vpn server (0)_**

## Only Gateway

### Prerequisites for gateway server

- middle-server and end-server already configured and running
- A device or a vm instance running on your local network with a Clean Alpine linux 13.13 or higher installed.
  [How to install alpine in virtualbox](https://github.com/yunielrc/kbp/blob/main/HOWTO/INTALL-ALPINE-IN-VBOX.md)
- Middle server openvpn profile on your pc, eg: middle-server.ovpn

### Configure gateway

Run the commands below to configure:

```sh
git clone https://github.com/yunielrc/cac-scripts.git
cd cac-scripts/dist/packages/triumvirate-ssvpn

mv .env{,.bak}
cp .env{.gateway.sample,.local}
vim .env.local                         # edit the config
ssh-copy-id <gateway_user>@<gateway_ip>
cp <some_dir>/middle-server.ovpn ~/middle-server.ovpn
bash configure-gateway                 # configure gateway server

rm ~/middle-server.ovpn
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below for autostart it:

```sh
bash configure-local
```

## All servers

### Prerequisites for triumvirate-ssvpn

You need three devices or vm instances running, one on your local network (GATEWAY with alpine linux 13.13),
another on your country's intranet (MIDDLE-SERVER with ubuntu 20.04), and another on internet (END-SERVER with ubuntu 20.04).

END-SERVER must have two public IP, END_SERVER_IP must be the floating IP, and END_SERVER_IP2 must be the real server IP.

Before continuing to configure the servers, you must run the following command on each ubuntu server in order to run sudo without password prompt:

```sh
echo "${USER} ALL=NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd
```

### Configure all servers

Run the commands below to configure:

```sh
git clone https://github.com/yunielrc/cac-scripts.git
cd cac-scripts/dist/packages/triumvirate-ssvpn

mv .env{,.bak}
cp .env{.sample,.local}
vim .env                  # edit the config
ssh-copy-id <gateway_user>@<gateway_ip>
ssh-copy-id <middle_user>@<middle_ip>
ssh-copy-id <end_user>@<end_ip>
bash configure-backend    # !!OPTIONAL!!: configure middle and end server
bash configure-gateway    # configure gateway server
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below for autostart it:

```sh
bash configure-local
```

## Usage

- Use 'GATEWAY' as a gateway and dns server for the devices on your network
