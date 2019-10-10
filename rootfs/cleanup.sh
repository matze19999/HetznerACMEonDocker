#!/bin/bash

echo "CLEANUP..."

for item in $SSL_DOMAIN
do
    lexicon hetzner delete "$CERTBOT_DOMAIN" TXT --name="_acme-challenge.$CERTBOT_DOMAIN"
    exit 0
done
exit 0
