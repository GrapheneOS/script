#!/bin/bash

set -o errexit

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

tmp="$(mktemp -d)"

export password
export new_password

for key in releasekey platform shared media networkstack; do
    if [[ -n $password ]]; then
        openssl pkcs8 -in $key.pk8 -inform DER -passin env:password | openssl pkcs8 -topk8 -outform DER -out "$tmp/$key.pk8" -passout env:new_password -scrypt
    else
        openssl pkcs8 -in $key.pk8 -inform DER -nocrypt | openssl pkcs8 -topk8 -outform DER -out "$tmp/$key.pk8" -passout env:new_password -scrypt
    fi
done

unset password
unset new_password

mv "$tmp"/* .
rmdir "$tmp"
