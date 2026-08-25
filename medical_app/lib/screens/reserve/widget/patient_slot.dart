import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../models/category.dart';
import '../../../models/doctor.dart';
import '../../../models/patient/enc_dec.dart';
import 'encrypted_info.dart';
import 'patient_form.dart';

class PatientSlot extends StatelessWidget {
  final Category category;
  final TabController tabController;
  final Doctor doctor;

  const PatientSlot({
    super.key,
    required this.category,
    required this.tabController,
    required this.doctor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mBackgroundColor,
            mSecondBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 48,
              ),
              Text(
                'Patient ${category.title} Info',
                style: const TextStyle(
                  color: mTitleTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              PatientForm(tabController: tabController),
              const SizedBox(
                height: 32,
              ),
              (Provider.of<EncDec>(context).encData['values'] == null)
                  ? Container()
                  : EncryptedInfo(
                      category: category,
                      tabController: tabController,
                      doctor: doctor,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
