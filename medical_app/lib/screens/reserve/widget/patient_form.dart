import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:medical_app/models/patient/enc_dec.dart';
import 'package:medical_app/models/patient/sqflite_space/cardiology.dart';
import 'package:medical_app/models/patient/sqflite_space/key.dart';
import 'package:medical_app/screens/reserve/widget/bottom_content.dart';
import 'package:medical_app/screens/reserve/widget/button.dart';
import 'package:provider/provider.dart';

import '../../../models/patient/cardiology.dart';
import './patient_info_field.dart';

class PatientForm extends StatefulWidget {
  final TabController tabController;

  const PatientForm({
    super.key,
    required this.tabController,
  });

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _form = GlobalKey<FormState>();
  final Map values = {};
  List<Cardiolgy> queryLists = [];
  bool isQueryListsLoading = false;
  bool isSaving = false;
  bool isStartEnc = false;
  _onSave(String key, String value) async {
    values[key] = value;
  }

  // called immediately after initState()
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      isQueryListsLoading = true;
    });
    CardiologySQFlite.cardiologies().then((vals) {
      setState(
        () {
          queryLists = vals;
          isQueryListsLoading = false;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isEncLoading = Provider.of<EncDec>(
          context,
        ).encData['values'] ==
        null;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isQueryListsLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Wrap(
                  spacing: 25,
                  alignment: WrapAlignment.start,
                  children: [
                    ...Cardiolgy.getFieldsDesc().entries.map((e) {
                      return PatientInfoField(
                        field: e.key,
                        fieldValue: e.value,
                        check: false,
                        onSave: _onSave,
                        actualValue: queryLists.isEmpty
                            ? ''
                            : queryLists[0].toMap()[e.key].toString(),
                      );
                    }).toList()
                  ],
                ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Button(
                onPressed: () async {
                  setState(() {
                    isSaving = true;
                  });
                  if (_form.currentState!.validate()) {
                    _form.currentState!.save();

                    await CardiologySQFlite.insertCardiology(
                      Cardiolgy(
                        age: int.parse(values['age']),
                        sex: int.parse(values['sex']),
                        cp: int.parse(values['cp']),
                        trestbps: int.parse(values['trestbps']),
                        chol: int.parse(values['chol']),
                        fbs: int.parse(values['fbs']),
                        restecg: int.parse(values['restecg']),
                        thalach: int.parse(values['thalach']),
                        exang: int.parse(values['exang']),
                        oldpeak: double.parse(values['oldpeak']),
                        slope: int.parse(values['slope']),
                        ca: int.parse(values['ca']),
                        thal: int.parse(values['thal']),
                      ),
                    );
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data updated!!!'),
                      ),
                    );
                  }
                  setState(() {
                    isSaving = false;
                  });
                },
                text: isSaving ? "..." : "Save",
              ),
              const SizedBox(
                width: 10,
              ),
              Button(
                text:
                    (isStartEnc && isEncLoading) ? 'Processing...' : 'Encrypt',
                onPressed: () async {
                  setState(() {
                    isStartEnc = true;
                  });
                  if (_form.currentState!.validate()) {
                    final keyList = await KeySQFlite.keys();
                    if (keyList.isEmpty) {
                      showBottomSheet(
                        context: context,
                        builder: (context) => BottomContentSlot(
                          tabController: widget.tabController,
                        ),
                      );
                    } else {
                      // Sends the public key and values for encryption
                      _form.currentState!.save();
                      final data = {
                        'public_key': {'n': keyList[0].n},
                        'values': values.values.toList(),
                      };
                      Provider.of<EncDec>(context, listen: false)
                          .sendForEnc(data);
                    }
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
