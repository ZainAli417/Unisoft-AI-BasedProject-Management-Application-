
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/splash_screen.dart';
import 'package:unisoft/VideoCall/screens/common/join_screen.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/userController.dart';
import 'package:unisoft/models/User/User_model.dart';
import 'package:unisoft/pages/splashPage.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Buttons/primary_tab_buttons.dart';
import 'package:unisoft/widgets/Navigation/dasboard_header.dart';

import '../../Values/values.dart';
import '../../services/notification_service.dart';
import '../Chat/screens/home_screen.dart';
import '../Profile/profile_overview.dart';
import 'DashboardTabScreens/overview.dart';
import 'DashboardTabScreens/productivity.dart';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _DashboardScreen();
  }
}

class _DashboardScreen extends StatefulWidget {
  const _DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<_DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller2;
  final ValueNotifier<int> _buttonTrigger = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }



  @override
  @override
  void dispose() {
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1280,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardNav(
                    image: "assets/man-head.png",
                    notificationCount: "2",
                    page: Container(),
                    title: AppConstants.dashboard_key.tr,
                    onImageTapped: () async {
                      bool fcmStutas =
                          await FcmNotifications.getNotificationStatus();
                      Get.to(() => ProfileOverview(
                            isSelected: fcmStutas,
                          ));
                      if (kDebugMode) {
                        print(AuthService
                            .instance.firebaseAuth.currentUser!.email);
                      }
                    },
                  ),
                  AppSpaces.verticalSpace20,
                  StreamBuilder<DocumentSnapshot<UserModel>>(
                    stream: UserController().getUserByIdStream(
                        id: AuthService.instance.firebaseAuth.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Center(
                        child: Text(
                          "${AppConstants.hello_n_key.tr} ${snapshot.data!.data()!.name} 👋",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.laila(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  AppSpaces.verticalSpace20,
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        GestureDetector(
                          onTap: ()  {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const JoinScreen()),
                                    (route) => true);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Container(
                              width: 150,
                              height: 50,
                              decoration: const BoxDecoration(),
                              child: Image.asset(
                                'assets/meet.png',
                                fit: BoxFit
                                    .cover, // Ensures the image covers the entire container
                                width: 150,
                                height: 50,
                              ),
                            ),
                          ),
                        ),
                      AnimatedBuilder(
                        animation: _controller2,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: () {
                              // Call AI chat screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ChatHomeScreen()),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50.0),
                              child: Container(
                                width: 150,
                                height: 50,
                                decoration: const BoxDecoration(),
                                child: Image.asset(
                                  'assets/chat2.png',
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 50, // Ensures the image covers the entire container
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  AppSpaces.verticalSpace20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!kIsWeb)
                        GestureDetector(
                        onTap: () {
                          // Call AI chat screen
                          try {
                            dynamic conversationObject = {
                              'appId': 'a87ee5bd0478c656be92d4d3b9f894a2',
                              'withPreChat': false,
                            };
                            dynamic result =
                            KommunicateFlutterPlugin.buildConversation(
                                conversationObject);
                            print("Conversation builder success : $result");
                          } on Exception catch (e) {
                            print("Conversation builder error occurred : $e");
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Container(
                            width: 150,
                            height: 50,
                            decoration: const BoxDecoration(),
                            child: Image.asset(
                              'assets/aichat.png',
                              fit: BoxFit
                                  .cover, // Ensures the image covers the entire container
                              width: 150,
                              height: 40,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                  AppSpaces.verticalSpace20,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //tab indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PrimaryTabButton(
                              buttonText: AppConstants.overview_key.tr,
                              itemIndex: 0,
                              notifier: _buttonTrigger),
                          PrimaryTabButton(
                              buttonText: AppConstants.productivity_key.tr,
                              itemIndex: 1,
                              notifier: _buttonTrigger)
                        ],
                      ),
                    ],
                  ),
                  AppSpaces.verticalSpace10,
                  ValueListenableBuilder(
                    valueListenable: _buttonTrigger,
                    builder: (BuildContext context, _, __) {
                      return _buttonTrigger.value == 0
                          ? const DashboardOverview()
                          : const DashboardProductivity();
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient getGradient(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
