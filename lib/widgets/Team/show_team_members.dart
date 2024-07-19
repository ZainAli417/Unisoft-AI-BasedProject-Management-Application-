// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/Projects/searchForMembers.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/team_member_controller.dart';
import 'package:unisoft/controllers/userController.dart';
import 'package:unisoft/controllers/waitingMamberController.dart';
import 'package:unisoft/models/User/User_model.dart';
import 'package:unisoft/models/team/Manger_model.dart';
import 'package:unisoft/models/team/Team_model.dart';
import 'package:unisoft/models/team/waitingMamber.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';
import 'package:unisoft/widgets/active_employee_card.dart';
import 'package:unisoft/widgets/inactive_employee_card.dart';
import '../../Values/values.dart';
import '../../models/team/TeamMembers_model.dart';
import '../../widgets/Buttons/primary_buttons.dart';
import '../../widgets/DarkBackground/darkRadialBackground.dart';
import '../../widgets/Navigation/app_header.dart';
import '../dummy/profile_dummy.dart';

class ShowTeamMembers extends StatelessWidget {
  final TeamModel teamModel;
  final ManagerModel? userAsManager;
  const ShowTeamMembers({
    required this.userAsManager,
    required this.teamModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DarkRadialBackground(
          color: HexColor.fromHex("#181a1f"),
          position: "topLeft",
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(
                left:
                    Utils.screenWidth * 0.04, // Adjust the percentage as needed
                right: Utils.screenWidth * 0.04,
              ),
              child: TaskezAppHeader(
                title: AppConstants.members_key.tr,
                widget: GestureDetector(
                  onTap: () async {
                    //TODO:

                    // bool fcmStutas =
                    //     await FcmNotifications.getNotificationStatus();
                    // Get.to(() => ProfileOverview(
                    //       isSelected: fcmStutas,
                    //     ));
                  },
                  child: FutureBuilder<UserModel>(
                      future: UserController()
                          .getUserWhereMangerIs(mangerId: teamModel.managerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return GestureDetector(
                          onTap: () {
                            CustomDialog.userInfoDialog(
                                title: AppConstants.team_leader_key.tr,
                                imageUrl: snapshot.data!.imageUrl,
                                name: snapshot.data!.name!,
                                userName: snapshot.data!.userName!,
                                bio: snapshot.data!.bio);
                          },
                          child: ProfileDummy(
                            imageType: ImageType.Network,
                            color: Colors.white,
                            dummyType: ProfileDummyType.Image,
                            image: snapshot.data!.imageUrl,
                            scale: 1.2,
                          ),
                        );
                      }),
                ),
              ),
            ),
            AppSpaces.verticalSpace40,
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecorationStyles.fadingGlory,
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: DecoratedBox(
                    decoration: BoxDecorationStyles.fadingInnerDecor,
                    child:   Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSpaces.verticalSpace20,
                            Expanded(
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child:
                                    StreamBuilder<
                                            QuerySnapshot<TeamMemberModel>>(
                                        stream: TeamMemberController()
                                            .getMembersInTeamIdStream(
                                                teamId: teamModel.id),
                                        builder:
                                            (context, snapshotTeamMembers) {
                                          List<String> usersId = [];
                                          if (snapshotTeamMembers
                                                  .connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          }

                                          if (snapshotTeamMembers.hasError) {
                                            return Center(
                                              child: Text(
                                                  snapshotTeamMembers.error
                                                      .toString(),
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Colors.red)),
                                            );
                                          }
                                          for (var member in snapshotTeamMembers
                                              .data!.docs) {
                                            usersId.add(member.data().userId);
                                          }
                                          return StreamBuilder<
                                              QuerySnapshot<
                                                  WaitingMemberModel>>(
                                            stream: WaitingMamberController()
                                                .getWaitingMembersInTeamIdStream(
                                                    teamId: teamModel.id),
                                            builder:
                                                (context, snapShotWatingUsers) {
                                              if (snapShotWatingUsers
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              }

                                              if (snapShotWatingUsers.hasData) {
                                                for (var member
                                                    in snapShotWatingUsers
                                                        .data!.docs) {
                                                  usersId.add(
                                                      member.data().userId);
                                                }
                                              }
                                              if (usersId.isEmpty) {
                                                return Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
//
                                                    Icon(
                                                      Icons.search_off,
                                                      color: Colors.red,
                                                      size: Utils.screenWidth *
                                                          0.27,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: Utils
                                                                .screenWidth *
                                                            0.1, // Adjust the percentage as needed
                                                        vertical:
                                                            Utils.screenHeight *
                                                                0.05,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          AppConstants
                                                              .no_any_members_yet_key
                                                              .tr,
                                                          style: GoogleFonts
                                                              .fjallaOne(
                                                            color: Colors.white,
                                                            fontSize: Utils
                                                                    .screenWidth *
                                                                0.1,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }
                                              return StreamBuilder<
                                                      QuerySnapshot<UserModel>>(
                                                  stream: UserController()
                                                      .getUsersWhereInIdsStream(
                                                          usersId: usersId),
                                                  builder:
                                                      (context, snapshotUsers) {
                                                    if (snapshotUsers
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return CircularProgressIndicator();
                                                    }
                                                    return ListView.builder(
                                                      itemCount: snapshotUsers
                                                          .data!.size,
                                                      itemBuilder:
                                                          (context, index) {
                                                        print(snapshotUsers
                                                            .data!.size);
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 3,
                                                                  vertical: 6),
                                                          child: Slidable(
                                                            endActionPane: userAsManager !=
                                                                        null &&
                                                                    teamModel
                                                                            .managerId ==
                                                                        userAsManager
                                                                            ?.id
                                                                ? index <
                                                                        snapshotTeamMembers
                                                                            .data!
                                                                            .size
                                                                    ? ActionPane(
                                                                        motion:
                                                                            StretchMotion(),
                                                                        children: [
                                                                            SlidableAction(
                                                                              backgroundColor: Colors.red,
                                                                              borderRadius: BorderRadius.circular(16),
                                                                              onPressed: (context) {
                                                                                print("object deete");
                                                                                CustomDialog.showConfirmDeleteDialog(
                                                                                    onDelete: () async {
                                                                                      print("delete member");
                                                                                      await TeamMemberController().deleteMember(id: snapshotTeamMembers.data!.docs[index].data().id);
                                                                                      Get.back();
                                                                                    },
                                                                                    content: Text("${AppConstants.confirm_delete_key.tr} ${snapshotUsers.data!.docs[index].data().name} ${AppConstants.from_this_team_key.tr}"));
                                                                              },
                                                                              label: AppConstants.delete_key.tr,
                                                                              icon: FontAwesomeIcons.trash,
                                                                            ),
                                                                          ])
                                                                    : ActionPane(
                                                                        motion:
                                                                            StretchMotion(),
                                                                        children: [
                                                                            SlidableAction(
                                                                              backgroundColor: Colors.red,
                                                                              borderRadius: BorderRadius.circular(16),
                                                                              onPressed: (context) async {
                                                                                showDialogMethod(context);
                                                                                await WaitingMamberController().deleteWaitingMamberDoc(waitingMemberId: snapShotWatingUsers.data!.docs[index].data().id);
                                                                                Get.key.currentState!.pop();
                                                                                print(snapShotWatingUsers.data!.docs[index].data().userId);
                                                                                print("object delete waitiing member");
                                                                              },
                                                                              label: AppConstants.delete_key.tr,
                                                                              icon: FontAwesomeIcons.trash,
                                                                            ),
                                                                          ])
                                                                : null,
                                                            startActionPane: index <
                                                                    snapshotTeamMembers
                                                                        .data!
                                                                        .size
                                                                ? userAsManager !=
                                                                            null &&
                                                                        teamModel.managerId ==
                                                                            userAsManager?.id
                                                                    ? null
                                                                    : null
                                                                : null,
                                                            child: index <
                                                                    snapshotTeamMembers
                                                                        .data!
                                                                        .size
                                                                ? ActiveEmployeeCard(
                                                                    onTap: () {
                                                                      CustomDialog.userInfoDialog(
                                                                          title: AppConstants
                                                                              .member_key
                                                                              .tr,
                                                                          imageUrl: snapshotUsers
                                                                              .data!
                                                                              .docs[
                                                                                  index]
                                                                              .data()
                                                                              .imageUrl,
                                                                          name: snapshotUsers
                                                                              .data!
                                                                              .docs[
                                                                                  index]
                                                                              .data()
                                                                              .name!,
                                                                          userName: snapshotUsers
                                                                              .data!
                                                                              .docs[
                                                                                  index]
                                                                              .data()
                                                                              .userName!,
                                                                          bio: snapshotUsers
                                                                              .data!
                                                                              .docs[index]
                                                                              .data()
                                                                              .bio);
                                                                    },
                                                                    notifier:
                                                                        null,
                                                                    userImage: snapshotUsers
                                                                        .data!
                                                                        .docs[
                                                                            index]
                                                                        .data()
                                                                        .imageUrl,
                                                                    userName: AuthService.instance.firebaseAuth.currentUser!.uid ==
                                                                            snapshotUsers.data!.docs[index]
                                                                                .data()
                                                                                .id
                                                                        ? AppConstants
                                                                            .you_key
                                                                            .tr
                                                                        : snapshotUsers
                                                                            .data!
                                                                            .docs[index]
                                                                            .data()
                                                                            .name!,
                                                                    color: null,
                                                                    bio: snapshotUsers
                                                                            .data!
                                                                            .docs[index]
                                                                            .data()
                                                                            .bio ??
                                                                        " ",
                                                                  )
                                                                : Visibility(
                                                                    visible: userAsManager !=
                                                                            null &&
                                                                        teamModel.managerId ==
                                                                            userAsManager?.id,
                                                                    child:
                                                                        InactiveEmployeeCard(
                                                                      onTap:
                                                                          () {
                                                                        CustomDialog.userInfoDialog(
                                                                            title:
                                                                                AppConstants.invited_not_a_member_yet_key.tr,
                                                                            imageUrl: snapshotUsers.data!.docs[index].data().imageUrl,
                                                                            name: snapshotUsers.data!.docs[index].data().name!,
                                                                            userName: snapshotUsers.data!.docs[index].data().userName!,
                                                                            bio: snapshotUsers.data!.docs[index].data().bio);
                                                                      },
                                                                      userName: AuthService.instance.firebaseAuth.currentUser!.uid == snapshotUsers.data!.docs[index].data().id
                                                                          ? AppConstants
                                                                              .you_key
                                                                              .tr
                                                                          : snapshotUsers
                                                                              .data!
                                                                              .docs[index]
                                                                              .data()
                                                                              .name!,
                                                                      color:
                                                                          null,
                                                                      userImage: snapshotUsers
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                          .data()
                                                                          .imageUrl,
                                                                      bio: snapshotUsers
                                                                              .data!
                                                                              .docs[index]
                                                                              .data()
                                                                              .bio ??
                                                                          "",
                                                                    ),
                                                                  ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  });
                                            },
                                          );
                                        }),
                              ),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
            ),
            //AppSpaces.verticalSpace20,
            Visibility(
              visible: userAsManager != null &&
                  teamModel.managerId == userAsManager?.id,
              child: AppPrimaryButton(
                  buttonHeight: 50,
                  buttonWidth: 150,
                  buttonText: AppConstants.add_member_key.tr,
                  callback: () {
                    Get.to(
                      () => SearchForMembers(
                        teamModel: teamModel,
                        users: null,
                        newTeam: false,
                      ),
                    );
                  }),
            ),
            AppSpaces.verticalSpace20,
          ]),
        ),
      ]),
    );
  }

//  void GoToCommon(String projectId, bool isManager) {}
}
