######################################################
FROM alpine:3.11 as relayer-builder

WORKDIR /usr/src/app

RUN apk add -U git nodejs npm python build-base make g++

RUN git clone https://github.com/tornadocash/relayer.git && \
    cd relayer && \ 
    npm i web3@1.2.4 && \
    npm i web3-utils@1.2.4 && \
    npm i && \
    npm cache clean --force

######################################################
FROM alpine:3.11 as builder

RUN apk update && \
    apk add git build-base libressl3.0-libssl libressl-dev

# Shallot onion key generator
RUN git clone https://github.com/katmagic/Shallot && \
    cd Shallot && \
    ./configure && \
    make

######################################################
FROM redis:alpine3.11

WORKDIR /usr/src/app
USER root

ENV NET_ID=42
ENV RPC_URL=http://kovan.dappnode:8545/
ENV ORACLE_RPC_URL=http://fullnode.dappnode:8545/
ENV REDIS_URL=redis://127.0.0.1:6379
ENV APP_PORT=8000

COPY --from=relayer-builder /usr/src/app /usr/src/app
COPY --from=builder /Shallot/shallot /usr/bin/shallot

RUN apk add -U --no-cache nodejs tor libressl3.0-libcrypto openssl nginx supervisor && \
    mkdir /run/nginx/

COPY start_tor.sh /usr/local/bin/
COPY start_relayer.sh /usr/local/bin/
COPY nginx.conf /etc/nginx/
COPY supervisord.conf /etc/supervisord/

RUN PASSWORD=$(echo $(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 20)) && \
    openssl genrsa -des3 -passout pass:${PASSWORD} -out server.pass.key 2048 && \
    openssl rsa -passin pass:${PASSWORD} -in server.pass.key -out server.key && \
    rm server.pass.key && \
    openssl req -new -key server.key -x509 -days 365 -out server.crt -addext extendedKeyUsage=serverAuth -addext subjectAltName=DNS:tornado-cash-relayer.public.dappnode -subj "/C=DE/ST=DAppNode/L=DAppNode/O=tornado-cash-relayer.public.dappnode/OU=community@dappnode.io/CN=tornado-cash-relayer.public.dappnode"
RUN mkdir -p /etc/nginx/certs/ && cp //usr/src/app/server.* /etc/nginx/certs/

#ENV TOR_USER=tord
# Create an unprivileged tor user
#RUN addgroup -g 19001 -S $TOR_USER && adduser -u 19001 -G $TOR_USER -S $TOR_USER && mkdir -p /home/tord/hidden && chown $TOR_USER:$TOR_USER /home/tord/hidden && chmod 660 /home/tord/hidden
RUN echo -e "Log notice file /var/log/notices.log\nHiddenServiceDir /hidden_service\nHiddenServicePort 443 localhost:443\nHiddenServicePort 80 localhost:80\n" >"/etc/tor/torrc" && \
    mkdir -p /hidden_service && \
    chmod 600 /hidden_service

###
# Lets Encrypt
###
RUN apk --update add openssl \
        augeas-libs certbot

ENTRYPOINT ["supervisord","-c","/etc/supervisord/supervisord.conf"]