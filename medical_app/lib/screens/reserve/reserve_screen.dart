import 'package:flutter/material.dart';
import 'package:medical_app/screens/reserve/widget/appointment_slot.dart';

import '../../models/doctor.dart';
import '../../models/category.dart';
import '../../constant.dart';
import '../../utils/custom_icons_icons.dart';
import '../../utils/hex_color.dart';
import './widget/doctor_info.dart';
import '../../widgets/my_header.dart';
import './widget/patient_slot.dart';
import './widget/key_pair.dart';

class ReserveScreen extends StatefulWidget {
  final Category category;
  final Doctor doctor;
  final int index;

  const ReserveScreen({
    super.key,
    required this.category,
    required this.doctor,
    required this.index,
  });

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if(widget.index >= 0) {
      _tabController!.index = widget.index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _appBar = _buildAppBar(context);

    return Scaffold(
      appBar: _appBar,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      _appBar.preferredSize.height) *
                  0.3,
              child: MyHeader(
                // height: 250,
                imageUrl: 'assets/images/avatar_head.png',
                child: Column(
                  children: <Widget>[
                    // MyAppbar(),
                    const SizedBox(
                      height: 16,
                    ),
                    DoctorInfo(
                      doctor: widget.doctor,
                    )
                  ],
                ),
              ),
            ),
            Container(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      _appBar.preferredSize.height) *
                  0.07,
              child: TabBar(
                indicatorColor: mBarColor,
                controller: _tabController,
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                ),
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(
                    child: Text(
                      'Info',
                      style: TextStyle(
                        color: mBarColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Key Pair',
                      style: TextStyle(
                        color: mBarColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Reservation',
                      style: TextStyle(
                        color: mBarColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      _appBar.preferredSize.height) *
                  0.63,
              child: TabBarView(
                controller: _tabController,
                children: [
                  PatientSlot(
                    category: widget.category,
                    doctor: widget.doctor,
                    tabController: _tabController!,
                  ),
                  const KeyPairTabScreen(),
                  const AppointmentSlot(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **********************************************
  /// WIDGETS
  /// **********************************************

  /// App Bar
  AppBar _buildAppBar(context) {
    return AppBar(
      backgroundColor: HexColor('#00C6AD'),
      elevation: 0,
      brightness: Brightness.dark,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(CustomIcons.arrowLeft, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
