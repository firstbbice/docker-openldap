#!/usr/bin/env bash

cd /opt/slapd 
mkdir etc/slapd.d
mkdir var/openldap-data
mkdir var/openldap-accesslog

# Check if we already have a config database and create one if we don't
if [ ! -e /opt/slapd/etc/slapd.d/cn=config.ldif ]; then
	echo "Running: slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif"
	slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif 2>&1
fi

if [ ! -e /opt/slapd/var/openldap-data/data.mdb ]; then
	echo "Running: slapadd -F etc/slapd.d -b "dc=tcn,dc=com" -l etc/openldap/initial.ldif"
	slapadd -F etc/slapd.d -b "dc=tcn,dc=com" -l etc/openldap/initial.ldif 2>&1
fi

if [ ! -e /opt/slapd/var/openldap-accesslog/data.mdb ]; then
	echo "Running: slapadd -F etc/slapd.d -b "dc=tcn,dc=com" -l etc/openldap/accesslog.ldif"
	slapadd -F etc/slapd.d -b "cn=accesslog" -l etc/openldap/accesslog.ldif 2>&1
fi

/opt/slapd/libexec/slapd -d $LOGLEVEL -F /opt/slapd/etc/slapd.d -h "ldap:/// ldapi:///"


