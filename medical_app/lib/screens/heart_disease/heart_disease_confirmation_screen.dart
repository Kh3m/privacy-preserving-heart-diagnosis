import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../models/category.dart';
import '../../models/doctor.dart';
import '../../models/patient/patient.dart';
import '../../utils/custom_icons_icons.dart';
import '../../widgets/builders/app_bar_builder.dart';
import '../../widgets/circle_progress.dart';
import '../../widgets/my_header.dart';
import '../reserve/reserve_screen.dart';
import '../reserve/widget/button.dart';
import '../reserve/widget/enc_text_view.dart';

class HeartDiseaseConfirmationScreen extends StatefulWidget { 
  final Map data;
  final Doctor doctor;
  final Category category;
  final TabController tabController;

  const HeartDiseaseConfirmationScreen({
    super.key,
    required this.data,
    required this.tabController,
    required this.doctor,
    required this.category
  });
  
  @override
  State<HeartDiseaseConfirmationScreen> createState() => _HeartDiseaseConfirmationScreenState();
}

class _HeartDiseaseConfirmationScreenState extends State<HeartDiseaseConfirmationScreen> {
  var _isDecrypted = false;
  var _isDecryptLoading = false;
  var _decryptedVals = [];

  @override
    void initState() {
      // TODO: implement initState
      super.initState();
      Provider.of<Patient>(context, listen: false)
          .sendForHeartDiseaseDiag(widget.data);
    }

  @override
  Widget build(BuildContext context) {
    bool hasDisease = false;
    if(_decryptedVals.isNotEmpty) {
      hasDisease = _decryptedVals[0] == 1.0 ? true : false; 
      // hasDisease = _decryptedVals[0] == 1.0 ? false : true; 
    }     
   
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
            const MyHeader(
              imageUrl: "assets/images/dataset-cover.jpg", 
              child: Text(""),
            ),
          const SizedBox (
            height: 30,
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: Provider.of<Patient>(context).encData,
            builder: (conext, snapshot) {
              print(snapshot.connectionState);
              print(snapshot.hasData);
              print(snapshot.data);
              
              if(snapshot.connectionState == ConnectionState.done 
              && snapshot.hasData
              && snapshot.data!.entries.isNotEmpty
              ) {
                return CustomPaint(
                  foregroundPainter: CircleProgress( hasDisease: hasDisease ),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: _isDecrypted ? _buildDecSec( hasDisease ) : _buildUnDecSec(
                      data: {
                        "public_key": {
                          "n": widget.data["public_key"]["n"]
                        },
                        "private_key": {
                          "p": widget.data["private_key"]["p"],
                          "q": widget.data["private_key"]["q"]
                        },
                        "values": snapshot.data!["values"]
                      }
                    )
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator(color: mSecondBackgroundColor,));
            }
             
          )
        ],
      )
    )
    );
  }

Widget _buildDecSec( bool hasDisease ) {
  
  return Center( 
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CustomIcons.cardiologist, 
                      size: 30,
                       color: hasDisease ? Colors.redAccent : Colors.grey
                    ),
                    Text(_decryptedVals[0].toString(), style: const TextStyle(
                      fontSize: 50
                    ),),
                    hasDisease ? const Text("Sorry :)") : const Text("You're Fine!"),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ReserveScreen(
                              category: widget.category,
                              doctor: widget.doctor,
                              index: 2
                            ), 
                          )
                        );
                      },
                      child: const Text("See a Doctor ?"),
                    )
                  ],
                ),
                );
}
Widget _buildUnDecSec( {data} ) {
  return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CustomIcons.cardiologist, size: 30,),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: EncriptionTextWidget(
                        text: data["values"][0][0],
                      ),
                    ),
                    Button(
                      text: _isDecryptLoading ? "Processing...": "Decrypt", onPressed: _isDecryptLoading ? null : () async {
                      setState(() {
                        _isDecryptLoading = true;
                      });
                      final vals = await Provider.of<Patient>(context, listen: false).decryptHeartDiseaseTarget({
                        "public_key": {
                          "n": data["public_key"]["n"]
                        },
                        "private_key": {
                          "p": data["private_key"]["p"],
                          "q": data["private_key"]["q"]
                        },
                        "values": data["values"],
                      });
                      setState(() {
                        _isDecryptLoading = false; 
                        _decryptedVals = vals;
                        _isDecrypted = true;     
                      });
                    }),
                  ],
                )
                ); 
}
}

