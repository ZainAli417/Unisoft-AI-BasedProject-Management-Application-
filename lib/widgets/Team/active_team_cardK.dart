import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/models/team/Team_model.dart';

import '../../Values/values.dart';

import '../dummy/profile_dummy.dart';

class ActiveTeamCard extends StatelessWidget {
  final String teamName;
  final VoidCallback onTap;
  final String teamImage;
  final int numberOfMembers;
  final TeamModel team;
  final ImageType imageType;
  const ActiveTeamCard(
      {Key? key,
      required this.imageType,
      required this.onTap,
      required this.team,
      required this.teamName,
      required this.teamImage,
      required this.numberOfMembers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: Utils.screenWidth * 0.03,
            vertical: Utils.screenWidth * 0.02),
        width: 800,
        height: 80,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink, AppColors.lightMauveBackgroundColor],
            ),
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: HexColor.fromHex("181A1F")),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ProfileDummy(
                        imageType: imageType,
                        dummyType: ProfileDummyType.Image,
                        scale: 2,
                        color: null,
                        image: teamImage,
                      ),
                      AppSpaces.horizontalSpace20,
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(
                                teamName,
                                style: GoogleFonts.laila(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 10, // Adjust the percentage as needed
                                width:10, // Adjust the percentage as needed
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5, // Adjust the percentage as needed
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                    //color: HexColor.fromHex(color),
                                    border: Border.all(
                                        color: Colors.blue, width: 1),
                                    borderRadius: BorderRadius.circular(50.0)),
                                child: Text(
                                  "$numberOfMembers  ${AppConstants.members_key.tr}",
                                  style: GoogleFonts.laila(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ])
                          ])
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
