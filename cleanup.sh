#!/bin/bash
set -e -o pipefail

echo "Warning this will remove all your docker files by performing a system prune!!!"
echo "use -f to force"

if ! [[ "$1" == "-f" ]]; then
  exit 1
fi

docker rm -f -v server
docker rm -f -v client

# docker system prune -a --volumes

rm -rf ./data
