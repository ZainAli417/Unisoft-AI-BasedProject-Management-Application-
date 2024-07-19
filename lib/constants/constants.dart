import 'package:flutter/material.dart';
import 'package:unisoft/Screens/Chat/screens/home_screen.dart';

import '../Screens/Dashboard/category.dart';
import '../Screens/Dashboard/dashboard.dart';
import '../Screens/Dashboard/invitions.dart';
import '../Screens/Dashboard/projects.dart';

import '../Values/values.dart';

String tabSpace = "\t\t\t";

final List<Widget> dashBoardScreens = [
  const Dashboard(),
   const ProjectScreen(),
   const CategoryScreen(),
  Invitions(),
  const ChatHomeScreen()
];

List<Color> progressCardGradientList = [
  //grenn
  HexColor.fromHex("87EFB5"),
  //blue
  HexColor.fromHex("8ABFFC"),
  //pink
  HexColor.fromHex("EEB2E8"),
];


