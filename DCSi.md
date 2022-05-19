
## DCSi Schema and examples

### What is DCSi?

The name is SGI Historical. I think it was an acronym for Data Center
System information (don't ask my why the i was lower-case - shrug - it
was before I got there and I just kept the name).

Short Version - It's a schema I made for LDAP to track assets like
servers, switches, contacts, applications, application owners, platforms,
etc. 

Longer Version - When I worked at SGI (Silicon Graphics Inc/Intl), we had an internally
developed tool to track assets like servers, built using perl, CGI, and Sybase,
and built by someone who had left the company a decade or so before I started.
It had data in it useful for the FNG (friggin' new guy) who had on-call
duties, letting me lookup a server name and find out what rack in which
room in what building that server was in. But it had "issues". Only one
person could make changes at a time without changes being lost.

So it was rarely up to date. And it gave up the ghost completely when we
closed a data center in Mtn. View, CA and we wound up keeping track of
where servers were using a myriad of spreadsheets. (yuck)

As a result, once the dust settled I made an LDAP schema to store all of the
same sorts of data (plus lots more) in LDAP. We could all use Apache
DirectoryStudio or other LDAP browser/editor tools to safely make changes
and I wrote some simple scripts using ssh and snmp to even automatically
update the database with things like Memory, CPU types, CPU speeds,
number of cores, OS versions, etc. 

Why bother? Well, it meant that with a simple php script to query this
LDAP server, I could tie all sorts of useful info into nagios, our
monitoring system. Got a
nagios alert for an application or server at 3 AM? One click in nagios
and you'd get (from LDAP) where the server was, what applications it ran
who owned the server, who owned each of the applications, build notes for
the server, build/troubleshooting notes for the applications, contact info,
physical location, how to get out-of-band console connections, where the
backups for that server lived, etc. 

We also used it to good effect when we had to apply patches. Remember
shellshock? I used ou=DCSi in LDAP to search for all the servers running
*nix that had an affected bash version. When we had some command that we
needed to run on every RedHat system, I could get the list of server names
with one ldapsearch command. These days people use things like ansible
for this, but it'd be pretty easy to keep ansible inventory files up to date
using a script that queried LDAP too. 

We even used it to keep track of spares. Retiring a server but not throwing
it out? Move if from ou=Servers to ou=Spares. Then the next time you need
a physical system with at least X gigs of memory and Y CPU cores, and
finding if you've got one (and where it is) is just an ldap search away.

### Example data

I loaded some fake example data under ou=DCSi. Take a peek. Many of the
attributes are just free-form text so use 'em however you want. Or heck,
use this as a springboard to make your own schema to track other stuff.
I made a prototype at one
point for keeping track of backup tape volumes (is Volume 12345
stored off-site? Which location? On-site? In which tape safe?)

### Why bring it back?

SGI is, sadly, no longer around having been bought by HPE. But I had
always intended to extend the schema to include nagios config information.
The idea was that our nagios configs would be built from the data in
LDAP. Spin up a new server running a new web service? Just copy/paste an
existing, similar server in LDAP, rename it, tweak it a little, and watch
while nagios automagically learns it should monitor a new server, what
it's parent hosts are (and other dependencies), what applications on the
new server to monitor, who should get the notifications, and at what level
(email only, text/pager but only 8x5 or maybe 24x7 time ranges, whatever).

I keep thinking it would be a fun project, but to do that I need to revive
DCSi first, so here it is. It's incredibly useful on it's own provided
you put useful data in it. While deciding what data to put into it, think
to yourself, "What data might a new, junior sysadmin might need when
woken up at 3 AM because something fell over.
Think, location,
build/troubleshooting notes, support-contract info, contacts for those
support contracts (and whatever serial numbers or other data you'll need),
how to get out-of-band access via iLO or some KVM server, etc. Anything
that might be useful to know. It might just mean the new junior admin will
be able fix the problem instead of having to escalate and wake you up to
ask questions!

### That's a lot of sensitive info!

Yeah, it is, so if you put DCSi into an LDAP server used for other
stuff and/or used by other people, you'll want to tweak your olcAccess
attributes in the cn=config directory to carefully govern access to
the ou=DCSi branch (or maybe just specific attributes). I'll leave that
as an exercise to the reader. Unless someone asks nicely. Then I might
be willing to make some more extensive example configs.

