# The debian:latest tag will always point the latest stable release of debian
ARG BASE_IMAGE=debian:latest
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=golang:latest /usr/local/go/ /usr/local/go/

ENV GOROOT=/usr/local/go/
ENV GOPATH="${HOME}/go"
ENV PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"

RUN apt-get update -qq  &&\
# command line tool for transferring data with URL syntax
apt-get install curl \
# gpg tools
gnupg \
# dig, nslookup etc
dnsutils \
# ncursed-based process viewer
htop \
# suite is a collection of utilities for networking and traffic control.
iproute2 \
# ping command sends ICMP ECHO_REQUEST packets
iputils-ping \
# jq is like sed for JSON data
jq \
# List Open Files
lsof \
# ltrace intercepts and records the dynamic library calls
ltrace \
# Includes arp, ifconfig, netstat, rarp, nameif and route.
net-tools \
# TCP/IP swiss army knife
netcat-traditional \
# network exploration or security auditing
nmap \
# SSL and TLS cryptographic protocols
openssl \
# contains free, kill, pkill, pgrep, pmap, ps, pwdx, skill, slabtop, snice, sysctl, tload, top, uptime, vmstat, w, and watch.
procps \
# Socat (for Socket CAT) establishes two bidirectional byte streams and transfers data between them.
socat \
# strace is a system call tracer, i.e. a debugging tool which prints out a trace of all the system calls made by a another process/program
strace \
# system performance tools, sar, iostat, pidstat
sysstat \
# network utility to retrieve files from the web using HTTP(S) and FTP
wget \
# database client package for PostgreSQL.
postgresql-client \
# mysql database client
mysql-client \
# captures data transmitted as part of TCP connections
tcpflow \
# Vim is an almost compatible version of the UNIX editor Vi.
vim \
# small, friendly text editor inspired by Pico
nano \
# sudo for sudo stuff
sudo \
# common files for software-properties, ca-certificates, python3
software-properties-common -y -qq

# lightweight and portable command-line YAML, JSON and XML processor. yq uses jq like syntax but works with yaml files as well as json, xml, properties, csv and tsv.
RUN go install github.com/mikefarah/yq/v4@latest


# Instal mongo lcient
RUN wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc \
    | tee /etc/apt/trusted.gpg.d/server-7.0.asc && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
    | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update -y && apt-get install -y mongodb-mongosh

RUN apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
