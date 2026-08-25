import 'package:flutter/material.dart';

import '../../utils/custom_icons_icons.dart';
import '../../utils/hex_color.dart';

/// App Bar
  AppBar buildAppBar(context) {
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