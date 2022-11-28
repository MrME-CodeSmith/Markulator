import 'package:flutter/material.dart';

import '../Model/system_information_model.dart';

class SystemInformationProvider with ChangeNotifier {
  SystemInformation? systemInformation;

  SystemInformationProvider();

  initialize(BuildContext context) {
    systemInformation = SystemInformation(
      screenHeight: MediaQuery.of(context).size.height,
      screenWidth: MediaQuery.of(context).size.width,
    );
  }

  SystemInformation get systemInfo {
    return systemInformation!;
  }

  double androidAvailableScreenHeight(
      {required BuildContext context, bool keyBoardVisible = false}) {
    return systemInformation!.screenHeight -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        ((keyBoardVisible) ? MediaQuery.of(context).viewInsets.bottom : 0);
  }

  double keyboardHeight({required BuildContext context}) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}
