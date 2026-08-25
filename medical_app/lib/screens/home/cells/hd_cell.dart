import 'package:flutter/material.dart';

import '../../../models/doctor.dart';
import '../../../utils/custom_icons_icons.dart';
import '../../../utils/hex_color.dart';

class HDCell extends StatelessWidget {
  final Doctor doctor;
  final Function onTap;

  const HDCell({
    Key? key,
    required this.doctor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 283,
      height: 199,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: HexColor('#00C6AD'),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 16,
            right: 16,
            child: SizedBox(
              width: 162,
              height: 139,
              child: Image(
                image: AssetImage('assets/images/bg_shape.png'),
              ),
            ),
          ),
          Positioned(
            top: 32,
            left: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dr.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  doctor.firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  doctor.lastName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  '${doctor.type} Specialist',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: InkWell(
              onTap: () => onTap(),
              child: Container(
                width: 77,
                height: 54,
                decoration: BoxDecoration(
                  color: HexColor('#00A994'),
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(32)),
                ),
                child: const Icon(
                  CustomIcons.arrowRight,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 0,
            child: SizedBox(
              width: 120,
              height: 173,
              child: Hero(
                tag: doctor.firstName + doctor.lastName,
                child: Image(
                  filterQuality: FilterQuality.high,
                  image: AssetImage('assets/images/${doctor.image}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
