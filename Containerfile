FROM debian:trixie-slim as build-env

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade --yes \
  # install dependencies
  && apt install -y --no-install-recommends --no-install-suggests make gcc cvs zlib1g-dev openssl \
  && apt install -y --no-install-recommends --no-install-suggests curl \
  # make image smaller
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives \
  && rm -rf /tmp/* /var/tmp/*

WORKDIR /tmp

RUN cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co dietlibc \
  && cd dietlibc \
  && make \
  && install bin-x86_64/diet /usr/local/bin \
  && cd .. \
  && cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co libowfat \
  && cd libowfat \
  && diet make \
  && make install \
  && cd .. \
  && cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co gatling \
  && cd gatling \
  && diet make gatling \
  && install gatling /usr/local/bin \
  && rm -rf /tmp/*

FROM debian:trixie-slim as prod-env

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade --yes \
  # install dependencies
  && apt install -y --no-install-recommends --no-install-suggests curl \
  # make image smaller
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives \
  && rm -rf /tmp/* /var/tmp/*

COPY --from=build-env /usr/local/bin/* /usr/local/bin/

WORKDIR /srv

ENV GATLING_OPTS "-F -S -p 8000 -c /srv"

RUN echo "Hello World" > /srv/index.html

EXPOSE 8000

CMD gatling ${GATLING_OPTS}

HEALTHCHECK CMD curl -f "http://localhost:8000" || exit 1
