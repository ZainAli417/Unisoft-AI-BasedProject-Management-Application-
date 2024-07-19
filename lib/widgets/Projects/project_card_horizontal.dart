import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/widgets/Projects/project_badge.dart';
import 'package:intl/intl.dart';
import '../../Values/values.dart';

class ProjectCardHorizontal extends StatelessWidget {
  final String projectName;
  final String projeImagePath;
  final String teamName;
  final DateTime endDate;
  final DateTime startDate;
  final String status;
  final String idk;
  String startDateString = "";
  String endDateString = "";
  ProjectCardHorizontal({
    Key? key,
    required this.idk,
    required this.status,
    required this.teamName,
    required this.projectName,
    required this.projeImagePath,
    required this.endDate,
    required this.startDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child:  SizedBox(
        width: 800,
        height: 500,
        child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: HexColor.fromHex("20222A"),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ColouredProjectBadge(projeImagePath: projeImagePath),
        const SizedBox(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    projectName,
                    style: GoogleFonts.laila(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: Utils.screenHeight * 0.01),
                  Row(children: [
                    InkWell(
                      child: Text(
                        "${AppConstants.team_key.tr} : ",
                        style: TextStyle(
                          color: HexColor.fromHex("246CFE"),
                        ),
                      ),
                    ),
                    Text(
                      teamName,
                      style: TextStyle(
                        color: HexColor.fromHex("#FFFFFF"),
                      ),
                    ),
                  ]),
                  Row(
                    children: [
                      Text(
                        "${AppConstants.status_key.tr} : ",
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("246CFE"),
                        ),
                      ),
                      Text(
                        status,
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("#FFFFFF"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppConstants.start_date_key.tr}  : ",
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("246CFE"),
                        ),
                      ),
                      Text(
                        formatDateTime(startDate),
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("#FFFFFF"),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppConstants.end_date_key.tr} : ",
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("246CFE"),
                        ),
                      ),
                      Text(
                        formatDateTime(endDate),
                        style: GoogleFonts.laila(
                          color: HexColor.fromHex("#FFFFFF"),
                        ),
                      ),
                    ],
                  ),
                ])
              ]),
            ]),
        AppSpaces.verticalSpace10,
      ]),
    ),
        ),
    );
  }
}

String formatDateTime(DateTime dateTime) {
  DateTime now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    return "${AppConstants.today_key.tr} ${DateFormat('h:mm a').format(dateTime)}";
  } else {
    return DateFormat('dd/MM h:mm a').format(dateTime);
  }
}
