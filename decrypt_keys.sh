#!/bin/bash

set -o errexit -o pipefail

[[ $# -ne 1 ]] && exit 1

cd $1

read -p "Enter key passphrase (empty if none): " -s password
echo

tmp="$(mktemp -d --tmpdir decrypt_keys.XXXXXXXXXX)"

cleanup_keys() {
    rm -rf "$tmp"
}

trap cleanup_keys EXIT

export password

for key in releasekey platform shared media networkstack; do
    if [[ -n $password ]]; then
        openssl pkcs8 -in $key.pk8 -inform DER -passin env:password | openssl pkcs8 -topk8 -outform DER -out "$tmp/$key.pk8" -nocrypt
    fi
done

if [[ -f avb.pem ]]; then
    if [[ -n $password ]]; then
        openssl pkcs8 -in avb.pem -passin env:password | openssl pkcs8 -topk8 -out "$tmp/avb.pem" -nocrypt
    fi
fi

unset password

mv "$tmp"/* .
