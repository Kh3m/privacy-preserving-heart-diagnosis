from flask import jsonify

class HE:
    def serializeData(self, public_key, encrypted_data_list):
        encrypted_data={}
        encrypted_data['public_key'] = {'n': str(public_key.n)}
        encrypted_data['values'] = [(str(x.ciphertext()), x.exponent) for x in encrypted_data_list]
        return jsonify(encrypted_data)
