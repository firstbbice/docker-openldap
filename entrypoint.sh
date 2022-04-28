#!/bin/sh

# Check if we already have a config database and create one if we don't
if [ ! -e /opt/slapd/etc/slapd.d/cn=config.ldif ]; then
	cd /opt/slapd 

	# the data dir should be a volume, but because podman sucks balls
	# and I'm sometimes testing starting without mounting openldap-data,
	# create this directory if it's not already there
	mkdir -p /opt/slapd/var/openldap-data

	echo "Running: slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif"
	slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif 2>&1
	slapadd -F etc/slapd.d -b "dc=tcn,dc=com" -l etc/openldap/initial.ldif 2>&1
fi

/opt/slapd/libexec/slapd -d "conns,ACL,filter,stats" -F /opt/slapd/etc/slapd.d -h "ldap:/// ldapi:///"


