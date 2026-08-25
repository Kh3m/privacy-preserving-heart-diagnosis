import 'package:flutter/material.dart';
import 'package:medical_app/models/category.dart';
import 'package:medical_app/models/doctor.dart';
import 'package:medical_app/screens/home_detail_screen/detail_screen.dart';
import 'package:medical_app/screens/reserve/reserve_screen.dart';

import 'cells/trd_cell.dart';
import '../../utils/custom_icons_icons.dart';
import '../../utils/hex_color.dart';
import './cells/hd_cell.dart';
import './cells/category_cell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> _hDoctors = [];
  List<Category> _categories = [];
  List<Doctor> _trDoctors = [];

  /// ****************************************************
  /// ACTIONS
  /// ****************************************************

  _onCellTap(Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeDetailScreen(
          doctor: doctor,
        ),
      ),
    );
  }

  _onCatCellTap(Category category, Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReserveScreen(
          category: category,
          doctor: doctor,
          index: -1,
        ),
      ),
    );
  }

  /// ****************************************************
  /// LIFE CYCLE METHODS
  /// ****************************************************

  @override
  void initState() {
    super.initState();
    _hDoctors = _getHDoctors();
    _categories = _getCategories();
    _trDoctors = _getTRDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hDoctorsSection(),
            const SizedBox(
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _categorySection(),
                  const SizedBox(
                    height: 32,
                  ),
                  _trDoctorsSection(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ****************************************************
  /// WIDGETS
  /// ****************************************************

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      brightness: Brightness.light,
      iconTheme: IconThemeData(
        color: HexColor('#150047'),
      ),
      leading: IconButton(
        icon: const Icon(
          CustomIcons.menu,
          size: 14,
        ),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            CustomIcons.search,
            size: 20,
          ),
        ),
      ],
    );
  }

  /// Highlighted Doctors Section
  SizedBox _hDoctorsSection() {
    return SizedBox(
      height: 199,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: _hDoctors.length,
        separatorBuilder: ((context, index) => const Divider(
              indent: 16,
            )),
        itemBuilder: ((context, index) => HDCell(
              doctor: _hDoctors[index],
              onTap: () => _onCellTap(_hDoctors[index]),
            )),
      ),
    );
  }

  /// Category Section
  Column _categorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        SizedBox(
          height: 100,
          child: ListView.separated(
            primary: false,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: ((context, index) => const Divider(
                  indent: 16,
                )),
            itemBuilder: ((context, index) => CategoryCell(
                  category: _categories[index],
                  onCatTap: () => _onCatCellTap(
                    _categories[index],
                    _hDoctors[index],
                  ),
                )),
          ),
        ),
      ],
    );
  }

  /// Top Rated Doctors Section
  _trDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Rated Doctors',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 32,
        ),
        ListView.separated(
          primary: false,
          shrinkWrap: true,
          itemCount: _trDoctors.length,
          separatorBuilder: ((context, index) => const Divider(
                thickness: 16,
                color: Colors.transparent,
              )),
          itemBuilder: ((context, index) => TrdCell(
                doctor: _trDoctors[index],
              )),
        )
      ],
    );
  }

  /// ****************************************************
  /// DUMMY DATA
  /// ****************************************************

  /// Get Highlighted Doctors List
  List<Doctor> _getHDoctors() {
    List<Doctor> hDoctors = [];

    hDoctors.add(
      Doctor(
        firstName: 'Abdul',
        lastName: 'Kareem',
        image: 'abdulkareem.png',
        type: 'Cardiologist',
        rating: 4.5,
      ),
    );

    hDoctors.add(
      Doctor(
        firstName: 'Joy',
        lastName: 'Albert',
        image: 'joy.png',
        type: 'Eye',
        rating: 3.5,
      ),
    );

    hDoctors.add(
      Doctor(
        firstName: 'Ahmed',
        lastName: 'Mohammed',
        image: 'ahmed.png',
        type: 'Pediatrician',
        rating: 4.5,
      ),
    );
    return hDoctors;
  }

  /// Get Categories
  List<Category> _getCategories() {
    List<Category> categories = [];
    categories.add(
      Category(icon: CustomIcons.cardiologist, title: 'Cardiologist'),
    );
    categories.add(
      Category(icon: CustomIcons.eyes, title: 'Eyes'),
    );
    categories.add(
      Category(icon: CustomIcons.pediatrician, title: 'Pediatrician'),
    );
    return categories;
  }

  /// Get Top Rated Doctors List
  List<Doctor> _getTRDoctors() {
    List<Doctor> trDoctors = [];
    trDoctors.add(Doctor(
      firstName: 'Ahmed',
      lastName: 'Mohammed',
      image: 'ahmed.png',
      type: 'Pediatrician',
      rating: 4.7,
    ));

    trDoctors.add(
      Doctor(
        firstName: 'Mustapha',
        lastName: 'Abibat',
        image: 'abibat.png',
        type: 'Cardiologist',
        rating: 4.5,
      ),
    );

    trDoctors.add(
      Doctor(
        firstName: 'Cherly',
        lastName: 'Bishop',
        image: 'cherly.png',
        type: 'Kidney',
        rating: 4.3,
      ),
    );

    return trDoctors;
  }
}
