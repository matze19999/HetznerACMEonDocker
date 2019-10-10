#!/bin/bash

days=`eval "echo $(date -ud "@$SSLTTL" +'$((%s/3600/24)) Tage')"`

function getcertificate() {

    if [ "$SSL_AUTODEPLOY" = "true" ]; then
            local certificate=$1
            openssl x509 -checkend $SSLTTL -noout -in "/certs/$certificate.pem" > /dev/null 2>&1
            if [ "$?" = "1" ]; then
                echo
                echo "Zertifikate für $certificate werden erstellt..."
                echo
                echo "Das Ausstellen der Zertifikate kann einige Minuten pro Zertifikat in Anspruch nehmen, bitte nicht das Script oder den Tab beenden!"
                echo
                certbot certonly --manual --preferred-challenges=dns --email "it-support@staudigl-druck.de" --server "https://acme-v02.api.letsencrypt.org/directory" -d *.$certificate -d $certificate --agree-tos --manual-public-ip-logging-ok --non-interactive $DEBUG --manual-auth-hook "/authenticator.sh" --manual-cleanup-hook "/cleanup.sh"
                echo
                cat /etc/letsencrypt/archive/$certificate/* > /certs/$certificate.pem
                echo "Das fertige Zertifikat liegen unter /certs/"
                echo "$certificate.pem muss im Pound eingetragen werden"
            else
                echo "Zertifikat $certificate ist noch mindestestens $days gültig!"
                echo
            fi
    else
            exit 0
    fi
}

    if [ "$TESTRUN" = "true" ]; then
        DEBUG="--dry-run"
        echo "Debugmodus, es werden nur Demo Zertifikate ausgestellt!"
    fi
    echo
    if [ "$SSL_DOMAIN" = "" ]; then
        read -p "Für welche Domain(s) möchtest du die Zertifikate ausstellen?     " -r
        SSL_DOMAIN=$REPLY
    fi
    echo
    if [ "$SSL_AUTODEPLOY" = "false" ]; then
        read -p "Möchtest du Zertifikate wirklich jetzt ausstellen? [J/N]    " -r
        if [ "$REPLY" = "J" ]; then
            SSL_AUTODEPLOY="true"
        elif [ "$REPLY" != "J" ]; then
            SSL_AUTODEPLOY="false"
        fi
    fi

for item in $SSL_DOMAIN
do
    getcertificate $item
done

echo "Warte 24h bis zur nächsten Prüfung..."
while sleep "86400"; do
    for item in $SSL_DOMAIN
    do
        getcertificate $item
    done
done
exit 1