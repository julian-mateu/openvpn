#!/bin/bash
set -e -o pipefail

docker-compose down --volumes --remove-orphans
docker-compose rm

# Remove volume
rm -rf ./data
