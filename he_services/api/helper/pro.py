"""Recovers plaintext feature values from a Paillier-encrypted request payload.

The Flutter client encrypts each clinical feature client-side and posts the
ciphertexts to /api/operations/ml/classification together with the keypair.
The Random Forest cannot operate on ciphertext, so the values are decrypted
here before being handed to the model.

NOTE: this requires the client to transmit its PRIVATE key to the server, which
defeats the privacy guarantee the encryption is meant to provide. See the
"Threat model and known limitations" section of the README.
"""

import phe as paillier


def process(data):
    """Decrypt data["values"] and return them as a list of plain numbers.

    Args:
        data: request body containing "public_key" {n}, "private_key" {p, q}
            and "values", a list of [ciphertext_str, exponent] pairs as
            produced by /api/phe/client/encrypt.

    Returns:
        A list of decrypted numeric feature values, ordered as received.
    """
    public_key = paillier.PaillierPublicKey(n=int(data["public_key"]["n"]))
    private_key = paillier.PaillierPrivateKey(
        public_key,
        int(data["private_key"]["p"]),
        int(data["private_key"]["q"]),
    )
    encrypted = [
        paillier.EncryptedNumber(public_key, int(value), int(exponent))
        for value, exponent in data["values"]
    ]
    return [private_key.decrypt(x) for x in encrypted]
