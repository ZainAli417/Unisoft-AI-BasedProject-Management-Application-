// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/constants/app_constans.dart';
import '../../Values/values.dart';

class LabelledFormInput extends StatelessWidget {
  final AutovalidateMode? autovalidateMode;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final void Function()? onClear;
  final String label;
  final String placeholder;
  final String? value;
  final String keyboardType;
  bool obscureText;
  final bool readOnly;
  final TextEditingController controller;
  LabelledFormInput(
      {Key? key,
      required this.autovalidateMode,
      this.onClear,
      this.onChanged,
      this.validator,
      required this.readOnly,
      required this.placeholder,
      required this.keyboardType,
      required this.controller,
      this.obscureText = false,
      required this.label,
      this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpaces.verticalSpace10,
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.left,
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextFormField(
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          controller: controller,
          readOnly: readOnly,
          style: GoogleFonts.lato(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          onTap: () {},
          keyboardType: keyboardType == "text"
              ? TextInputType.text
              : TextInputType.number,
          //initialValue: initialValue,
          obscureText: obscureText,

          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 20,
            ),
            suffixIcon: controller.text.isEmpty
                ? null
                : placeholder == AppConstants.password_key.tr ||
                        placeholder == 'Choose a password' ||
                        placeholder == AppConstants.confirm_key.tr
                    ? InkWell(
                        onTap: onClear,
                        child: obscureText
                            ? const Icon(FontAwesomeIcons.eyeSlash,
                                color: Colors.white, size: 20)
                            : const Icon(FontAwesomeIcons.eye,
                                color: Colors.white, size: 20),
                      )
                    : InkWell(
                        onTap: onClear,
                        child: const Icon(FontAwesomeIcons.solidTimesCircle,
                            color: Colors.white, size: 20),
                      ),
            hintText: placeholder,
            hintStyle: GoogleFonts.lato
              (
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey[500]
            ),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HexColor.fromHex("#FFFFFF")),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color:Colors.cyanAccent),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
          ),
          //  textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
