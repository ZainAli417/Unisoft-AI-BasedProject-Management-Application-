import 'package:flutter/material.dart';

import '../../Values/values.dart';

class OutlinedButtonWithText extends StatelessWidget {
  final String content;
  final double width;
  final VoidCallback? onPressed;
  const OutlinedButtonWithText(
      {Key? key, required this.content, required this.width, this.onPressed, required Icon icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(HexColor.fromHex("181A1F")),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(color: HexColor.fromHex("246EFE"), width: 2.5),
            ),
          ),
        ),
        child: Center(
          child: Text(
            content,
            style: const TextStyle(
                fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
