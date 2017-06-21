#! /bin/bash

# for given domain(s), configure your IP routing to connect to them directly through your default gateway rather than a VPN

if [ ! -n "$1" ]
then
	echo "usage: sudo $(basename $0) domain1.com domain2.org ..." >&2
	exit 1
fi

gateway=$(ip route show | grep -i 'default via'| awk '{print $3 }')

for domain in "$@"
do
	for address in $(host $domain | grep 'has address' | cut -f 4 -d ' ') # a domain might resolve to multiple addresses
	do
		ip route replace $address via $gateway
	done
done

