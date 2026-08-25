import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../models/category.dart';
import '../../../models/doctor.dart';
import '../../../models/patient/cardiology.dart';
import '../../../models/patient/enc_dec.dart';
import '../../../models/patient/patient.dart';
import '../../../models/patient/sqflite_space/key.dart';
import '../../heart_disease/heart_disease_confirmation_screen.dart';
import 'bottom_content.dart';
import 'button.dart';

class EncryptedInfo extends StatelessWidget {
  final Category category;
  final TabController tabController;
  final Doctor doctor;

  const EncryptedInfo({
    required this.category,
    required this.tabController,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> result = Provider.of<EncDec>(context).encData;
    bool isNull = result['values'] == null;
    final fields = Cardiolgy.getFieldsDesc().keys.toList();
    List? fieldVals;
    final _form = GlobalKey<FormState>();
    final Map values = {};
    _onSave(String key, String value) async {
      values[key] = value;
    }
    if (!(isNull)) {
      fieldVals = List.generate(fields.length, (i) {
        return {fields[i]: (result['values'] as List)[i][0]};
      });
    }

    return Column(
      children: [
        Text(
          'Patient ${category.title} Encrypted Info',
          style: const TextStyle(
            color: mTitleTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        Form(
          key: _form,
          child: Column(
          children: [
            if (!(isNull))
              ...fieldVals!.map(
                (val) {
                  return TextFormField(
                    onSaved: (newValue) => _onSave(val.keys.first, newValue!),
                    decoration: InputDecoration(
                      labelText: val.keys.first,
                      labelStyle: TextStyle(
                        color: mBarColor,
                        // height: 0.5,
                      ),
                    ),
                    initialValue: val.values.first,
                    maxLines: 2,
                  );
                },
              ),
          ],
        )),
        const SizedBox(
          height: 32,
        ),
        Button(text: 'Send Encrypted Data', onPressed: () async {
          if (_form.currentState!.validate()) {
                    final keyList = await KeySQFlite.keys();
                    if (keyList.isEmpty) {
                      showBottomSheet(
                        context: context,
                        builder: (context) => Text("Empty")
                        // BottomContentSlot(
                        //   tabController: widget.tabController,
                        // ),
                      );
                    } else {
                      // Sends the public key and values for encryption
                      _form.currentState!.save();
                      final data = {
                        'public_key': {'n': keyList[0].n},
                        'private_key': {'p': keyList[0].p, 'q': keyList[0].q},
                        'values': result['values'],
                        'columns': fields,
                        'sd': true
                      };
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HeartDiseaseConfirmationScreen(
                            data: data,
                            doctor: doctor,
                            category: category,
                            tabController: tabController,
                          ),
                        )
                      );
                    }
                  }
        }),
        const SizedBox(
          height: 32,
        ),
      ],
    );
  }
}
