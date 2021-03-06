#!/usr/bin/env bash

cd /opt/slapd 
mkdir etc/slapd.d
mkdir var/openldap-data
mkdir var/openldap-accesslog

# Check if we already have a config database and create one if we don't
if [ ! -e /opt/slapd/etc/slapd.d/cn=config.ldif ]; then
	if grep LOGOPS /opt/slapd/etc/openldap/slapd.ldif; then
		sed -i "s/LOGOPS/$LOGOPS/g" /opt/slapd/etc/openldap/slapd.ldif
		sed -i "s/LOGPURGE/$LOGPURGE/g" /opt/slapd/etc/openldap/slapd.ldif
		sed -i "s/LDAP_DC/$LDAP_DC/g" /opt/slapd/etc/openldap/slapd.ldif
		sed -i "s/LDAP_TLD/$LDAP_TLD/g" /opt/slapd/etc/openldap/slapd.ldif
		sed -i "s/MGR_USER/$MGR_USER/g" /opt/slapd/etc/openldap/slapd.ldif
	fi

	echo "Running: slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif"
	slapadd -n 0 -F etc/slapd.d -l etc/openldap/slapd.ldif 2>&1

	if [ $ENABLE_DCSI = "true" ]; then
		echo "Loading DCSi schema"
		slapadd -n 0 -F etc/slapd.d -l etc/openldap/schema/dcsi.ldif 2>&1
		slapmodify -n 0 -F etc/slapd.d -l etc/openldap/dcsi-indexes.ldif 2>&1
	fi
fi

if [ ! -e /opt/slapd/var/openldap-data/data.mdb ]; then
	sed -i "s/LDAP_DC/$LDAP_DC/g" /opt/slapd/etc/openldap/initial.ldif
	sed -i "s/LDAP_TLD/$LDAP_TLD/g" /opt/slapd/etc/openldap/initial.ldif
	sed -i "s/MGR_USER/$MGR_USER/g" /opt/slapd/etc/openldap/initial.ldif
	sed -i "s/MGR_PASS/$MGR_PASS/g" /opt/slapd/etc/openldap/initial.ldif
	sed -i "s/LDAP_ORG/$LDAP_ORG/g" /opt/slapd/etc/openldap/initial.ldif

	echo "Running: slapadd -F etc/slapd.d -b "dc=$LDAP_DC,dc=$LDAP_TLD" -l etc/openldap/initial.ldif"
	slapadd -F etc/slapd.d -b "dc=$LDAP_DC,dc=$LDAP_TLD" -l etc/openldap/initial.ldif 2>&1

	if [ $ENABLE_DCSI = "true" ]; then
		sed -i "s/LDAP_DC/$LDAP_DC/g" /opt/slapd/etc/openldap/dcsi-examples.ldif
		sed -i "s/LDAP_TLD/$LDAP_TLD/g" /opt/slapd/etc/openldap/dcsi-examples.ldif
		echo "Loading dcsi-examples.ldif"
		slapadd -F etc/slapd.d -b "dc=$LDAP_DC,dc=$LDAP_TLD" -l etc/openldap/dcsi-examples.ldif 2>&1
	fi
fi

if [ ! -e /opt/slapd/var/openldap-accesslog/data.mdb ]; then
	echo "Running: slapadd -F etc/slapd.d -b "cn=accesslog" -l etc/openldap/accesslog.ldif"
	slapadd -F etc/slapd.d -b "cn=accesslog" -l etc/openldap/accesslog.ldif 2>&1
fi

/opt/slapd/libexec/slapd -d $LOGLEVEL -F /opt/slapd/etc/slapd.d -h "ldap:/// ldapi:///"


