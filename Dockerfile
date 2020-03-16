FROM alpine:latest

LABEL maintainer="Hugo Bulnes <hugobulnes@hotmail.com>"
LABEL version="1.0"
LABEL description="Asterisk image to test dialplan"

ENV DB_PASS toor 

###
# Installing dependencies
RUN apk add python py-pip python-dev git gcc g++ linux-headers patch lua \
    lua-dev libc-dev ncurses-dev openssl-dev libpcap-dev alsa-lib-dev \
    libxml2-dev libxslt-dev automake gdb libressl-dev lksctp-tools-dev make \ 
    asterisk asterisk-sample-config sqlite-dev mysql-client mariadb

# Installing python dependencies
RUN pip install PyYAML && pip install Twisted lxml setuptools Cython

# Finishing DB Installation
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    cp /usr/share/mariadb/mysql.server /etc/init.d/

# Downloading and Installing SIPp
RUN wget https://github.com/SIPp/sipp/releases/download/v3.6.0/sipp-3.6.0.tar.gz -P /opt/ && \ 
    tar -zxvf /opt/sipp-3.6.0.tar.gz -C /opt/ && \
    cd /opt/sipp-3.6.0 && ./configure --with-pcap --with-openssl && make install && \
    rm /opt/sipp-3.6.0.tar.gz

# Downloading the testsuite
RUN mkdir -p /opt/testsuite && \
    git clone https://github.com/asterisk/testsuite.git /opt/testsuite

# Installing asttest
RUN cd /opt/testsuite/asttest &&  make && make install

# Installing starpy
RUN cd /opt/testsuite/addons && make update && cd starpy && python setup.py install

# Downloading and Installing pjproject
RUN mkdir -p /opt/pjproject && \
    git clone https://github.com/pjsip/pjproject.git /opt/pjproject && \
    cd /opt/pjproject && ./configure CFLAGS=-fPIC && \
    echo "#define PJ_HAS_IPV6 1" >> pjlib/include/pj/config_site.h && \
    make dep && make clean && make && \
    cp pjsip-apps/bin/pjsua-x86_64-unknown-linux-gnu /usr/sbin/pjsua && \
    cd /opt/pjproject/pjsip-apps/src/python && python setup.py install

# Downloading and Installing yappcap
RUN mkdir -p /opt/yappcap && \ 
    git clone https://github.com/otherwiseguy/yappcap.git /opt/yappcap && \
    cd /opt/yappcap && make && make install

# Copy scripts
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

COPY ./script-runner.sh /
RUN chmod +x /script-runner.sh && mkdir /scripts

ENTRYPOINT ["/bin/sh","/docker-entrypoint.sh"]
