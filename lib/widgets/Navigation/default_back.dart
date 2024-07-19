import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/models/User/User_model.dart';

import '../../Values/values.dart';
import '../dummy/profile_dummy.dart';
import 'back_button.dart';
  
class DefaultNav extends StatelessWidget {
  final String title;
  final UserModel userModel;
  final ProfileDummyType? type;
  const DefaultNav(
      {Key? key, this.type, required this.title, required this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      if(!kIsWeb)
      const AppBackButton(),
      Text(title,
          style: GoogleFonts.laila(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w600)),
      Builder(builder: (context) {
        if (type == ProfileDummyType.Icon) {
          return ProfileDummy(
              imageType: ImageType.Assets,
              color: HexColor.fromHex("93F0F0"),
              dummyType: ProfileDummyType.Image,
              image: "assets/man-head.png",
              scale: 1.2);
        } else if (type == ProfileDummyType.Image) {
          return ProfileDummy(
              imageType: ImageType.Assets,
              color: HexColor.fromHex("9F69F9"),
              dummyType: ProfileDummyType.Icon,
              scale: 1.0);
        } else {
          return Container();
        }
      }),
    ]);
  }
}
