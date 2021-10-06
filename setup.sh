#!/bin/bash
set -e -o pipefail

OVPN_DATA="${PWD}/data"
SERVER_URL='server'
CLIENTNAME='client'
TARGET_DIR="${PWD}/files"

# Create a network so the client can talk to the server with the `server` hostname instead of IP
docker network create ovpn-net || true

# See https://github.com/kylemanna/docker-openvpn#quick-start

# Create the server config and store it in the $OVPN_DATA volume
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm kylemanna/openvpn \
  ovpn_genconfig -u "udp://${SERVER_URL}"

# Force the traffic trhough the VPN. See https://askubuntu.com/a/466011
echo 'push "redirect-gateway def1"' >> "${OVPN_DATA}/openvpn.conf"
echo 'push "remote-gateway vpn_server_ip"' >> "${OVPN_DATA}/openvpn.conf"

# Run PKI init script in interactive mode to create CA and certificates in the $OVPN_DATA volume
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  ovpn_initpki

# Run the server container in detached mode
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  -d -p 1194:1194/udp --cap-add=NET_ADMIN \
  --name server --network ovpn-net \
  kylemanna/openvpn

# Generate the client config and certs
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  easyrsa build-client-full "${CLIENTNAME}" nopass

# The step below is commented as the client config is copied from a local file instead of using the .ovpn file generated
# Get the client config and store it in the volume
# docker run \
#   -v "${OVPN_DATA}:/etc/openvpn" \
#   --rm kylemanna/openvpn \
#   ovpn_getclient "${CLIENTNAME}" > "${TARGET_DIR}/${CLIENTNAME}.ovpn"

# Build the client from the Dockerfile
docker build -t client .

# Run the client in detached mode
docker run \
  --name client --network ovpn-net \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  --rm -d client

