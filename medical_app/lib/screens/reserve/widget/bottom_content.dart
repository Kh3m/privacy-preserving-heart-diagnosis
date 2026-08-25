import 'package:flutter/material.dart';
import 'package:medical_app/screens/reserve/widget/button.dart';
import 'package:medical_app/screens/reserve/widget/enc_text_view.dart';

import '../../../constant.dart';

class BottomContentSlot extends StatelessWidget {
  final TabController tabController;

  const BottomContentSlot({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    String str = """A handle to the location of a widget in the widget tree.

This class presents a set of methods that can be used from [StatelessWidget.build] methods and from methods on [State] objects.

[BuildContext] objects are passed to [WidgetBuilder] functions (such as [StatelessWidget.build]), and are available from the [State.context] member. Some static functions (e.g. [showDialog], [Theme.of], and so forth) also take build contexts so that they can act on behalf of the calling widget, or obtain data specifically for the given context.

Each widget has its own [BuildContext], which """;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.7,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 32,
            ),
            const Text(
              'Ooops :) No Key Found For Encryption',
              style: TextStyle(
                color: mTitleTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            const Image(
                image: AssetImage('assets/images/what-is-encryption.png')),
            const SizedBox(
              height: 32,
            ),
            const Text(
              'To Encrypt data using homomorphic encryption, you typically need:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Public Key: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text:
                        'This is used to encrypt the data and can be shared with anyone.',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Private Key: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text:
                        'This is used to decrypt the data and should be kept secret.',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Button(
                text: 'Let\'s Generate Key Pair ?',
                onPressed: () {
                  Navigator.pop(context);
                  tabController.index = 1;
                }),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
