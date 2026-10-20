# Privacy-Preserving Heart Diagnosis

This project predicts heart disease without the server ever seeing the
patient's data.

It uses Paillier encryption. The Flutter app creates the keys and encrypts the
patient's measurements on the phone. The Flask server runs the model on the
encrypted numbers and sends back an encrypted result. Only the phone can
decrypt it. The server never gets the private key, so it can't read the
patient's data or the prediction.

> **This is a research prototype, not a medical device.** The model was trained
> on only 303 patient records. Do not use it to diagnose or treat anyone. See
> [Limitations](#limitations).

> **Looking for the version in the paper?** It is saved in git under the tag
> `paper-v1`. Run `git checkout paper-v1` to see it, including the notebooks
> behind the paper's numbers. See [Changes since the paper](#changes-since-the-paper).

## Folders

| Folder | What's inside |
|---|---|
| `medical_app/` | The Flutter app. The encryption code is in `lib/crypto/paillier.dart`. |
| `he_services/` | The Flask server that runs the model on encrypted data |
| `heart_disease_model/` | The dataset, the training script and the evaluation notebook |

## How it works

```
Phone (has the private key)                     Server (has the model)
---------------------------                     ----------------------
1. Create a key pair

2. Ask for the input format  --- GET ---->
                             <-- format --

3. Turn the form into 27 numbers
   and encrypt each one

4. Send the encrypted numbers --- POST --->  Compute the encrypted score
   and the public key                        (no private key needed)
                             <-- encrypted score --

5. Decrypt the score.
   Above 0 means heart disease.
```

**Why the server can compute without decrypting.** With Paillier encryption,
anyone can do two things to encrypted numbers without the private key:

- add two encrypted numbers together
- multiply an encrypted number by a normal number

A logistic regression only needs those two steps. It multiplies each input by a
weight, adds everything up, and adds a constant. So the server can work out the
score while it is still encrypted. The phone then decrypts it. A score above 0
means the model thinks the chance of heart disease is more than 50%.

**Why 27 numbers instead of 13.** Some fields are categories, not amounts. For
example, chest pain type (`cp`) is a label, so `cp = 2` is not "twice" `cp = 1`.
The app turns each category field into a set of yes/no values (this is called
one-hot encoding). This has to happen on the phone before encryption, because
the server can't do it to an encrypted number. The 13 form fields become 27
numbers.

The Dart encryption code produces exactly the same format as the Python
[python-paillier](https://github.com/data61/python-paillier) library that the
server uses.

## API

| Method | Address | What it does |
|---|---|---|
| `GET`  | `/api/operations/ml/classification` | Returns the list of 27 inputs the app must send, in order |
| `POST` | `/api/operations/ml/classification` | Takes encrypted inputs and returns the encrypted score |

Keys and encrypted numbers are sent as text, not as JSON numbers. They are too
big for JSON numbers and would lose digits.

```bash
curl -X POST http://localhost:5000/api/operations/ml/classification \
  -H 'Content-Type: application/json' \
  -d '{
    "public_key": {"n": "..."},
    "values":     [["<encrypted number>", -8], ...]
  }'
# Reply: {"public_key": {"n": "..."}, "values": [["<encrypted score>", -23]]}
```

The server refuses a request if:

- the key is shorter than 2048 bits (short keys can be broken)
- it doesn't have exactly 27 values
- an encrypted number is out of range
- an exponent is not between -32 and 0

## How to run it

### Server

```bash
cd he_services
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py                   # runs on http://0.0.0.0:5000
python -m unittest discover tests
```

Use Python 3.10 (see `runtime.txt`). In production the server runs with uwsgi
(see `Procfile`):

```bash
uwsgi uwsgi.ini
```

### App

The repository only has `lib/`, `assets/`, `test/` and `pubspec.yaml`. Create
the platform folders before the first run:

```bash
cd medical_app
flutter create .                # creates android/, ios/, web/
flutter pub get
flutter test
flutter run
```

By default the app talks to `http://10.0.2.2:5000`. That is how the Android
emulator reaches your computer. To use a different address:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:5000
```

For the iOS simulator or a desktop build, use `http://127.0.0.1:5000`.

## The model

The model is a logistic regression trained on the UCI Cleveland heart disease
dataset: 303 patients and 13 measurements each. The data is in
`heart_disease_model/data/heart-disease.csv`.

### Why logistic regression

The model has to run on encrypted numbers, so it can only add and multiply.
That rules out the paper's Random Forest, which needs comparisons ("is age
above 55?"). It also rules out KNN, which needs distances between patients.

So the real question was: do we lose accuracy by using a simpler model? We
don't. We tested four models the same way. Each model was trained and tested 50
times on different splits of the data (5-fold cross-validation, repeated 10
times). The table shows the average, and the ± shows how much the result
varied between runs.

| Model | Works encrypted? | Accuracy | Precision | Recall | F1 | ROC AUC |
|---|---|---|---|---|---|---|
| Random Forest (paper) | no | 0.822 ± 0.046 | 0.826 ± 0.055 | 0.859 ± 0.065 | 0.840 ± 0.042 | 0.904 ± 0.034 |
| KNN (k=5) | no | 0.816 ± 0.049 | 0.812 ± 0.055 | 0.869 ± 0.063 | 0.837 ± 0.042 | 0.877 ± 0.043 |
| Logistic regression, 13 inputs | yes | 0.830 ± 0.040 | 0.816 ± 0.046 | 0.892 ± 0.063 | 0.850 ± 0.037 | 0.897 ± 0.039 |
| **Logistic regression, 27 inputs (used)** | **yes** | **0.851 ± 0.050** | **0.852 ± 0.065** | **0.886 ± 0.059** | **0.866 ± 0.044** | **0.918 ± 0.035** |

What this shows:

- **The model we use is the best of the four.** It has the highest accuracy,
  precision, F1 and ROC AUC. It beat the Random Forest in 33 of the 50 runs,
  tied in 10 and lost in 7.
- **One-hot encoding helps.** Using 27 inputs instead of 13 adds about 2
  percentage points of accuracy. The cost is 27 encryptions per prediction
  instead of 13.
- **It misses fewer sick patients.** Recall is about 0.89, compared with 0.86
  for the Random Forest. For a screening tool, missing a sick patient is the
  worst mistake.
- **Encryption doesn't change the answer.** We sent all 303 patients through
  the encrypted server. Every prediction was the same as without encryption.

The full analysis is in `heart_disease_model/encrypted-model-evaluation.ipynb`.

**About the 91.8% in the paper.** That number, and 88.5%, each come from
testing on one split of 61 patients. Small test sets give very different
results depending on which patients land in them. We tested the same Random
Forest on 30 different random splits and got anywhere from 72.1% to 90.2%. So
you can't compare a one-split number with the averages above.

To retrain the model:

```bash
cd heart_disease_model
pip install -r requirements.txt
python train_encrypted_model.py
```

This saves the model weights to
`he_services/ml_models/heart_disease_logistic_regression.json`. It also checks
that the saved weights give exactly the same scores as the trained model.

## Speed

We measured 30 predictions with a 2048-bit key. The app code and the server
both ran on the same desktop computer, so there was no network delay and no
phone. The table shows the middle (median) time.

| Step | Where | Time |
|---|---|---|
| Create key pair (once) | phone | 0.55 s |
| Encrypt 27 numbers | phone | 1.96 s |
| Compute the score | server | 0.30 s |
| Decrypt the score | phone | 0.07 s |
| **One prediction, start to finish** | | **2.3 s** |

On a real phone, encryption will probably be slower.

## Limitations

**What is protected:** the server, and anyone watching the network, only sees
the public key and encrypted numbers. The private key is created and kept on
the phone, so the server can't read the patient's data or the result.

**What is not protected:**

1. **The model is not secret.** The server stores the model weights as normal
   numbers. The phone gets the exact score back, so someone could send about 28
   carefully chosen requests and work out the weights. That's fine for a public
   model.
2. **The server is trusted to compute honestly.** A dishonest server could send
   back any encrypted number. Nothing proves the score came from the real
   model.
3. **There is no HTTPS and no login.** Anyone can call the server, and there is
   no limit on requests. Don't put it on the internet as it is.
4. **The private key is not protected on the phone.** It is stored as plain
   text in the app's SQLite database. Moving it to the phone's secure storage
   (for example `flutter_secure_storage`) would fix this.
5. **Some form hints don't match the training data.** The app says `cp` goes
   from 1 to 4 and `thal` is 1, 3, 6 or 7. In the training data both go from 0
   to 3. If a value isn't in the training data, all of its yes/no inputs become
   0.

## Changes since the paper

In the published version (tag `paper-v1`), data was encrypted while travelling
but decrypted on the server. The app sent its private key with every request.
The server also created the keys, and the app sent the raw measurements to a
server `/encrypt` address. The server had to decrypt because a Random Forest
can't run on encrypted numbers.

This version:

- uses a logistic regression instead of the Random Forest
- creates the keys, encrypts and decrypts on the phone
- removes every server address that received a private key or raw data

Code that the new version no longer uses has been deleted: the paper's
notebooks and Random Forest, the old server code, and seven Dart files that
nothing used. You can still see all of it in the `paper-v1` tag. To print one
old file, run `git show paper-v1:<path>`.

The accuracy and speed numbers in this README are for this version, not the
paper's.

## Fonts

The app was designed with the SF Pro Display font. Apple's license doesn't
allow sharing it, so it isn't included and the app uses the default font. See
`medical_app/assets/fonts/README.md` to add it back or use Inter instead.

## License

MIT. See [LICENSE](LICENSE).

The UCI Cleveland heart disease dataset is public and is included so you can
reproduce the results.
