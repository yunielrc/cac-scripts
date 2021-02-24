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

Run on each ubuntu server:

```sh
echo "${USER} ALL=NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd
```

Run on your pc:

```sh
git clone https://github.com/yunielrc/cac-scripts.git
cd cac-scripts/packages/triumvirate-ssvpn
cp .env{.sample,}
vim .env                  # edit the config
bash configure-backend    # configure middle and end server
bash configure-gateway    # configure garteway saever
```

If GATEWAY is running in a VirtualBox VM on your PC, run the command below:

```sh
bash configure-local
```


## Usage

- Use 'GATEWAY' as a gateway and dns server for the devices on your network
