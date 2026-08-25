import 'package:flutter/material.dart';
import 'package:medical_app/models/doctor.dart';
import '../../../constant.dart';

class DoctorInfo extends StatelessWidget {
  final Doctor doctor;
  const DoctorInfo({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            height: 110,
            child: CircleAvatar(
              backgroundColor: mBarColor,
              child: Image.asset(
                doctor.image,
                width: 100,
                height: 110,
              ),
            ),
          ),
          // Image.asset(
          //   'assets/images/avatar.png',
          //   width: 100,
          //   height: 100,
          // ),
          SizedBox(
            width: 24,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'dr.${doctor.firstName} ${doctor.lastName}',
                style: TextStyle(
                  color: mBarColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                doctor.type,
                style: const TextStyle(fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }
}
