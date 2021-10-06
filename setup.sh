#!/bin/bash
set -e -o pipefail

OVPN_DATA="${PWD}/data"
SERVER_URL='server'
CLIENTNAME='client'

# See https://github.com/kylemanna/docker-openvpn#quick-start

# Create the server config and store it in the $OVPN_DATA volume
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm kylemanna/openvpn \
  ovpn_genconfig -u "udp://${SERVER_URL}"

# Force the traffic trhough the VPN. See https://askubuntu.com/a/466011
echo 'push "redirect-gateway def1"' >>"${OVPN_DATA}/openvpn.conf"
echo 'push "remote-gateway vpn_server_ip"' >>"${OVPN_DATA}/openvpn.conf"

# Run PKI init script in interactive mode to create CA and certificates in the $OVPN_DATA volume
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  ovpn_initpki

# Generate the client config and certs
docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  easyrsa build-client-full "${CLIENTNAME}" nopass

docker-compose up --build
