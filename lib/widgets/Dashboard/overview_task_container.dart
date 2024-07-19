import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Values/values.dart';

class OverviewTaskContainer extends StatelessWidget {
  final Color backgroundColor;
  final String numberOfItems;
  final String cardTitle;
  final VoidCallback? onButtonClick;
  const OverviewTaskContainer(
      {Key? key,
      required this.backgroundColor,
      required this.cardTitle,
      this.onButtonClick,
      required this.numberOfItems})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onButtonClick != null) {
          onButtonClick!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical:5.0),
        child: Container(
          width: 550,
          padding: const EdgeInsets.all(5),
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primaryBackgroundColor,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppSpaces.horizontalSpace10,
                  Text(
                    cardTitle,
                    style: GoogleFonts.laila(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  )
                ],
              ),
              Row(children: [
                Text(
                  numberOfItems,
                  style: GoogleFonts.laila(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20),
                ),
                AppSpaces.horizontalSpace20,
                //                const Icon(Icons.chevron_right, color: Colors.white, size: 30)
              ])
            ],
          ),
        ),
      ),
    );
  }
}
