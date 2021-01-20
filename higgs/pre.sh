#!/bin/bash
set -ex

source /etc/higgs/env

echo "Add higgs netns" 
if [ -z "$(ip netns list | grep higgs)" ]; then
        ip netns add higgs
else
        ip netns del higgs
        ip netns add higgs
fi

echo "Prepare babeld.conf"
id=$(cat /etc/higgs/rait.conf | grep private_key | cut -d "\"" -f 2 | head -n 1 | wg pubkey | md5sum | cut -d " " -f 1)
export BabelID=${id:0:2}:${id:2:2}:${id:4:2}:${id:6:2}:${id:8:2}:${id:10:2}:${id:12:2}:${id:12:2}
envsubst < /etc/higgs/babeld.template > /etc/higgs/babeld.conf

if [ ${Forward} == "true" ]; then
        sysctl -w net.ipv4.ip_forward=1
        sysctl -w net.ipv6.conf.all.forwarding=1
        ip6tables -I FORWARD -s ${NET} -j ACCEPT
        ip6tables -I FORWARD -d ${NET} -j ACCEPT
else
        echo "out ip ${Prefix}::/${CIDR} allow" >> /etc/higgs/babeld.conf
        echo "out deny" >> /etc/higgs/babeld.conf
fi