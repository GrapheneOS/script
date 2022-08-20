#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -ne 1 ]] && user_error "expected 1 argument (key directory)"

cd $1

read -p "Enter old key passphrase (empty if none): " -s password
echo

read -p "Enter new key passphrase: " -s new_password
echo
read -p "Confirm new key passphrase: " -s confirm_new_password
echo

if [[ $new_password != $confirm_new_password ]]; then
    echo new password does not match
    exit 1
fi

tmp="$(mktemp -d /dev/shm/encrypt_keys.XXXXXXXXXX)"
trap "rm -rf \"$tmp\"" EXIT

export password
export new_password

for key in releasekey platform shared media networkstack sdk_sandbox bluetooth; do
    if [[ -n $password ]]; then
        openssl pkcs8 -inform DER -in $key.pk8 -passin env:password | openssl pkcs8 -topk8 -outform DER -out "$tmp/$key.pk8" -passout env:new_password -scrypt
    else
        openssl pkcs8 -topk8 -inform DER -in $key.pk8 -outform DER -out "$tmp/$key.pk8" -passout env:new_password -scrypt
    fi
done

if [[ -f avb.pem ]]; then
    if [[ -n $password ]]; then
        openssl pkcs8 -topk8 -in avb.pem -passin env:password -out "$tmp/avb.pem" -passout env:new_password -scrypt
    else
        openssl pkcs8 -topk8 -in avb.pem -out "$tmp/avb.pem" -passout env:new_password -scrypt
    fi
fi

unset password
unset new_password

mv "$tmp"/* .
