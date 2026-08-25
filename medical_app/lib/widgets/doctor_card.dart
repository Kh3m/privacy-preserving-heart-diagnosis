import 'package:flutter/material.dart';

import '../models/doctor.dart';
import '../utils/hex_color.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onDrCellTap;

  const DoctorCard({super.key, required this.doctor, required this.onDrCellTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onDrCellTap,
        child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color: Colors.deepPurple[100],
          color: HexColor('#EDFDFA'),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            children: [
            // picture of doctor
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  doctor.image,
                  height: 100,
              ),
            ),
          const SizedBox(height: 10),
            //  rating out of 5
            Row(children: [
              Icon(Icons.star,
                color: Colors.yellow[500]
              ),
              Text('${doctor.rating}',
              style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),),
            ],),
            const SizedBox(height: 10),
            // doctor name
            Text('Dr. ${doctor.firstName} ${doctor.lastName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),),
            // doctor title
            Text('${doctor.type}, 7 y.e.'),
          ],
        ),
      ),
    );
  }
}