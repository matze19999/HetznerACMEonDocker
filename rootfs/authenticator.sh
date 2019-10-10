#!/bin/bash

echo "AUTHENTICATE...."
lexicon hetzner create $CERTBOT_DOMAIN TXT --name=_acme-challenge."$CERTBOT_DOMAIN" --content="$CERTBOT_VALIDATION"
exit 0