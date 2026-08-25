from flask_restful import Resource, request
from api.helper.he import HE
class EncDec(Resource):
    _he = HE()
    def get(self, name):
        if(name == 'generate_key_pair'):
            return self._he.generate_key_pair()    
        return 404

    def post(self, name):
        if(name == 'encrypt'):
            data = request.get_json()
            return self._he.encrypt(data)
        if(name == 'decrypt'):
            data = request.get_json()
            return self._he.decrypt(data)
        return name

    

