#!/bin/bash

# Storyline: Create peer VPN configuration file


# What is the user / peer's name
echo -n "What is the peer's name? "
read the_client

# Filename variable
pFile="${the_client}-wg0.conf"

# Check for existing config file / if we want to override
if [[ -f "${pFile}" ]]
then
	# Prompt if we need to overwrite file
		echo "The file ${pFile} already exists."
	echo -n "Do you want to overwrite it? [y|N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
	then
		echo "Exiting..."
		exit 0
	elif [[ "${to_overwrite}" == "y" ]]
	then
		echo "Creating the wireguard configuration file..."
	# If they don't specify their decision then error out
	else
		echo "Invalid value"
		exit 1
	fi
fi
# Generate private key
p="$(wg genkey)"

# Generate public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate preshared key used for additional security for the client when establishing vpn tunnel
pre="$(wg genpsk)"

# 10.254.132.0/24,172.16.28.0/24  192.199.97.164:4282 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 8.8.8.8,1.1.1.1 1280 120.0.0.1

# Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

# Server public key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListeningPort
lport="$(shuf -n1 -i 40000-50000)"

# Default Routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

# Create Client Configuration file
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort - ${lport}
MTU = ${mtu}
PrivateKey = ${p}
[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

# Add our peer configuration to the server config
echo "
# ${the_client} begin
[Peer]
PublicKey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.100/32
# ${the_client} end 
"| tee -a wg0.conf
