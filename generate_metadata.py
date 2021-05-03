#!/usr/bin/env python3

from argparse import ArgumentParser
from os import path
from re import search
from subprocess import Popen, PIPE, STDOUT
from zipfile import ZipFile


def sign_string_base64(string_to_sign, key_path, key_type):
    """
    Signs a string using the provided key, and returns the base64-encoded signature (in one line).
    """
    echo_process = Popen(["echo", "-n", string_to_sign],
                         stdout=PIPE, stderr=STDOUT, universal_newlines=True)

    sign_cmd = ["openssl", "dgst", "-sha256", "-keyform", "DER", "-sign", key_path]
    if key_type == "rsa":
        # use RSASSA-PSS as required by PKCS#1 for new applications
        sign_cmd += ["-sigopt", "rsa_padding_mode:pss", "-sigopt", "rsa_pss_saltlen:digest"]
    sign_process = Popen(sign_cmd,
                         stdin=echo_process.stdout, stdout=PIPE, stderr=STDOUT, universal_newlines=True)

    base64_process = Popen(["openssl", "base64", "-A"],
                           stdin=sign_process.stdout, stdout=PIPE, stderr=STDOUT, universal_newlines=True)

    result, _ = base64_process.communicate()
    if base64_process.returncode != 0:
        raise Exception(f"Failed to sign: Got result: {result}")
    return result


def determine_key_type(key):
    signature_process = Popen(["openssl", "asn1parse", "-inform", "DER", "-in", key,
                               "-item", "PKCS8_PRIV_KEY_INFO"],
                              stdout=PIPE, stderr=STDOUT, universal_newlines=True)
    result, _ = signature_process.communicate()
    algorithm_line = search('(algorithm: )(.*)', result)
    if algorithm_line is None:
        raise Exception(f"Failed to find privateKeyAlgorithm for the private key")
    private_key_algorithm = algorithm_line.group(2)
    if private_key_algorithm.startswith("rsaEncryption"):
        return "rsa"
    elif private_key_algorithm.startswith("id-ecPublicKey"):
        return "ec"
    else:
        raise Exception(f"Only RSA and EC keytypes are supported, but got {algorithm_line}")


parser = ArgumentParser(description="Generate signed update server metadata")
parser.add_argument("zip",
                    help="The OTA zip file created by ota_from_target_files")
parser.add_argument("decrypted_release_key",
                    help="A decrypted private key in PKCS#8 format used to sign the metadata")

input_args = parser.parse_args()
signing_key = input_args.decrypted_release_key
key_type = determine_key_type(signing_key)
zip_path = input_args.zip
with ZipFile(zip_path) as f:
    with f.open("META-INF/com/android/metadata") as metadata:
        data = dict(line[:-1].decode().split("=") for line in metadata)
        for channel in ("beta", "stable", "testing"):
            metadata_path = path.join(path.dirname(zip_path), data["pre-device"] + "-" + channel)
            with open(metadata_path, "w") as output:
                build_id = data["post-build"].split("/")[3]
                incremental = data["post-build"].split("/")[4].split(":")[0]
                metadata_line = f'{incremental} {data["post-timestamp"]} {build_id} {channel} {data["pre-device"]}'
                print(metadata_line, file=output)

                print(f"signing metadata: {metadata_path} ({signing_key})")
                print(sign_string_base64(metadata_line, signing_key, key_type), file=output)
