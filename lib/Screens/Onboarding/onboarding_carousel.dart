import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/Auth/login.dart';
import 'package:unisoft/components/sqaure_Button.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';
import 'dart:developer' as dev;

import '../../Values/values.dart';
import '../../widgets/Onboarding/slider_captioned_image.dart';

import '../Dashboard/timeline.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  _OnboardingCarouselState createState() => _OnboardingCarouselState();
}


class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(
        i == _currentPage
            ? _indicator(true)
            : _indicator(false),
      );
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0), // Adjust margin
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: isActive ? 15.0 : 10.0, // Increased dot size
        width: isActive ? 15.0 : 10.0, // Increased dot size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.indigo[800] : Colors.grey[500], // Changed dot color
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [

            Column(
              children: [
                Expanded(
                  child: SizedBox(
                    child: PageView(
                      physics: const ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: <Widget>[
                        SliderCaptionedImage(
                          index: 0,
                          imageUrl: "assets/slider-background-1.png",
                          caption: AppConstants.task_calendar_chat_key.tr,
                          captionColor: Colors.black, // Set caption color to black
                          captionFontSize: 14,
                        ),
                        SliderCaptionedImage(
                          index: 1,
                          imageUrl: "assets/slider-background-3.png",
                          caption: AppConstants.work_anywhere_easily_key.tr,
                          captionColor: Colors.black, // Set caption color to black
                          captionFontSize: 14,
                        ),
                        SliderCaptionedImage(
                          index: 2,
                          imageUrl: "assets/slider-background-2.png",
                          caption: AppConstants.manage_everything_on_Phone_key.tr,
                          captionColor: Colors.black, // Set caption color to black
                          captionFontSize: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _buildPageIndicator(),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                  Get.to(() => const Login());
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(HexColor.fromHex("246CFE")),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    side: BorderSide(color: HexColor.fromHex("246CFE")),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.email, color: Colors.white),
                                  Text(
                                    AppConstants.continue_with_email_key.tr,
                                    style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey), // Adjust color as needed
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.grey), // Adjust color as needed
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey), // Adjust color as needed
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),// Increased space between email button and Google button
                          Center(
                            child: SquareButtonIcon(
                              imagePath: "lib/images/google2.png",
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                );
                                var authG = await AuthService().signInWithGoogle();
                                Navigator.of(context).pop();
                                authG.fold(
                                      (left) {
                                    CustomSnackBar.showError(left.toString());
                                  },
                                      (right) {
                                    CustomSnackBar.showSuccess("Success login");
                                    dev.log("message");
                                    Get.offAll(() => const Timeline());
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              AppConstants.by_continuing_you_agree_Unisoft_terms_of_services_privacy_policy_key.tr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 15, color: Colors.black), // Set text color to black
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}