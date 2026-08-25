import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import pickle

heart_disease_data = pd.read_csv("data/heart-disease.csv")

heart_disease_model = pickle.load(open("heart_disease_random_forest_model.pkl", "rb"))

X, y = heart_disease_data.drop("target", axis=1), heart_disease_data["target"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

score = heart_disease_model.score(X_test, y_test) 
print(score)

y_preds = heart_disease_model.predict(
    pd.DataFrame(
        np.array(
            # [
            #     63,	1, 3, 145, 233, 1, 0, 150, 0, 2.3, 0,	0, 1
            # ],
            [
                57, 0,	0,	140, 241, 0, 1,	123, 1,	0.2, 1,	0, 3
            ]
        ).reshape(1, -1),
        columns=[ "age", "sex", "cp", "trestbps",	"chol",	"fbs", "restecg",	
        "thalach", "exang", "oldpeak", "slope",	"ca", "thal"]
    )
) 

print(y_preds)
# pred_val = np.array([
#         63,	1, 3, 145, 233, 1, 0, 150, 0, 2.3, 0,	0, 1
#     ])
# print(pred_val.shape)
# new_pred = pred_val.reshape(1,-1)
# print(new_pred.shape)