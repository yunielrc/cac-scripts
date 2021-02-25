# triumvirate-ssvpn

Configures three servers connected in a straight line with vpn + shadowsocks

GATEWAY ⇆ MIDDLE-SERVER ⇆ END-SERVER

GATEWAY       | MIDDLE-SERVER   | END-SERVER
--------------|-----------------|---------
|vpn client   |   ss client  ⇆ | ⇆  ss server
|     ⇅      |   ⇅ vpn client  |    ⇅
|     ⇅      |   ⇅ vpn server  |    ⇅
|ss client ⇆  | ⇆ ss server    | vpn server

## Only Gateway

### Prerequisites for gateway server

- middle-server and end-server already configured and running
- A device or a vm instance running on your local network with a Clean Alpine linux 13.13 or higher installed.
  [How to install alpine in virtualbox](https://github.com/yunielrc/kbp/blob/main/HOWTO/INTALL-ALPINE-IN-VBOX.md)
- Middle server openvpn profile on your pc, eg: middle-server.ovpn

### Configure gateway

Run the commands below to configure:

```sh
ssh-copy-id <GATEWAY_USER>@<GATEWAY_IP>
cp <DIR>/middle-server.ovpn ~/middle-server.ovpn

git clone https://github.com/yunielrc/cac-scripts.git
cd cac-scripts/dist/packages/triumvirate-ssvpn

cp .env{.gateway.sample,.local}
vim .env.local                         # edit the config
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
another on your country's intranet (MIDDLE-SERVER with ubuntu 20.04), and another on internet (END-SERVER with ubuntu 20.04)

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
bash configure-backend    # !!OPTIONAL!!: configure middle and end server
bash configure-gateway    # configure gateway server
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below for autostart it:

```sh
bash configure-local
```

## Usage

- Use 'GATEWAY' as a gateway and dns server for the devices on your network
