import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:medical_app/models/patient/sqflite_space/key.dart';
import 'package:medical_app/screens/reserve/widget/display_text.dart';
import 'package:medical_app/screens/reserve/widget/enc_text_view.dart';

import '../../../constant.dart';
import './title_content_group.dart';
import '../../../models/patient/enc_dec.dart';
import '../../../screens/reserve/widget/button.dart';
import '../../../models/patient/key_m.dart';

class KeyPairTabScreen extends StatefulWidget {
  const KeyPairTabScreen({super.key});

  @override
  State<KeyPairTabScreen> createState() => _KeyPairTabScreenState();
}

class _KeyPairTabScreenState extends State<KeyPairTabScreen> {
  var isKeyLoading = false;
  KeyM? _key;

  void _keyPressed() async {
    setState(() {
      isKeyLoading = true;
    });

    EncDec().generateKeyPair().then((keym) {
      setState(() {
        _key = keym;
        isKeyLoading = false;
        KeySQFlite.insertKey(keym);
      });
    });
  }

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
        child: FutureBuilder(
            future: KeySQFlite.keys(),
            builder: ((context, snapshot) {
              bool isWaiting =
                  snapshot.connectionState == ConnectionState.waiting;
              KeyM? keyM;
              if (!isWaiting) {
                log(snapshot.data!.length.toString());
                keyM = KeyM(
                  n: snapshot.data!.isNotEmpty ? snapshot.data![0].n : 'No Key',
                  p: snapshot.data!.isNotEmpty ? snapshot.data![0].p : 'No Key',
                  q: snapshot.data!.isNotEmpty ? snapshot.data![0].q : 'No Key',
                );
              }
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 32,
                    ),
                    TitleContentGroup(
                      title: 'Private (Key)',
                      list: [
                        if (isWaiting)
                          const DisplayText(text: 'No Key', check: false),
                        if (!(isWaiting))
                          EncriptionTextWidget(
                            text: keyM!.p,
                          ),
                        if (isWaiting)
                          const DisplayText(text: 'No Key', check: false),
                        if (!isWaiting)
                          EncriptionTextWidget(
                            text: keyM!.q,
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    TitleContentGroup(
                      title: 'Public (Key)',
                      list: [
                        if (isWaiting)
                          const DisplayText(text: "No Key", check: false),
                        if (!isWaiting)
                          EncriptionTextWidget(
                            text: keyM!.n,
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Button(
                      text:
                          isKeyLoading ? 'Processing...' : 'Generate Key Pair',
                      onPressed: isKeyLoading ? null : _keyPressed,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Button(
                      text: 'Clear Key',
                      onPressed: () async {
                        await KeySQFlite.deleteKeys();
                      },
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                  ]);
            })),
      ),
    );
  }
}
