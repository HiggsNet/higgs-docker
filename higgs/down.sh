#!/bin/bash
set -x

source /etc/higgs/env

echo "Delete route"
ip -6 route flush table ${Table}
ip -6 rule del to ${Prefix}::/${CIDR} lookup main

if [ ${Route} == "true" ];then
        ip -6 rule del from ${NET} lookup ${Table}
fi

echo "Delete iptables"
if [ ${IPv6} == "true" ];then
        ip6tables -D INPUT -d ${Prefix}::1 -p udp -m udp --dport ${IPv6Port} -j DROP
fi

if [ ${BGP} == "true" ];then
        IFS=', ' read -r -a ports <<< ${BGPBlockInputPort}
        for port in ${ports[@]}
        do
                ip6tables -D FORWARD ! -s ${NET} -d ${NET} -p tcp -m tcp --dport ${port} -j REJECT --reject-with icmp6-port-unreachable
        done
        IFS=', ' read -r -a ports <<< ${BGPBlockOutputPort}
        for port in ${ports[@]}
        do
                ip6tables -D FORWARD -s ${NET} ! -d ${NET} -p udp -m udp --dport ${port} -j REJECT --reject-with icmp6-port-unreachable
        done
fi

if [ ${Forward} == "true" ];then
        ip6tables -D FORWARD -s ${NET} -j ACCEPT
        ip6tables -D FORWARD -d ${NET} -j ACCEPT
fi

ip netns del higgs