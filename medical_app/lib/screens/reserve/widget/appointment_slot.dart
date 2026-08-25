import 'package:flutter/material.dart';

import '../../../constant.dart';
import '../../../models/choose_model.dart';
import 'choose_date.dart';
import 'choose_time_group.dart';

class AppointmentSlot extends StatelessWidget {
  const AppointmentSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [mBackgroundColor, mSecondBackgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 48,
                ),
                const Text(
                  'Choose Your Slot',
                  style: TextStyle(
                    color: mTitleTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    ChooseDate(
                      week: 'Mon',
                      date: '26',
                    ),
                    ChooseDate(
                      week: 'Tue',
                      date: '27',
                      check: true,
                    ),
                    ChooseDate(
                      week: 'Wed',
                      date: '28',
                    ),
                    ChooseDate(
                      week: 'Thu',
                      date: '29',
                    ),
                    ChooseDate(
                      week: 'Fri',
                      date: '30',
                    ),
                    ChooseDate(
                      week: 'Sat',
                      date: '31',
                    ),
                  ],
                )
              ],
            ),
            ChooseTimeGroup(
              title: 'Morning',
              list: [
                ChooseModel('09.00 AM'),
                ChooseModel('09.30 AM', check: true),
                ChooseModel('10.30 AM'),
                ChooseModel('11.00 AM'),
                ChooseModel('11.30 AM'),
                ChooseModel('12.00 AM'),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            ChooseTimeGroup(
              title: 'Afternoon',
              list: [
                ChooseModel('02.00 PM'),
                ChooseModel('02.30 PM'),
                ChooseModel('03.00 PM'),
                ChooseModel('03.30 PM'),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            ChooseTimeGroup(
              title: 'Evening',
              list: [
                ChooseModel('06.00 PM'),
                ChooseModel('06.30 PM'),
                ChooseModel('07.00 PM'),
                ChooseModel('07.30 PM'),
                ChooseModel('08.00 PM'),
                ChooseModel('08.30 PM'),
              ],
            ),
            const SizedBox(
              height: 32,
            )
          ],
        ),
      ),
    );
  }
}
