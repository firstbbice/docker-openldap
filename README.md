
### A docker image for spinning up openldap's slapd

This docker image grabs the openldap source and builds slapd and
installs it in /opt/slapd. 

If you want the data to be persistent, you must provide volumes for
slapd.d, openldap-data, and openldap-accesslog:

- **slapd.d**: Mounted to /opt/slapd/etc/slapd.d
- **openldap-data**: Mounted to /opt/slapd/var/openldap-data
- **openldap-accesslog**: Mounted to /opt/slapd/var/openldap-accesslog

Note that without these volumes mounted, your LDAP database will not
be persistent. When the container is stopped and restarted, it will be
with fresh config, main, and accesslog databases populated only with
my default slapd.ldif and initial.ldif (and optionally, my DCSi
schema and examples ldif files).

The slapd.d volume will contain your config database. If empty, the image
will build one from what it finds in /opt/slapd/etc/openldap/slapd.ldif.

The openldap-data volume is where your primary LDAP database
will be stored. If it's empty, the docker image will build a
database with slapadd using /opt/slapd/etc/openldap/initial.ldif.

The openldap-accesslog volume is where the accesslog LDAP database will
be stored. If it's empty, the docker image will build a fresh database
with slapadd using /opt/slapd/etc/openldap/accesslog.ldif.

### Example command to startup image

**docker run -d -p 8389:389 --net=bridge --name=openldap brentbice/openldap**

This command will start slapd and have it listen on port 8389 on your system,
but the databases will **not** be persisted. They'll be built from scratch
and thrown away when the docker image is restarted.

**docker run -d -v `pwd`/volumes/slapd.d:/opt/slapd/etc/slapd.d -v `pwd`/volumes/openldap-data:/opt/slapd/var/openldap-data -v `pwd`/volumes/openldap-accesslog:/opt/slapd/var/openldap-accesslog -p 8389:389 --net=bridge --name=openldap brentbice/openldap**

This command will start slapd and have it listen on port 8389 on your system.
All databases will be persisted in directories in the volumes directory.

### What databases exist and how to connect to them

The default database is built as dc=bicetech,dc=com (see the ENV vars
in the dockerfile to override with whatever you desire). The manager login
is cn=Manager,dc=bicetech,dc=com and the default password is "secret".
Obviously, you'll want to connect with the LDAP browser/editor of your choice
and change the password (and use SSHA or some other hash) right away.
There's a uid=brent.bice record under ou=People that I use for testing
that you'll want to get rid of (or rename and change the password for your
own testing).

The config database can be found at the Base DN of cn=config. The RootDN
is the cn=Manager account beneath whatever base you specified with the
BASE_DN ENV var with the password "secret" or whatever you specified with
the MGR_PASS ENV var.

You can monitor stats with the Base DN of cn=monitor. Like the cn=config
connection, you'll want to specify the Base DN, not just fetch it from
the LDAP server.

The accesslog database should be visible to the normal cn=Manager login,
but it's base is cn=accesslog in case it's not (I use Apache
DirectoryStudio and see it along side my main DB when I connect and
auth as cn=Manager).

Obviously, access to all these different databases can granted to other
logins by changing the olcAccessLog settings in the databases. These
settings can be found in cn=config.

