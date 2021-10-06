# openvpn
Configuration files and scripts to run openvpn server and clients with docker.

## Getting started

Just run the `setup.sh` script and answer to the interactive questions:
```bash
./setup.sh
```

This will create:
- a `data` folder which contains the configuration for the server
- a `server` docker container running the OpenVPN server
- a `client` docker container runing the OpenVPN client

To verify that the client is connected and routing traffic through the vpn:
```bash
$ docker exec -it client sh
# tcpdump -n -i tun0
```
and then open another terminal:
```bash
$ docker exec -it client sh
# ping www.google.com
```
and you should see traffic going through the `tun0` interface.

## Cleanup
Just run the `cleanup.sh` script.
```bash
./cleanup.sh
```

## Next steps
The `setup.sh` script could be replaced by a multistage `Dockerfile` that runs the configuration containers and then the OpenVPN server, and finally both the server and client could be ran with `docker-compose`.

The ultimate goal of this little project would be to run OpenVPN server in one raspberry pi at home, and to be able to connect through it from anywhere in the world.
