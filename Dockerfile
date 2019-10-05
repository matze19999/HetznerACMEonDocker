#ACME LetsEncrypt Tool für staudigl-druck.de
# acme_wildcard:20190809

# Geschrieben von
# Matthias Pröll <matthias.proell@staudigl-druck.de>
# Staudigl-Druck GmbH & Co. KG
# Letzte Anpassung: 2019/08/23

FROM alpine:latest

# Labels
LABEL vendor="Staudigl-Druck GmbH & Co. KG"
LABEL maintainer="Matthias Pröll (matthias.proell@staudigl-druck.de)"
LABEL release-date="2019-08-09"

# Install Packages
RUN apk --update add certbot git python python-dev py-pip gcc linux-headers libc-dev libffi-dev openssl-dev libxml2-dev libxslt-dev && \
	rm -rf /var/cache/apk/*

RUN pip install dns-lexicon[full]

# Erstelle Scripte
RUN echo $'#!/bin/sh\n\
\n\
echo produktiv\n\
\n\
export LEXICON_HETZNER_USERNAME="$MAIL_ADDRESS"\n\
export LEXICON_HETZNER_PASSWORD="$PASSWORD"\n\
lexicon hetzner create $CERTBOT_DOMAIN TXT --name=_acme-challenge."$CERTBOT_DOMAIN" --content="$CERTBOT_VALIDATION"\n\
\n\
exit 0\n\
' >/authenticator.sh

RUN chmod +x /authenticator.sh


RUN echo $'#!/bin/sh\n\
\n\
echo cleanup\n\
\n\
export LEXICON_HETZNER_USERNAME="$MAIL_ADDRESS"\n\
export LEXICON_HETZNER_PASSWORD="$PASSWORD"\n\
lexicon hetzner delete DOMAIN.de TXT --name="_acme-challenge.DOMAIN.de"\n\
lexicon hetzner delete "$CERTBOT_DOMAIN" TXT --name=_acme-challenge."$CERTBOT_DOMAIN"\n\
\n\
exit 0\n\
' >/cleanup.sh

RUN chmod +x /cleanup.sh

# Create folder
RUN mkdir -p /certs


RUN echo $'#!/bin/sh\n\
\n\
if [ "$TESTRUN" = "true" ]; then\n\
    DEBUG="--dry-run"\n\
	echo "Debugmode, only demo certificates will be created!"\n\
fi\n\
\n\
if [ "$SSL_DOMAIN" = "" ]; then\n\
    read -p "For which domain you want to create certificates?     " -r\n\
    SSH_DOMAIN=$REPLY\n\
fi\n\
echo\n\
if [ "$SSL_AUTODEPLOY" = "false" ]; then\n\
    read -p "You really want to create the certificates now? [Y/N]    " -r\n\
    if [ "$REPLY" = "Y" ]; then\n\
        SSL_AUTODEPLOY="true"\n\
	elif [ "$REPLY" != "Y" ]; then\n\
		SSL_AUTODEPLOY="false"\n\
    fi\n\
fi\n\
\n\
if [ "$SSL_AUTODEPLOY" = "true" ]; then\n\
    echo\n\
    echo "Certificates for $SSL_DOMAIN will be created..."\n\
    echo\n\
    echo "This can take up to 15 minutes!"\n\
    echo\n\
    certbot certonly --manual --preferred-challenges=dns --email "EMAIL" --cert-path "/certs" --server "https://acme-v02.api.letsencrypt.org/directory" -d *.$SSL_DOMAIN --agree-tos --manual-public-ip-logging-ok --non-interactive --manual-auth-hook "/authenticator.sh" --manual-cleanup-hook "/cleanup.sh" "$DEBUG"\n\
    echo\n\
    mv /etc/letsencrypt/archive/* /certs/\n\
    echo "The created certificates are saved on /certs/"\n\
else\n\
    exit 0\n\
fi\n\
' >/run.sh

RUN chmod +x /run.sh

	
CMD /bin/sh /run.sh && tail -f /dev/null
