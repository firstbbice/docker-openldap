
### A docker image for spinning up openldap's slapd

This docker image grabs the openldap source and builds slapd and
installs it in /opt/slapd. 

In order to use it you MUST supply at least two volumes.
- **slapd.d**: Mounted to /opt/slapd/etc/slapd.d (REQUIRED)
- **openldap**: Mounted to /opt/slapd/etc/openldap (REQUIRED)
- **openldap-data**: Mounted to /opt/slapd/var/openldap-data (OPTIONAL)

The slapd.d volume will contain your config database. If empty, slapd
will build one from what it finds in your config files in etc/openldap.

The openldap volume must contain your config files describing the ldap
server you wish to have, including schema files.

The open-ldap-data volume is where your LDAP database/s, other than the
config database, will be stored. If it's empty, slapd will build empty
database files when started. If you do NOT supply an openldap-data volume,
then every time this docker image is started you will have an empty database.

### Example command to startup image

**docker run -v `pwd`/volumes/slapd.d:/opt/slapd/etc/slapd.d -v `pwd`/volumes/openldap:/opt/slapd/etc/openldap -v `pwd`/volumes/openldap-data:/tmp/openldap-data -p 8389:389 slapd**

This command will start slapd and have it listen on port 8389 on your system.

### Post startup steps

Once you start slapd the first time, it'll have an empty database. You can
populate it by connecting to it with Apache DirectoryStudio and then importing
an LDIF file containing your data. A sample file can be found in
volumes/openldap/initial.ldif

