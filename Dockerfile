#ACME LetsEncrypt Tool for Hetzner
# matze19999/acme_wildcard:20191010

FROM alpine:latest

COPY /rootfs /

# Labels
LABEL vendor="Staudigl-Druck GmbH & Co. KG"
LABEL maintainer="Matthias Pröll (matthias.proell@staudigl-druck.de)"
LABEL release-date="2019-09-03"

# Installiere Pakete
RUN apk --update add openssl bash certbot git python python-dev py-pip gcc linux-headers libc-dev libffi-dev openssl-dev libxml2-dev libxslt-dev && \
	rm -rf /var/cache/apk/*

RUN pip install dns-lexicon[hetzner]

RUN chmod +x /authenticator.sh /run.sh /cleanup.sh

# Erstelle Ordner
RUN mkdir -p /certs

CMD /bin/sh /run.sh && tail -f /dev/null
