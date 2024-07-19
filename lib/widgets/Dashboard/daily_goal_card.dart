import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/constants/back_constants.dart';
import 'package:unisoft/controllers/user_task_controller.dart';

import '../../Values/values.dart';
import '../../constants/app_constans.dart';
import '../../services/auth_service.dart';

class DailyGoalCard extends StatefulWidget {
  DailyGoalCard(
      {Key? key,
      required this.message,
      required this.allStream,
      required this.forStatusStram})
      : super(key: key);
  String message;
  Stream allStream;
  Stream forStatusStram;
  @override
  State<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends State<DailyGoalCard> {
  @override
  Widget build(BuildContext context) {
    UserTaskController userTaskController = Get.put(UserTaskController());
    DateTime nowDate = DateTime.now();
    int first = 0;
    int second = 0;
    double percent = 0.0;
    DateTime todayDate = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
      0,
      0,
      0,
    );

    return Container(
      width: 500,
      padding: const EdgeInsets.all(13.0),
      height: 150, // Adjust percentage as needed,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          color: AppColors.primaryBackgroundColor),
      child: StreamBuilder(
        stream: userTaskController.getUserTasksBetweenTowTimesStream(
            firstDate: todayDate,
            secondDate: todayDate.add(
              const Duration(days: 1),
            ),
            userId: AuthService.instance.firebaseAuth.currentUser!.uid),
        builder: (context, allTasks) {
          if (allTasks.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (allTasks.hasError) {
            return Text('Error: ${allTasks.error}');
          }
          if (allTasks.hasData) {
            return StreamBuilder(
              stream:
                  userTaskController.getUserTasksStartInADayForAStatusStream(
                      date: DateTime.now(),
                      userId:
                          AuthService.instance.firebaseAuth.currentUser!.uid,
                      status: statusDone),
              builder: (context, doneTasks) {
                if (doneTasks.hasData) {
                  first = doneTasks.data!.size;
                  second = allTasks.data!.size;
                  percent = (second != 0 ? ((first / second) * 100) : 0);
                  percent = percent / 100;
                  return dailygoal(
                    first: first,
                    second: second,
                    percent: percent,
                    message: widget.message,
                  );
                }
                return dailygoal(
                  first: first,
                  second: second,
                  percent: percent,
                  message: widget.message,
                );
              },
            );
          }
          return dailygoal(
            first: first,
            second: second,
            percent: percent,
            message: widget.message,
          );
        },
      ),
    );
  }
}

class dailygoal extends StatelessWidget {
  dailygoal({
    super.key,
    required this.first,
    required this.second,
    required this.percent,
    required this.message,
  });

  final int first;
  final int second;
  final double percent;
  String message;

  @override
  Widget build(BuildContext context) {
    //  final screenHeight = MediaQuery.of(context).size.height;
    //final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //left side
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.daily_goal_key.tr,
              style: GoogleFonts.laila(
                  color: HexColor.fromHex("FFFFFF"),
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
            AppSpaces.verticalSpace10,
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 25,
                  decoration: BoxDecoration(
                      color: HexColor.fromHex("8ACA72"),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      )),
                  child: Center(
                    child: Text(
                      '$first/$second',
                      style: GoogleFonts.laila(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                AppSpaces.horizontalSpace10,
                Text(
                  AppConstants.tasks_key.tr,
                  style: GoogleFonts.laila(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            // AppSpaces.verticalSpace10,
            Text(
              //    "${AppConstants.you_marked_key.tr}  $first $second $message  ${AppConstants.are_done_key.tr}  ",
              "  $first  $message  ${AppConstants.are_done_key.tr}  ",
              style: GoogleFonts.laila(
                  color: Colors.tealAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
//
          ],
        ),
        Stack(
          children: [
            Container(

              child: const Center(
                child: SizedBox(
                  width: 150, // Adjust the percentage as needed
                  height: 150,

                    child: Image(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        "assets/head_cut.png",
                      ),

                  ),
                ),
              ),
            ),
            Positioned(
              top: Utils.screenHeight * 0.01, // Adjust the percentage as needed
              left: Utils.screenWidth * 0.01, // Adjust the percentage as needed
              child: RotatedBox(
                quarterTurns: 4,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 0.80),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, _) => SizedBox(
                    width: Utils.screenWidth *
                        0.1, // Adjust the percentage as needed
                    height: Utils.screenWidth * 0.1,

                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
