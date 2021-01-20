#!/bin/bash
set -ex

source /etc/higgs/env
echo "Add veth"
ip link add higgs address 00:00:00:00:00:01 type veth peer name host address 00:00:00:00:00:02 netns higgs mtu 1330
ip link set up higgs
ip link set higgs mtu 1330

echo "Add ip address "
ip addr add ${Prefix}::1/${CIDR} dev higgs
if [ ${IPv4} == "true" ];then
        ip -n higgs addr add ${Prefix}::fff4/128 dev g4vxlan
fi
if [ ${IPv6} == "true" ];then
        ip -n higgs addr add ${Prefix}::fff6/128 dev g6vxlan
fi

echo "Set link up"
ip -n higgs link set up lo
ip -n higgs link set up host

echo "Set route"
if [ ${Route} == "true" ];then
        ip -6 route add ${NET} via fe80::200:ff:fe00:2 dev higgs
        ip -6 rule add from ${NET} lookup ${Table}
        ip -6 rule add to ${Prefix}::/${CIDR} lookup main
        ip -6 route add default via fe80::200:ff:fe00:2 dev higgs table ${Table}
        ip -n higgs -6 route add ${Prefix}::/${CIDR} via fe80::200:ff:fe00:1 dev host proto kernel
fi

echo "Set iptables"
if [ ${IPv6} == "true" ];then
        ip6tables -I INPUT -d ${Prefix}::1 -p udp -m udp --dport ${IPv6Port} -j DROP
fi

echo "Set BGP Gateway"
if [ ${BGP} == "true" ];then
        ip -6 route change default via ${BGPGateway} dev ${BGPInterface} table ${Table}
        ip -6 route add ${NET} via fe80::200:ff:fe00:2 dev higgs table ${Table}
        IFS=', ' read -r -a ports <<< ${BGPBlockInputPort}
        for port in ${ports[@]}
        do
                ip6tables -I FORWARD ! -s ${NET} -d ${NET} -p tcp -m tcp --dport ${port} -j REJECT --reject-with icmp6-port-unreachable
        done
        IFS=', ' read -r -a ports <<< ${BGPBlockOutputPort}
        for port in ${ports[@]}
        do
                ip6tables -I FORWARD -s ${NET} ! -d ${NET} -p udp -m udp --dport ${port} -j REJECT --reject-with icmp6-port-unreachable
        done
        if [ ${BGPAnnounce} == "true" ];then
                ip -n higgs -6 route add default via fe80::200:ff:fe00:1 dev host proto kernel
        fi
fi