import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unisoft/Screens/Dashboard/timeline.dart';

import '../Shapes/roundedborder_with_icon.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (Navigator.canPop(context)) {
            Get.back();
          } else {
            // User? user=  AuthService.instance.firebaseAuth.currentUser;
            // if (user!=null && !user.isAnonymous) {

            // }
            Get.offAll(() => const Timeline());
          }
          print(1);
        },
        child: const RoundedBorderWithIcon(icon: Icons.arrow_back),
      ),
    );
  }
}
