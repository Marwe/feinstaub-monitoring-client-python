#!/bin/bash

# connect to your freifunk (ff) router, get clients 
# MAC Prefix: 18:fe:34=Espressif Inc.
macp='\b([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}\b'
iwdev="client0"
# to find out the iw device:
# iwdev=$(ssh root@172.21.24.254 iwinfo | grep Freifunk| awk '{print $1}')
chipidfile="chipids.csv"
pubkey="$HOME/.ssh/id_rsa.pub"
if [ -f "$pubkey" ] ; then 
	sshopts="-i $pubkey"
fi

# ff next node IP: 172.21.24.254
# ff next node IP6: fd21:b4dc:4b1e::1
# you need to have key-based ssh access to your ff router 
# https://wiki.freifunk-stuttgart.net/anleitungen:config_mode:start#fernzugriff
# ip="fd21:b4dc:4b1e:0:ea94:f6ff:fe68:ebfe"

if [ -z "$1" ] ; then
	#ip="172.21.24.254"
	#ip="fd21:b4dc:4b1e::1"
	# new nextnodeip
	ip=fd21:711::1
else
	ip="$1"
fi

ssh $sshopts root@$ip iw dev $iwdev station dump | grep -E "$macp\|inactive\|signal\|bitrate"

# find chipid.csv

if [ ! -z "$(which realpath)" ] ; then
	chk="$(dirname $(realpath $0))/$chipidfile"
	if [ -f "$chk" ] ; then
		chipidfile="$chk"
	fi
fi

if [ -f "$chipidfile" ] ; then
	for mac in $(ssh $sshopts "root@$ip" iw dev $iwdev station dump | \
		grep -i -E "$macp" | \
		grep -o -i -E "$macp")
	do
 		grep -i "$mac" $chipidfile
	done
fi

