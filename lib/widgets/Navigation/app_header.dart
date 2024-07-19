import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Values/values.dart';

import 'back_button.dart';

class TaskezAppHeader extends StatelessWidget {
  final String title;
  final bool? messagingPage;
  final Widget? widget;
  const TaskezAppHeader(
      {Key? key, this.widget, required this.title, this.messagingPage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const AppBackButton(),
        (messagingPage != null)
            ? Row(children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HexColor.fromHex("94D57B"),
                  ),
                ),
                const SizedBox(
                    width: 20), // Adjust the percentage as needed

                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    title,
                    style: GoogleFonts.laila(
                        fontSize:20, // Adjust the percentage as needed

                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ])
            : Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  title,
                  style: GoogleFonts.laila(
                      fontSize: 22, // Adjust the percentage as needed
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
        widget!
      ]),
    );
  }
}
