import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/doctor.dart';
import '../../utils/custom_icons_icons.dart';
import '../../utils/hex_color.dart';
import '../../widgets/category_card.dart';
import '../../widgets/doctor_card.dart';
import '../home_detail_screen/detail_screen.dart';
import '../reserve/reserve_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();

  const HomeScreen({super.key});
}

class _HomeScreenState extends State<HomeScreen> {
  List<Doctor> _doctors = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _doctors = _getDoctors();
    _categories = _getCategories();
  }

// Get Doctors List
List<Doctor> _getDoctors() {
    List<Doctor> hDoctors = [];

    hDoctors.add(
      Doctor(
        firstName: 'Abdul',
        lastName: 'Kareem',
        image: 'assets/images/abdulkareem.png',
        type: 'Cardiologist',
        rating: 4.5,
      ),
    );

    hDoctors.add(
      Doctor(
        firstName: 'Joy',
        lastName: 'Albert',
        image: 'assets/images/joy.png',
        type: 'Eye',
        rating: 3.5,
      ),
    );

    hDoctors.add(
      Doctor(
        firstName: 'Ahmed',
        lastName: 'Mohammed',
        image: 'assets/images/ahmed.png',
        type: 'Pediatrician',
        rating: 4.5,
      ),
    );
    return hDoctors;
  }
  
  _onDrCellTap(Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomeDetailScreen(
          doctor: doctor,
        ),
      ),
    );
  }

  // Get Categories
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
          child: Column(
          children: [
            const SizedBox(height: 16,),
            // app bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text('Hello,',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text('Meehar Abdul',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),),
                  ],
                  ),
                  // profile picture
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // color: Colors.deepPurple[100],
                      color: HexColor('#E1F7F4'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 25
            ),
            // card - how do you feel?
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0
              ),
              child: Container( 
                padding: EdgeInsets.all(
                    20,
                  ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // color: Colors.pink[100],
                  color: HexColor('#E1F7F4'),
                ),
                child: Row(
                  children: [
                    // animation or picture
                    Container(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset('assets/images/meehar.jpeg'),
                      ),
                      
                      // child: Image.asset('assets/images/avatar.png'),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    // how do you feel _ get started button 
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('How do you feel?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                          const SizedBox(height: 12,),
                          const Text('Fill out your medical card right now',
                          style: TextStyle(
                            fontSize: 14,
                          ),),
                          const SizedBox(height: 12,),
                           InkWell(
                             onTap: () => _onCatCellTap(
                               _categories[0],
                               _doctors[0],
                             ),
                              child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                //  color: Colors.deepPurple[300],
                                color: HexColor('#00C6AD'),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                              child:  const Center(
                                child:  Text('Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                          ),
                          ),
                                ),
                          ),
                           ),
                        ]
                      ),
                    )                
                  ]
                ),

              ),
            ),
            const SizedBox(
              height: 25,
            ),
            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // color: Colors.deepPurple[100],
                  color: HexColor('#EDFDFA'),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: 'How cn we help you?',
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            // horizontal listview -> categories, heart etc
            Container(
              padding: const EdgeInsets.only(left: 25, right: 25),
              height: 80,
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const Divider(indent: 16),
                itemBuilder: (context, index) {
                  return CategoryCard(
                    category: _categories[index],
                    onCatTap: () => _onCatCellTap(
                    _categories[index],
                    _doctors[index],
                  ),
                  );
                },
                scrollDirection: Axis.horizontal,
                
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                const Text('Doctor list',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
                Text('See all',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[500]
                )),
              ],),
            ),
            const SizedBox(height: 25),
            // doctor list
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _doctors.length,
                    separatorBuilder: (context, index) => const Divider(indent: 16),
                    itemBuilder: (context, index) => DoctorCard(
                      doctor: _doctors[index],
                      onDrCellTap: () => _onDrCellTap(_doctors[index]),
                    ),
                  ),
                )
              ),
              const SizedBox(height: 25),
          ]
        ),
      ),
    );
  }
}