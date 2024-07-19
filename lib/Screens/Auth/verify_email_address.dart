// ignore_for_file: avoid_print

import 'package:either_dart/either.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unisoft/constants/app_constans.dart';

import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';

import '../../Values/values.dart';
import '../../widgets/DarkBackground/darkRadialBackground.dart';

import '../../widgets/Navigation/back.dart';
import '../../widgets/Shapes/background_hexagon.dart';
import '../Dashboard/timeline.dart';

class VerifyEmailAddressScreen extends StatefulWidget {
  const VerifyEmailAddressScreen({super.key});

  @override
  _VerifyEmailAddressScreenState createState() =>
      _VerifyEmailAddressScreenState();
}

class _VerifyEmailAddressScreenState extends State<VerifyEmailAddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DarkRadialBackground(
          color: HexColor.fromHex("#181a1f"),
          position: "topLeft",
        ),
        Positioned(
          top: Utils.screenHeight / 2,
          left: Utils.screenWidth,
          child: Transform.rotate(
            angle: -math.pi / 2,
            child: CustomPaint(
              painter: BackgroundHexagon(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NavigationBack(),
                    SizedBox(
                        height: Utils.screenHeight *
                            0.2),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Utils.screenWidth / 3),
                      child: Icon(
                        size: Utils.screenWidth * 0.2,
                        FontAwesomeIcons.envelopeCircleCheck,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                        height: Utils.screenHeight *
                            0.1), // Adjust the percentage as needed
                    Center(
                      child: Text(
                        AppConstants.check_your_an_email_messages_we_have_send_the_link_to_email_to_verify_key.tr,
                        textAlign: TextAlign.center, // Align text in the center
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: Utils.screenWidth * 0.08, // Reduce font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AppSpaces.verticalSpace40,
                    SizedBox(
                      //width: 180,
                      height: Utils.screenHeight * 0.15,
                      child: ElevatedButton(
                        onPressed: () async {
                          var verifyEmail =
                              await AuthService().sendVerifiectionEmail();
                          verifyEmail.fold((left) {
                            CustomSnackBar.showError(left.toString());
                          },
                              (right) => {
                                    if (right == true)
                                      {
                                        CustomSnackBar.showSuccess(AppConstants
                                            .the_mail_is_verifed_key.tr),
                                        Get.offAll(() => const Timeline()),
                                      }
                                  });
                        },
                        style: ButtonStyles.blueRounded,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.link, color: Colors.white),
                            Text(AppConstants.send_verify_link_key.tr,
                                style: GoogleFonts.lato(
                                    fontSize: Utils.screenWidth * 0.06,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    AppSpaces.verticalSpace20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.verifed_key.tr,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: Utils.screenWidth * 0.055),
                        ),
                        GestureDetector(
                          onTap: () {
                            var verifed = AuthService().checkEmailVerifction();
                            verifed.fold((left) {
                              CustomSnackBar.showError(left.toString());
                            }, (right) {
                              if (right == true) {
                                CustomSnackBar.showSuccess(
                                    AppConstants.sucess_baby_key.tr);
                                Get.offAll(() => const Timeline());
                              } else {
                                CustomSnackBar.showError(AppConstants
                                    .plese_verify_your_email_before_continue_key
                                    .tr);
                              }
                            });
                          },
                          child: Text(
                            AppConstants.continue_key.tr,
                            style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: Utils.screenWidth * 0.055,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
        )
      ]),
    );
  }
}
