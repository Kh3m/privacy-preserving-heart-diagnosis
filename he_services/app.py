from flask import Flask
from flask_restful import Api

# import resources
from api.ml.classification import MyClassification
from api.enc_dec.enc_dec import EncDec

app = Flask(__name__)

api = Api(app)

api.add_resource(MyClassification, '/api/operations/ml/classification')
api.add_resource(EncDec, '/api/phe/client/<string:name>')

if __name__ == '__main__':
    # Development server only. Production is served by uwsgi (see Procfile).
    app.run(host='0.0.0.0', port=5000)
