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
| `heart_disease_model/` | The dataset and `heart-disease-experiment.ipynb`, which trains, tests and saves the model |

## How it works

```
Phone (has the private key)                     Server (has the model)
---------------------------                     ----------------------
1. Create a key pair

2. Ask for the input format  --- GET ---->
                             <-- format --

3. Turn the form answers into 27 numbers
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
In the app, the user picks these from a list of plain options, like "Typical
angina". The app converts each choice to the code used in the training data,
then turns each category field into a set of yes/no values (this is called
one-hot encoding). This has to happen on the phone before encryption, because
the server can't do it to an encrypted number. The 13 form fields become 27
numbers.

The Dart encryption code produces exactly the same format as the Python
[python-paillier](https://github.com/data61/python-paillier) library that the
server uses.

## Why Paillier and not fully homomorphic encryption

There are three kinds of homomorphic encryption:

| Kind | What it can do on encrypted data | Examples |
|---|---|---|
| Partial (PHE) | One kind of operation, as often as needed. Paillier can add, and multiply by normal numbers. | Paillier |
| Somewhat (SHE) | Add, and multiply encrypted numbers together a limited number of times | BFV, CKKS |
| Fully (FHE) | Any calculation | TFHE, CKKS with bootstrapping |

**Where the cost is.** FHE is known for being slow, but the slow part runs on
the server: multiplying encrypted numbers together, and especially
bootstrapping (the step that makes unlimited calculations possible). The phone
only creates keys, encrypts and decrypts, which is cheap in every scheme. So
SHE and FHE can run on a phone too.

We chose Paillier because:

- **It is all the model needs.** The score is the server's own weights times
  the encrypted inputs, added up. Two encrypted numbers are never multiplied
  together, so SHE and FHE would add power we don't use.
- **It is light for a phone app.** Each encrypted value is 4096 bits
  (512 bytes), and the keys are just two large primes. SHE and FHE use much
  larger ciphertexts, and the server also needs extra keys that are often
  several megabytes. The main SHE and FHE libraries, such as Microsoft SEAL and
  OpenFHE, are written in C++, so a Flutter app would need native bindings.
  Paillier only needs big-number maths, which Dart has built in.
- **The results are exact.** CKKS, the usual choice for machine learning, gives
  approximate results. Our encrypted scores match the normal ones to within
  1e-15.
- **It is simple and well studied.** The only setting to choose is the key
  size. SHE and FHE need several settings that trade security against speed
  and precision.

SHE or FHE would be the better choice to:

- **encrypt faster.** CKKS can pack all 27 inputs into one ciphertext and
  encrypt them in one go. Paillier encrypts each value on its own, which is
  why encryption is the slowest step in our [speed test](#speed).
- **resist quantum computers.** Paillier is safe only while large numbers
  can't be factored. SHE and FHE are based on lattice problems, which are
  believed to be safe against quantum attacks.
- **hide the score.** Sending back only "disease" or "no disease" needs a
  comparison on encrypted data. Paillier can't do that on its own. It would
  need extra rounds of messages between the phone and the server.
- **run bigger models.** Neural networks need encrypted multiplications for
  their activation functions, and decision trees need comparisons.
- **handle many patients at once.** CKKS can pack thousands of values into one
  ciphertext.

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

**Watch out for the labels in this file.** It is the Kaggle copy of the UCI
data, and it numbers things differently from the original. We matched it row by
row with the original UCI file and found:

- The `target` column is **reversed**: 1 means **no** heart disease and 0 means
  heart disease. Our training code flips it, so in the model and the app,
  1 means heart disease.
- The category codes are renumbered. For example, chest pain type `cp = 0`
  means no chest pain, and `thal = 2` means normal. The full list is in
  `medical_app/lib/models/patient/cardiology.dart`.
- `ca = 4` and `thal = 0` mean the value was missing in the original data.
  The app offers these as "Unknown".

### Why logistic regression

The model has to run on encrypted numbers, so it can only add and multiply.
That rules out the paper's Random Forest, which needs comparisons ("is age
above 55?"). It also rules out KNN, which needs distances between patients.

So the real question was: do we lose accuracy by using a simpler model? We
don't. We tested four models the same way. Each model was trained and tested 50
times on different splits of the data (5-fold cross-validation, repeated 10
times). The table shows the average, and the +/- shows how much the result
varied between runs.

| Model | Works encrypted? | Accuracy | Precision | Recall | F1 | ROC AUC |
|---|---|---|---|---|---|---|
| Random Forest (paper) | no | 0.822 +/- 0.046 | 0.827 +/- 0.064 | 0.777 +/- 0.084 | 0.798 +/- 0.056 | 0.904 +/- 0.034 |
| KNN (k=5) | no | 0.816 +/- 0.049 | 0.833 +/- 0.068 | 0.753 +/- 0.093 | 0.786 +/- 0.064 | 0.877 +/- 0.043 |
| Logistic regression, 13 inputs | yes | 0.830 +/- 0.040 | 0.860 +/- 0.066 | 0.755 +/- 0.077 | 0.800 +/- 0.049 | 0.897 +/- 0.039 |
| **Logistic regression, 27 inputs (used)** | **yes** | **0.851 +/- 0.050** | **0.859 +/- 0.059** | **0.809 +/- 0.096** | **0.830 +/- 0.062** | **0.918 +/- 0.035** |

Precision and recall are about finding patients **with** heart disease.
Recall is the share of sick patients the model catches. Precision is the share
of "heart disease" predictions that are correct.

What this shows:

- **The model we use is the best of the four.** It has the highest accuracy,
  recall, F1 and ROC AUC. Its precision ties the 13-input logistic
  regression. It beat the Random Forest in 33 of the 50 runs, tied in 10 and
  lost in 7.
- **One-hot encoding helps.** Using 27 inputs instead of 13 adds about 2
  percentage points of accuracy and 5 points of recall. The cost is 27
  encryptions per prediction instead of 13.
- **It catches more sick patients.** Recall is 0.81, compared with 0.78 for
  the Random Forest. But it still misses about 1 in 5 patients who have heart
  disease (see [Limitations](#limitations)).
- **Encryption doesn't change the answer.** We sent all 303 patients through
  the encrypted server. Every prediction was the same as without encryption.

The full analysis is in `heart_disease_model/heart-disease-experiment.ipynb`.

**About the 91.8% in the paper.** That number, and 88.5%, each come from
testing on one split of 61 patients. Small test sets give very different
results depending on which patients land in them. We tested the same Random
Forest on 30 different random splits and got anywhere from 72.1% to 90.2%. So
you can't compare a one-split number with the averages above.

To retrain the model, run `heart_disease_model/heart-disease-experiment.ipynb`
from top to bottom:

```bash
cd heart_disease_model
pip install -r requirements.txt
jupyter notebook heart-disease-experiment.ipynb
```

It saves the model weights to
`he_services/ml_models/heart_disease_logistic_regression.json`, which the server
loads. It also checks that the saved weights give exactly the same scores as
the trained model.

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
5. **The model misses about 1 in 5 sick patients.** Its recall for heart
   disease is 0.81. That is better than the paper's Random Forest, but far too
   low for real screening.

## Changes since the paper

In the published version (tag `paper-v1`), data was encrypted while travelling
but decrypted on the server. The app sent its private key with every request.
The server also created the keys, and the app sent the raw measurements to a
server `/encrypt` address. The server had to decrypt because a Random Forest
can't run on encrypted numbers.

The paper's version also had two problems with the data's labels:

- **The result screen was reversed.** The dataset's `target` column uses 1 for
  no heart disease, but the app treated 1 as heart disease. So it told
  patients predicted healthy "Sorry" and patients predicted sick "You're
  Fine!". Accuracy figures are not affected, because flipping both labels
  doesn't change how often the model is right.
- **The form asked for the wrong codes.** Its hints used the original UCI
  numbering (for example `cp` from 1 to 4), but the model was trained on the
  Kaggle numbering (`cp` from 0 to 3, in a different order).

This version:

- uses a logistic regression instead of the Random Forest
- creates the keys, encrypts and decrypts on the phone
- removes every server address that received a private key or raw data
- trains with the correct label, so 1 means heart disease everywhere
- replaces the number-code form with dropdowns of plain options and number
  boxes with units and limits

Code that the new version no longer uses has been deleted: the paper's
notebooks and Random Forest, the old server code, and seven Dart files that
nothing used. You can still see all of it in the `paper-v1` tag. To print one
old file, run `git show paper-v1:<path>`.

The accuracy and speed numbers in this README are for this version, not the
paper's.

## License

MIT. See [LICENSE](LICENSE).

The UCI Cleveland heart disease dataset is public and is included so you can
reproduce the results.
