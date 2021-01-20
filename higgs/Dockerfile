FROM ghcr.io/catofes/rait/rait:v4.4.3 as rait
FROM ghcr.io/catofes/trigger/trigger:v1.6 as trigger
FROM ubuntu:20.04
WORKDIR /etc/higgs
COPY sources.list /etc/apt/sources.list
RUN apt update && apt -y upgrade
RUN apt install -y wireguard-tools babeld supervisor bash net-tools iptables iproute2 ca-certificates
COPY . .
COPY --from=rait /usr/local/bin/rait /usr/sbin/higgs
COPY --from=trigger /usr/bin/trigger /usr/sbin/trigger
ENTRYPOINT [ "./entrypoint.sh" ]