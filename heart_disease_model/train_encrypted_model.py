"""Train the logistic regression used for encrypted inference.

A Random Forest cannot be evaluated under Paillier encryption, which only
supports adding ciphertexts and multiplying them by plaintext constants. A
logistic regression score is exactly that: w . x + b. So the server can compute
E(w . x + b) from E(x) without ever decrypting, and the client decrypts the
score and applies the 0 threshold itself.

Categorical features are one-hot encoded on the client before encryption (the
server cannot one-hot an encrypted value). Standardization of the numeric
features is folded into the exported weights, so the client encrypts raw
values and the server needs only the weights.

Usage:
    python train_encrypted_model.py

Writes ../he_services/ml_models/heart_disease_logistic_regression.json
"""

import json
import os

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import RepeatedStratifiedKFold, cross_val_score
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler

HERE = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(HERE, "data", "heart-disease.csv")
OUT_PATH = os.path.join(
    HERE, "..", "he_services", "ml_models", "heart_disease_logistic_regression.json"
)

CATEGORICAL = ["cp", "restecg", "slope", "ca", "thal"]
C = 0.3  # chosen by repeated CV over C in {0.03, 0.1, 0.3, 1}


def build_pipeline(numeric):
    columns = ColumnTransformer([
        ("num", StandardScaler(), numeric),
        ("cat", OneHotEncoder(handle_unknown="ignore"), CATEGORICAL),
    ])
    return make_pipeline(columns, LogisticRegression(C=C, max_iter=5000))


def export(pipeline, numeric):
    """Fold the scaler into the weights and describe the client-side encoding."""
    columns, model = pipeline.steps[0][1], pipeline.steps[1][1]
    scaler = columns.named_transformers_["num"]
    encoder = columns.named_transformers_["cat"]
    coef = model.coef_[0]

    features, weights = [], []
    intercept = float(model.intercept_[0])

    # w * (x - mu) / sd  ==  (w / sd) * x  -  w * mu / sd
    for name, w, mu, sd in zip(numeric, coef[:len(numeric)], scaler.mean_, scaler.scale_):
        features.append({"column": name})
        weights.append(float(w / sd))
        intercept -= float(w * mu / sd)

    i = len(numeric)
    for name, categories in zip(CATEGORICAL, encoder.categories_):
        for value in categories:
            features.append({"column": name, "equals": int(value)})
            weights.append(float(coef[i]))
            i += 1

    return {
        "model": "logistic_regression",
        "features": features,
        "weights": weights,
        "intercept": intercept,
    }


def encode(row, features):
    return np.array([
        row[f["column"]] if "equals" not in f else float(row[f["column"]] == f["equals"])
        for f in features
    ])


def main():
    df = pd.read_csv(DATA_PATH)
    X, y = df.drop("target", axis=1), df["target"]
    numeric = [c for c in X.columns if c not in CATEGORICAL]

    cv = RepeatedStratifiedKFold(n_splits=5, n_repeats=10, random_state=42)
    scores = cross_val_score(build_pipeline(numeric), X, y, cv=cv)
    print(f"Repeated 5-fold CV accuracy: {scores.mean():.4f} +/- {scores.std():.4f}")

    pipeline = build_pipeline(numeric).fit(X, y)
    spec = export(pipeline, numeric)
    spec["cv_accuracy"] = round(float(scores.mean()), 4)

    # The folded weights must reproduce the pipeline's score exactly.
    w, b = np.array(spec["weights"]), spec["intercept"]
    folded = np.array([encode(row, spec["features"]) for _, row in X.iterrows()]) @ w + b
    assert np.allclose(folded, pipeline.decision_function(X)), "weight folding is wrong"

    with open(OUT_PATH, "w") as f:
        json.dump(spec, f, indent=2)
    print(f"Wrote {len(spec['features'])} weights to {os.path.normpath(OUT_PATH)}")


if __name__ == "__main__":
    main()
