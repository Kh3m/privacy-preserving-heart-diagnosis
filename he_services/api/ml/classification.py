import json
import os

import phe as paillier
from flask_restful import Resource, request

from api.helper.he import HE

MODEL_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "ml_models",
    "heart_disease_logistic_regression.json",
)

# Smaller keys are factorable; refuse to compute under them.
MIN_KEY_BITS = 2048
# Aligning exponents costs a modular power of 16**|exponent|, so bound it.
MIN_EXPONENT = -32


class MyClassification(Resource):
    """Logistic regression evaluated on Paillier ciphertexts.

    The client sends E(x) under its own public key and receives
    E(w . x + b). The server never holds the private key and never sees
    the features or the score in plaintext.
    """

    _he = HE()
    _model = None

    def get(self):
        # The client needs the feature layout to one-hot encode before encrypting.
        return {"features": self.load_model()["features"]}

    def post(self):
        model = self.load_model()
        try:
            public_key, encrypted = self.parse(request.get_json(silent=True), len(model["weights"]))
        except (KeyError, TypeError, ValueError) as e:
            return {"message": f"invalid request: {e}"}, 400

        score = encrypted[0] * model["weights"][0]
        for x, w in zip(encrypted[1:], model["weights"][1:]):
            score += x * w
        score += model["intercept"]

        return self._he.serializeData(public_key, [score])

    @staticmethod
    def parse(data, n_features):
        public_key = paillier.PaillierPublicKey(n=int(data["public_key"]["n"]))
        if public_key.n.bit_length() < MIN_KEY_BITS:
            raise ValueError(f"public key must be at least {MIN_KEY_BITS} bits")

        values = data["values"]
        if len(values) != n_features:
            raise ValueError(f"expected {n_features} values, got {len(values)}")

        encrypted = []
        for ciphertext, exponent in values:
            ciphertext, exponent = int(ciphertext), int(exponent)
            if not 0 < ciphertext < public_key.nsquare:
                raise ValueError("ciphertext out of range")
            if not MIN_EXPONENT <= exponent <= 0:
                raise ValueError(f"exponent must be in [{MIN_EXPONENT}, 0]")
            encrypted.append(paillier.EncryptedNumber(public_key, ciphertext, exponent))
        return public_key, encrypted

    @classmethod
    def load_model(cls):
        # Read once per process rather than on every request.
        if cls._model is None:
            with open(MODEL_PATH) as f:
                cls._model = json.load(f)
        return cls._model
