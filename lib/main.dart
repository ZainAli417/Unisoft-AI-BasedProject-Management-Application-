import 'dart:io';
import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:sizer/sizer.dart';
import 'package:unisoft/Screens/Auth/authPage.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/services/notification_service.dart';
import 'package:unisoft/services/notifications_sender.dart';
import 'package:window_manager/window_manager.dart';

import 'constants/app_constans.dart';
import 'controllers/languageController.dart';
import 'firebase_options.dart';
import 'navigator_key.dart';
import 'utils/dep.dart' as dep;
import 'utils/messages.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 700),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    windowManager.setResizable(false);
    windowManager.setMaximizable(false);
  }

  await initFirebase();
  await initAndroidAlarmManager();
  await initFcmHandler();
  Map<String, Map<String, String>> languages = await initLanguages();
  runApp(MyApp(
    languages: languages,
  ));
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthService());
}

Future<void> initAndroidAlarmManager() async {
  if (!kIsWeb) {
    await AndroidAlarmManager.initialize();
    const int helloAlarmID = 0;
    await AndroidAlarmManager.periodic(
      const Duration(seconds: 45),
      helloAlarmID,
      checkAuth,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
}

Future<void> initFcmHandler() async {
  FirebaseMessaging.onMessage.listen(FcmNotifications.handleMessageJson);
  FirebaseMessaging.onMessageOpenedApp
      .listen(FcmNotifications.handleMessageJson);
  FirebaseMessaging.onBackgroundMessage(FcmNotifications.handleMessageJson);
  RemoteMessage? remoteMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (remoteMessage != null) {
    await FcmNotifications.handleMessageJson(remoteMessage);
  }
}

Future<Map<String, Map<String, String>>> initLanguages() async {
  return await dep.init();
}

class MyApp extends StatelessWidget {
  final Map<String, Map<String, String>> languages;
  const MyApp({super.key, required this.languages});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) =>
          GetBuilder<LocalizationController>(builder: (localizationController) {
            return GetMaterialApp(
              builder: (context, child) => ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                ],
              ),
              locale: localizationController.locale,
              translations: Messages(languages: languages),
              fallbackLocale:
              Locale(AppConstants.languageCode[1], AppConstants.countryCode[1]),
              debugShowCheckedModeBanner: false,
              home: const AuthPage(),
              navigatorKey: navigatorKey,
            );
          }),
    );
  }
}