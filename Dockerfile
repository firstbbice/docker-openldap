FROM  alpine:3.11

ENV SLAPD_VER="2.6.1"
ENV SLAPD_URL="https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-$SLAPD_VER.tgz"
ENV CFLAGS=-O2

RUN apk update
RUN apk --update --no-cache add \
    curl wget build-base mdocml-soelim cyrus-sasl-dev argon2-dev libsodium-dev libtool musl-dev openssl-dev

# build slapd
RUN cd /tmp &&\
    wget $SLAPD_URL &&\
    tar xfz openldap-$SLAPD_VER.tgz && \
    cd openldap-$SLAPD_VER && \
    ./configure --prefix=/opt/slapd --enable-slapd --enable-mdb --enable-argon2 --enable-modules --with-tls --enable-accesslog --enable-overlays --enable-dds --enable-dyngroup --enable-dynlist --enable-ppolicy --enable-refint >& conf.log && \
    make depend && \
    make && \
    make install

FROM  alpine:3.11
COPY --from=0 /opt/slapd /opt/slapd
ENV LOGLEVEL="conns,filter,stats"

RUN apk update
RUN apk --update --no-cache add \
    curl cyrus-sasl argon2-libs libsodium libtool openssl man bash

# etc/openldap will be mounted from a volume
#RUN /bin/rm -rf /opt/slapd/etc/openldap

ENV PATH=/opt/slapd/bin:/opt/slapd/sbin:$PATH
ENV LD_LIBRARY_PATH=/opt/slapd/lib:/usr/lib
ENV MANPATH=/opt/slapd/share/man:/usr/share/man

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY overlay/slapd.ldif /opt/slapd/etc/openldap/slapd.ldif
COPY overlay/initial.ldif /opt/slapd/etc/openldap/initial.ldif
COPY overlay/accesslog.ldif /opt/slapd/etc/openldap/accesslog.ldif

# For debugging...
#RUN touch /tmp/t.t
#CMD [ "tail", "-f", "/tmp/t.t" ]

CMD [ "/usr/local/bin/entrypoint.sh" ]

