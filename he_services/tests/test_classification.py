"""Run from he_services/:  python -m unittest discover tests"""

import math
import unittest

import phe as paillier

from api.ml.classification import MyClassification
from app import app

URL = "/api/operations/ml/classification"

# Two records from heart_disease_model/data/heart-disease.csv: the first has no
# heart disease, the second has it (the CSV's target column is inverted, 1 = none).
PATIENTS = [
    {"age": 63, "sex": 1, "cp": 3, "trestbps": 145, "chol": 233, "fbs": 1, "restecg": 0,
     "thalach": 150, "exang": 0, "oldpeak": 2.3, "slope": 0, "ca": 0, "thal": 1},
    {"age": 57, "sex": 0, "cp": 0, "trestbps": 140, "chol": 241, "fbs": 0, "restecg": 1,
     "thalach": 123, "exang": 1, "oldpeak": 0.2, "slope": 1, "ca": 0, "thal": 3},
]


def encode(patient, features):
    return [
        float(patient[f["column"]]) if "equals" not in f
        else float(patient[f["column"]] == f["equals"])
        for f in features
    ]


class EncryptedClassificationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()
        cls.public_key, cls.private_key = paillier.generate_paillier_keypair()
        cls.model = MyClassification.load_model()

    def request(self, x, public_key=None):
        public_key = public_key or self.public_key
        return {
            "public_key": {"n": str(public_key.n)},
            "values": [(str(c.ciphertext()), c.exponent) for c in map(public_key.encrypt, x)],
        }

    def test_score_matches_plaintext(self):
        features = self.client.get(URL).get_json()["features"]
        for patient in PATIENTS:
            x = encode(patient, features)
            res = self.client.post(URL, json=self.request(x))
            self.assertEqual(res.status_code, 200)

            c, exponent = res.get_json()["values"][0]
            score = self.private_key.decrypt(
                paillier.EncryptedNumber(self.public_key, int(c), int(exponent)))
            expected = sum(w * v for w, v in zip(self.model["weights"], x)) + self.model["intercept"]
            self.assertTrue(math.isclose(score, expected, rel_tol=1e-9, abs_tol=1e-9))

    def test_request_carries_no_private_key(self):
        body = self.request([0.0] * len(self.model["weights"]))
        self.assertNotIn("private_key", body)
        self.assertEqual(self.client.post(URL, json=body).status_code, 200)

    def test_rejects_wrong_feature_count(self):
        res = self.client.post(URL, json=self.request([1.0, 2.0]))
        self.assertEqual(res.status_code, 400)

    def test_rejects_small_key(self):
        small, _ = paillier.generate_paillier_keypair(n_length=512)
        res = self.client.post(URL, json=self.request([0.0] * len(self.model["weights"]), small))
        self.assertEqual(res.status_code, 400)

    def test_rejects_malformed_body(self):
        self.assertEqual(self.client.post(URL, json={"values": []}).status_code, 400)
        self.assertEqual(self.client.post(URL, data="not json").status_code, 400)


if __name__ == "__main__":
    unittest.main()
