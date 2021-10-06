#!/bin/bash
set -e -o pipefail

OVPN_DATA="${PWD}/data"
SERVER_URL='server'
CLIENTNAME='client'
TARGET_DIR="${PWD}/files"

docker network create ovpn-net || true

docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm kylemanna/openvpn \
  ovpn_genconfig -u "udp://${SERVER_URL}"

echo 'push "redirect-gateway def1"' >> "${OVPN_DATA}/openvpn.conf"
echo 'push "remote-gateway vpn_server_ip"' >> "${OVPN_DATA}/openvpn.conf"

docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  ovpn_initpki

docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  -d -p 1194:1194/udp --cap-add=NET_ADMIN \
  --name server --network ovpn-net \
  kylemanna/openvpn

docker run \
  -v "${OVPN_DATA}:/etc/openvpn" \
  --rm -it kylemanna/openvpn \
  easyrsa build-client-full "${CLIENTNAME}" nopass

# docker run \
#   -v "${OVPN_DATA}:/etc/openvpn" \
#   --rm kylemanna/openvpn \
#   ovpn_getclient "${CLIENTNAME}" > "${TARGET_DIR}/${CLIENTNAME}.ovpn"

docker build -t client .

docker run \
  --name client --network ovpn-net \
  --device=/dev/net/tun \
  --cap-add=NET_ADMIN \
  --rm -d client

