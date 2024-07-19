import 'package:flutter/material.dart';
import 'package:unisoft/Values/values.dart';

class SquareButtonIcon extends StatelessWidget {
  SquareButtonIcon({super.key, required this.imagePath, required this.onTap});
  String imagePath;
  Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
     child:  Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Utils.screenWidth * 0.12,
                vertical: Utils.screenHeight * 0.0001,
              ),

              child: Image.asset(
                imagePath,
                height: Utils.screenHeight * 0.3,
                width: 200,
              ),
            ),
          ),
        ],
      )
    );
  }
}
