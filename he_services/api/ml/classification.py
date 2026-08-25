import os
import pickle

import numpy as np
import pandas as pd
import phe as paillier
from flask_restful import Resource, request

from api.helper.he import HE
from api.helper.pro import process

MODEL_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "ml_models",
    "heart_disease_random_forest_model.pkl",
)


class MyClassification(Resource):
    _he = HE()
    _model = None

    def post(self):
        data = request.get_json()
        if data.get("sd"):
            data["values"] = process(data)
        df = pd.DataFrame(
            np.array(data["values"]).reshape(1, -1),
            columns=data["columns"],
        )
        y_pred = self.load_model().predict(df)
        public_key = paillier.PaillierPublicKey(n=int(data["public_key"]["n"]))
        encrypted_data_list = [public_key.encrypt(float(x)) for x in y_pred.tolist()]
        return self._he.serializeData(public_key, encrypted_data_list)

    @classmethod
    def load_model(cls):
        # Unpickled once per process rather than on every request.
        if cls._model is None:
            with open(MODEL_PATH, "rb") as f:
                cls._model = pickle.load(f)
        return cls._model
