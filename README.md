# Privacy-Preserving Heart Diagnosis

Privacy-preserving heart disease prediction using Paillier partially homomorphic
encryption. A Flutter client encrypts a patient's clinical measurements on the
device, a Flask service runs a scikit-learn Random Forest over them, and the
prediction is returned encrypted under the patient's own public key.

> **Research prototype — not a medical device.** Predictions come from a model
> trained on 303 records and must not be used for diagnosis or treatment
> decisions. See [Threat model and known limitations](#threat-model-and-known-limitations)
> before citing this as a working privacy guarantee.

## Repository layout

| Path | What it is |
|---|---|
| `medical_app/` | Flutter client — patient form, key management, local SQLite storage |
| `he_services/` | Flask + Flask-RESTful API for key generation, encryption, and inference |
| `heart_disease_model/` | Training notebooks, dataset, and the serialized Random Forest |

## How it works

```
Flutter client                                      Flask service
--------------                                      -------------
1. request keypair   ---- GET  /generate_key_pair -->  Paillier keygen
   store (p, q)      <--------- {n}, {p, q} ---------

2. patient data      ---- POST /encrypt ----------->  encrypt under n
   ciphertexts       <--------- [(c, exp), ...] ----

3. ciphertexts       ---- POST /ml/classification ->  decrypt -> RF
   encrypted result  <--------- [(c, exp)] ---------  -> encrypt(y)

4. result            ---- POST /decrypt ----------->  decrypt
   0 or 1            <--------- [y] ----------------
```

The Paillier cryptosystem is *additively* homomorphic: given `E(a)` and `E(b)`
you can compute `E(a+b)` without the private key. That supports encrypted sums
and scalar multiplication, but a Random Forest needs comparisons and branching,
which Paillier cannot express. The model therefore operates on plaintext
server-side — only the transport and the returned prediction are encrypted.

## API

| Method | Endpoint | Purpose |
|---|---|---|
| `GET`  | `/api/phe/client/generate_key_pair` | Generate a Paillier keypair; returns public `n` and private `p`, `q` |
| `POST` | `/api/phe/client/encrypt` | Encrypt a list of values under a public key |
| `POST` | `/api/phe/client/decrypt` | Decrypt a list of ciphertexts with a keypair |
| `POST` | `/api/operations/ml/classification` | Predict heart disease; returns the result encrypted |

Keys are serialized as decimal strings because `n`, `p`, and `q` exceed the
range of a JSON number and would lose precision as IEEE-754 doubles.

### Example

```bash
# 1. generate a keypair
curl http://localhost:5000/api/phe/client/generate_key_pair

# 2. classify (values are ciphertexts from /encrypt when "sd" is true)
curl -X POST http://localhost:5000/api/operations/ml/classification \
  -H 'Content-Type: application/json' \
  -d '{
    "public_key":  {"n": "..."},
    "private_key": {"p": "...", "q": "..."},
    "values":      [["...", -32]],
    "columns":     ["age","sex","cp","trestbps","chol","fbs","restecg",
                    "thalach","exang","oldpeak","slope","ca","thal"],
    "sd": true
  }'
```

The `sd` flag means the payload carries ciphertexts that must be decrypted
before inference. Send `"sd": false` with plaintext `values` to skip that step.

## Running it

### Backend

```bash
cd he_services
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py                   # serves on http://0.0.0.0:5000
```

Python 3.10 is expected (see `runtime.txt`). The pinned `scikit-learn==1.2.2`
matches the version the model was serialized with — a different minor version
will raise `InconsistentVersionWarning` and may fail to unpickle.

Production is served by uwsgi via the `Procfile`:

```bash
uwsgi uwsgi.ini
```

### Flutter client

The repository contains only `lib/`, `assets/`, and `pubspec.yaml`. Generate the
platform folders before the first run:

```bash
cd medical_app
flutter create .                # regenerates android/, ios/, web/
flutter pub get
flutter run
```

The API host defaults to `http://10.0.2.2:5000` (the Android emulator's alias
for the host machine's localhost). Override it without editing source:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5000
```

Use `http://127.0.0.1:5000` for the iOS simulator or desktop targets.

## The model

A Random Forest classifier trained on the UCI Cleveland heart disease dataset
(303 records, 13 features), included at `heart_disease_model/data/heart-disease.csv`.

| | |
|---|---|
| Test accuracy | ~91.8% (hyperparameter-tuned, single split) |
| Cross-validated accuracy | ~88.5% |
| Features | age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak, slope, ca, thal |
| Target | 0 = no heart disease, 1 = heart disease |

Feature definitions are documented in
`medical_app/lib/models/patient/cardiology.dart`.

With 303 records and a single train/test split, the accuracy figure carries a
wide confidence interval — treat the cross-validated number as the honest one.

Re-train or verify:

```bash
cd heart_disease_model
python test_model.py
```

## Threat model and known limitations

These are stated plainly because the project's name implies guarantees it does
not yet fully deliver.

1. **The client sends its private key to the server.** The classification
   endpoint receives `private_key: {p, q}` and decrypts the features to run the
   model (`he_services/api/helper/pro.py`). A server that wanted the plaintext
   has it. In the current design encryption protects data in transit and at
   rest on the device, not from the inference server itself.

2. **Keys are generated server-side.** `/generate_key_pair` means the server
   sees the private key at creation. Generating the keypair on the device would
   remove one exposure.

3. **A Random Forest cannot run under Paillier.** Encrypted inference needs
   either a model expressible as additions and scalar multiplications (logistic
   regression scoring, linear models) or a fully homomorphic scheme such as
   CKKS or TFHE. Swapping the Random Forest for a linear model would let the
   server compute the score without ever decrypting.

4. **No transport security or authentication.** Endpoints are plain HTTP with
   no authn/authz and no rate limiting. Do not deploy as-is.

5. **`pickle` for model loading** executes arbitrary code on load. Safe for a
   self-hosted file you control; use `skops` or ONNX if the model ever comes
   from elsewhere.

Fixing (1) and (2) is the natural next step and would make the privacy claim
real for the transport layer; (3) is the research-interesting one.

### Reconstructed code

`he_services/api/helper/pro.py` was missing from the original source and has
been reconstructed from the client's request payload and the existing
`HE.decrypt` implementation. It is behaviour-compatible with what the endpoint
requires, but it is a reconstruction, not the original file.

## Fonts

The app was designed with SF Pro Display, which Apple's license does not permit
redistributing. Those files are not in this repository and the app falls back to
the platform default font. See `medical_app/assets/fonts/README.md` to restore
the intended typography or substitute Inter.

## License

MIT — see [LICENSE](LICENSE).

The UCI Cleveland heart disease dataset is public and redistributed here for
reproducibility.
