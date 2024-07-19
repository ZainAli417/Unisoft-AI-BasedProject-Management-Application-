import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Values/values.dart';

class PrimaryProgressButton extends StatelessWidget {
  final String label;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final VoidCallback? callback;
  const PrimaryProgressButton({
    Key? key,
    required this.label,
    this.callback,
    this.width,
    this.height,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      child: ElevatedButton(
        onPressed: callback,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(HexColor.fromHex("246CFE")),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(
                color: HexColor.fromHex("246CFE"),
              ),
            ),
          ),
        ),
        child: Text(
          label,
          style: textStyle ??
              GoogleFonts.laila(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
        ),
      ),
    );
  }
}
