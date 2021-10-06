FROM ubuntu:latest

WORKDIR /etc/openvpn

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install openvpn -y

RUN apt-get install net-tools tcpdump inetutils-ping -y

COPY ./conf/ .
COPY ./data/pki/ca.crt .
COPY ./data/pki/issued/client.crt .
COPY ./data/pki/private/client.key .
COPY ./data/pki/ta.key .

ENV REMOTE='server'

CMD ["openvpn", "/etc/openvpn/client.conf"]
