import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:get/get.dart';
import 'package:unisoft/Values/values.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/project_sub_task_controller.dart';
import 'package:unisoft/controllers/statusController.dart';
import 'package:unisoft/controllers/team_member_controller.dart';
import 'package:unisoft/models/statusmodel.dart';
import 'package:unisoft/models/team/Project_sub_task_Model.dart';
import 'package:unisoft/models/team/TeamMembers_model.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Dashboard/create_sub_task.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../BottomSheets/bottom_sheets.dart';
import '../../constants/back_constants.dart';
import '../../controllers/manger_controller.dart';
import '../../controllers/projectController.dart';
import '../../controllers/project_main_task_controller.dart';
import '../../controllers/teamController.dart';
import '../../controllers/topController.dart';
import '../../controllers/userController.dart';
import '../../controllers/waitingSubTasks.dart';
import '../../models/User/User_model.dart';
import 'package:intl/intl.dart';

import '../../models/team/Manger_model.dart';
import '../../models/team/Project_main_task_Model.dart';
import '../../models/team/Project_model.dart';
import '../../models/team/Team_model.dart';
import '../../models/team/waitingSubTasksModel.dart';

import '../../services/collectionsrefrences.dart';
import '../../services/notification_service.dart';
import '../../services/types.dart';
import '../Snackbar/custom_snackber.dart';
import '../User/focused_menu_item.dart';
import '../User/inactive_employee_card_sub_task.dart';

enum TaskStatus {
  notDone,
  inProgress,
  done,
  notStarted,
}

class TaskWidget extends StatelessWidget {
  final TaskStatus status;

  const TaskWidget({required this.status, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case TaskStatus.notDone:
        icon = Icons.clear;
        color = Colors.red;
        statusText = AppConstants.not_done_key.tr;
        break;
      case TaskStatus.inProgress:
        icon = Icons.access_time;
        color = Colors.orange;
        statusText = AppConstants.in_progress_key.tr;
        break;
      case TaskStatus.done:
        icon = Icons.check;
        color = Colors.greenAccent;
        statusText = AppConstants.done_key.tr;
      case TaskStatus.notStarted:
        icon = Icons.schedule;
        color = Colors.amberAccent;
        statusText = AppConstants.not_started_key.tr;
        break;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class SubTaskCard extends StatefulWidget {
  const SubTaskCard({
    required this.task,
    required this.primary,
    required this.onPrimary,
    Key? key,
  }) : super(key: key);
  final ProjectSubTaskModel task;
  final Color primary;
  final Color onPrimary;

  @override
  State<SubTaskCard> createState() => _SubTaskCardState();
}

class _SubTaskCardState extends State<SubTaskCard> {
  String taskStatus = "";
  String name = "";
  String? image;
  String bio = "";
  @override
  void initState() {
    ismanagerStream();
    super.initState();
    _fetchDownloadLinks();
  }

  List<String> _downloadLinks = [];
  bool _isLoading = false;
  void _fetchDownloadLinks() async {
    setState(() {
      _isLoading = true;
    });
    _downloadLinks = await fetchFileDownloadLinks(widget.task.projectId);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await launchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<List<String>> fetchFileDownloadLinks(String projectId) async {
    List<String> downloadLinks = [];
    try {
      // Get all the files under the specific projectId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('project_attachments')
          .doc(widget.task.projectId)
          .collection('files')
          .get();

      // Iterate through each file document to extract the URL
      for (var doc in querySnapshot.docs) {
        String downloadUrl = doc[
            'fileUrl']; // Adjust based on actual field name in your metadata
        downloadLinks.add(downloadUrl);
      }
    } catch (e) {
      print('Error fetching file download links: $e');
    }
    return downloadLinks;
  }

  ismanagerStream() async {
    ProjectModel? projectModel =
        await ProjectController().getProjectById(id: widget.task.projectId);
    Stream<DocumentSnapshot<ManagerModel>> managerModelStream =
        ManagerController().getMangerByIdStream(id: projectModel!.managerId);
    Stream<DocumentSnapshot<UserModel>> userModelStream;

    StreamSubscription<DocumentSnapshot<ManagerModel>> managerSubscription;
    StreamSubscription<DocumentSnapshot<UserModel>> userSubscription;

    managerSubscription = managerModelStream.listen((managerSnapshot) {
      ManagerModel manager = managerSnapshot.data()!;
      userModelStream =
          UserController().getUserWhereMangerIsStream(mangerId: manager.id);
      userSubscription = userModelStream.listen((userSnapshot) {
        UserModel user = userSnapshot.data()!;
        bool updatedIsManager;
        if (user.id != AuthService.instance.firebaseAuth.currentUser!.uid) {
          print(
              "${user.id}/////${AuthService.instance.firebaseAuth.currentUser!.uid}");
          updatedIsManager = false;
        } else {
          updatedIsManager = true;
        }
        print(updatedIsManager);
        // Update the state and trigger a rebuild
        isManager.value = updatedIsManager;
      });
    });
  }

  RxBool isManager = false.obs;

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot<UserModel>> steam = UserController()
        .getUserWhereMemberIsStream(memberId: widget.task.assignedTo)
        .asBroadcastStream();
    StatusController statusController = Get.put(StatusController());
    StatusModel? statusModel;

    taskStatus = " ";
    return Obx(() => isManager.value
        ? FocusedMenu(
            onClick: () {
              print("hello");
            },
            deleteButton: () async {
              print(1);
              ProjectSubTaskController userTaskController =
                  Get.put(ProjectSubTaskController());
              await userTaskController.deleteProjectSubTask(id: widget.task.id);
            },
            editButton: () {
              showAppBottomSheet(
                CreateSubTask(
                  userTaskModel: widget.task,
                  projectId: widget.task.projectId,
                  checkExist: ({required String name}) async {
                    bool s;
                    s = await TopController().existByTow(
                        reference: projectSubTasksRef,
                        value: widget.task.mainTaskId,
                        field: mainTaskIdK,
                        value2: name,
                        field2: nameK);
                    s = await TopController().existByTow(
                        reference: watingSubTasksRef,
                        value: widget.task.mainTaskId,
                        field: "subTask.$mainTaskIdK",
                        value2: name,
                        field2: "subTask.$nameK");
                    return s;
                  },
                  addTask: (
                      {required int priority,
                      required String taskName,
                      required DateTime startDate,
                      required DateTime dueDate,
                      required String? desc,
                      required String color,
                      required String userIdAssignedTo}) async {
                    ProjectSubTaskModel projectSubTaskModel =
                        await ProjectSubTaskController()
                            .getProjectSubTaskById(id: widget.task.id);
                    ProjectMainTaskModel mainTask =
                        await ProjectMainTaskController()
                            .getProjectMainTaskById(
                                id: projectSubTaskModel.mainTaskId);
                    if (!projectSubTaskModel.startDate
                            .isAfter(mainTask.startDate) ||
                        !projectSubTaskModel.endDate!
                            .isBefore(mainTask.endDate!)) {
                      throw Exception(AppConstants
                          .sub_task_dates_between_main_task_dates_key.tr);
                    }
                    TeamMemberModel memberModelold =
                        await TeamMemberController().getMemberById(
                            memberId: projectSubTaskModel.assignedTo);
                    ProjectModel? projectModel = await ProjectController()
                        .getProjectById(id: projectSubTaskModel.projectId);
                    print(projectModel!.teamId!);
                    String s = projectModel.teamId!;
                    TeamModel teamModel =
                        await TeamController().getTeamById(id: s);
                    TeamMemberModel newteamMemberModel =
                        await TeamMemberController().getMemberByTeamIdAndUserId(
                            teamId: teamModel.id, userId: userIdAssignedTo);
                    if ((projectSubTaskModel.startDate != startDate ||
                            projectSubTaskModel.endDate != dueDate ||
                            memberModelold.id != newteamMemberModel.id) &&
                        taskStatus != statusNotStarted) {
                      CustomSnackBar.showError(
                          "Cannot Edit Assignees or Start time and end time of NOT DONE/DONE/Running task");
                      return;
                    }
                    if (startDate.isAfter(dueDate) ||
                        startDate.isAtSameMomentAs(dueDate)) {
                      CustomSnackBar.showError(AppConstants
                          .start_date_cannot_be_after_end_date_or_in_the_same_time_or_before_the_current_date_key
                          .tr);
                      return;
                    }
                    if (memberModelold.id != newteamMemberModel.id) {
                      try {
                        bool overlapped = false;
                        int over = 0;
                        List<ProjectSubTaskModel> list =
                            await ProjectSubTaskController().getMemberSubTasks(
                                memberId: newteamMemberModel.id);
                        for (ProjectSubTaskModel existingTask in list) {
                          if (projectSubTaskModel.startDate
                                  .isBefore(existingTask.endDate!) &&
                              projectSubTaskModel.endDate!
                                  .isAfter(existingTask.startDate)) {
                            overlapped = true;
                            over += 1;
                          }
                        }
                        if (overlapped) {
                          Get.defaultDialog(
                            title: "Task Time Error",
                            middleText:
                                "There is $over task That start in this time \n for the new assigned user \n Would you Like To assign the Task Any Way?",
                            onConfirm: () async {
                              StatusModel statusModel = await statusController
                                  .getStatusByName(status: statusNotStarted);
                              await ProjectSubTaskController()
                                  .deleteProjectSubTask(
                                      id: projectSubTaskModel.id);
                              ProjectSubTaskModel updatedprojectSubTaskModel =
                                  ProjectSubTaskModel(
                                      assignedToParameter:
                                          newteamMemberModel.id,
                                      mainTaskIdParameter:
                                          projectSubTaskModel.mainTaskId,
                                      hexColorParameter: color,
                                      projectIdParameter:
                                          projectSubTaskModel.projectId,
                                      descriptionParameter: desc!,
                                      idParameter: projectMainTasksRef.doc().id,
                                      nameParameter: taskName,
                                      statusIdParameter: statusModel.id,
                                      importanceParameter: priority,
                                      createdAtParameter: DateTime.now(),
                                      updatedAtParameter: DateTime.now(),
                                      startDateParameter: startDate,
                                      endDateParameter: dueDate);
                              // await ProjectSubTaskController()
                              //     .addProjectSubTask(projectsubTaskModel: userTaskModel);
                              String waitingid = watingSubTasksRef.doc().id;
                              WaitingSubTaskModel waitingSubTaskModel =
                                  WaitingSubTaskModel(
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      id: waitingid,
                                      projectSubTaskModel: projectSubTaskModel);
                              WatingSubTasksController
                                  waitingSubTaskController =
                                  Get.put(WatingSubTasksController());
                              await waitingSubTaskController.addWatingSubTask(
                                  waitingSubTaskModel: waitingSubTaskModel);
                              FcmNotifications fcmNotifications =
                                  Get.put(FcmNotifications());
                              UserModel userModelnewAssigned =
                                  await UserController()
                                      .getUserById(id: userIdAssignedTo);
                              UserModel userModelOldAssigned =
                                  await UserController()
                                      .getUserById(id: memberModelold.userId);
                              await fcmNotifications.sendNotificationAsJson(
                                  fcmTokens: userModelnewAssigned.tokenFcm,
                                  title: "you have a task ",
                                  data: {"id": waitingid},
                                  body:
                                      "the project ${projectModel.name}. The task is titled ${projectSubTaskModel.name}. Please review the task details and take necessary action.",
                                  type: NotificationType.taskRecieved);
                              await fcmNotifications.sendNotificationAsJson(
                                  fcmTokens: userModelOldAssigned.tokenFcm,
                                  title:
                                      "the task ${updatedprojectSubTaskModel.name} have benn unassigned",
                                  body:
                                      "the project ${projectModel.name}. The task is titled ${projectSubTaskModel.name}. Please review the task details and take necessary action.",
                                  type: NotificationType.notification);
                              CustomSnackBar.showSuccess(
                                  "task $taskName sended to member successfully");
                              Get.key.currentState!.pop();
                              Get.key.currentState!.pop();
                            },
                            onCancel: () {
                              Get.back();
                            },
                          );
                        } else {
                          StatusModel statusModel = await statusController
                              .getStatusByName(status: statusNotStarted);
                          await ProjectSubTaskController()
                              .deleteProjectSubTask(id: projectSubTaskModel.id);
                          ProjectSubTaskModel updatedprojectSubTaskModel =
                              ProjectSubTaskModel(
                                  assignedToParameter: newteamMemberModel.id,
                                  mainTaskIdParameter:
                                      projectSubTaskModel.mainTaskId,
                                  hexColorParameter: color,
                                  projectIdParameter:
                                      projectSubTaskModel.projectId,
                                  descriptionParameter: desc!,
                                  idParameter: projectMainTasksRef.doc().id,
                                  nameParameter: taskName,
                                  statusIdParameter: statusModel.id,
                                  importanceParameter: priority,
                                  createdAtParameter: DateTime.now(),
                                  updatedAtParameter: DateTime.now(),
                                  startDateParameter: startDate,
                                  endDateParameter: dueDate);
                          // await ProjectSubTaskController()
                          //     .addProjectSubTask(projectsubTaskModel: userTaskModel);
                          String waitingid = watingSubTasksRef.doc().id;
                          WaitingSubTaskModel waitingSubTaskModel =
                              WaitingSubTaskModel(
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  id: waitingid,
                                  projectSubTaskModel: projectSubTaskModel);
                          WatingSubTasksController waitingSubTaskController =
                              Get.put(WatingSubTasksController());
                          await waitingSubTaskController.addWatingSubTask(
                              waitingSubTaskModel: waitingSubTaskModel);
                          FcmNotifications fcmNotifications =
                              Get.put(FcmNotifications());
                          UserModel userModelnewAssigned =
                              await UserController()
                                  .getUserById(id: userIdAssignedTo);
                          UserModel userModelOldAssigned =
                              await UserController()
                                  .getUserById(id: memberModelold.userId);
                          await fcmNotifications.sendNotificationAsJson(
                              fcmTokens: userModelnewAssigned.tokenFcm,
                              title: "you have a task ",
                              data: {"id": waitingid},
                              body:
                                  "the project ${projectModel.name}. The task is titled ${projectSubTaskModel.name}. Please review the task details and take necessary action.",
                              type: NotificationType.taskRecieved);
                          await fcmNotifications.sendNotificationAsJson(
                              fcmTokens: userModelOldAssigned.tokenFcm,
                              title:
                                  "the task ${updatedprojectSubTaskModel.name} have been unassigned",
                              body:
                                  "the project ${projectModel.name}. The task is titled ${projectSubTaskModel.name}. Please review the task details and take necessary action.",
                              type: NotificationType.notification);
                          CustomSnackBar.showSuccess(
                              "task $taskName sended to member successfully");
                          Get.key.currentState!.pop();
                        }
                        return;
                      } catch (e) {
                        CustomSnackBar.showError(e.toString());
                      }
                    }
                    if (startDate != projectSubTaskModel.startDate ||
                        dueDate != projectSubTaskModel.endDate) {
                      bool overlapped = false;
                      int over = 0;
                      List<ProjectSubTaskModel> list =
                          await ProjectSubTaskController()
                              .getMemberSubTasks(memberId: memberModelold.id);
                      for (ProjectSubTaskModel existingTask in list) {
                        if (projectSubTaskModel.startDate
                                .isBefore(existingTask.endDate!) &&
                            projectSubTaskModel.endDate!
                                .isAfter(existingTask.startDate)) {
                          overlapped = true;
                          over += 1;
                        }
                      }
                      if (overlapped) {
                        Get.defaultDialog(
                          title: "Task Time Error",
                          middleText:
                              "There is $over task That start in this time \n for the new assigned user \n Would you Like To assign the Task Any Way?",
                          onConfirm: () async {
                            await ProjectSubTaskController().updateSubTask(
                                isfromback: false,
                                data: {
                                  nameK: taskName,
                                  startDateK: startDate,
                                  endDateK: dueDate,
                                  descriptionK: desc,
                                  colorK: color,
                                  importanceK: priority,
                                },
                                id: widget.task.id);
                            FcmNotifications fcmNotifications =
                                Get.put(FcmNotifications());

                            UserModel userModelOldAssigned =
                                await UserController()
                                    .getUserById(id: memberModelold.userId);

                            await fcmNotifications.sendNotificationAsJson(
                                fcmTokens: userModelOldAssigned.tokenFcm,
                                title:
                                    "the task $taskName time have been changed",
                                body:
                                    "the new start time is $startDate and the new due time is $dueDate",
                                type: NotificationType.notification);
                            Get.key.currentState!.pop();
                            Get.key.currentState!.pop();
                          },
                          onCancel: () {
                            Get.back();
                          },
                        );
                      } else {
                        await ProjectSubTaskController().updateSubTask(
                            isfromback: false,
                            data: {
                              nameK: taskName,
                              startDateK: startDate,
                              endDateK: dueDate,
                              descriptionK: desc,
                              colorK: color,
                              importanceK: priority,
                            },
                            id: widget.task.id);
                        FcmNotifications fcmNotifications =
                            Get.put(FcmNotifications());

                        UserModel userModelOldAssigned = await UserController()
                            .getUserById(id: memberModelold.userId);

                        await fcmNotifications.sendNotificationAsJson(
                            fcmTokens: userModelOldAssigned.tokenFcm,
                            title: "the task $taskName time have been changed",
                            body:
                                "the new start time is $startDate and the new due time is $dueDate",
                            type: NotificationType.notification);

                        CustomSnackBar.showSuccess(
                            "task $taskName sended to member successfully");
                        Get.key.currentState!.pop();
                      }
                    }
                    try {
                      await ProjectSubTaskController().updateSubTask(
                          isfromback: false,
                          data: {
                            nameK: taskName,
                            startDateK: startDate,
                            endDateK: dueDate,
                            descriptionK: desc,
                            colorK: color,
                            importanceK: priority,
                          },
                          id: widget.task.id);
                    } catch (e) {
                      CustomSnackBar.showError(e.toString());
                    }
                  },
                  isEditMode: true,
                ),
                isScrollControlled: true,
                popAndShow: false,
              );
            },
            widget: Opacity(
              opacity: getOpacity(widget.task.importance),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  child: Container(
                    width: 300,
                    height: 450,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.primary,
                          widget.primary.withOpacity(.7)
                        ],
                        begin: AlignmentDirectional.topCenter,
                        end: AlignmentDirectional.bottomCenter,
                      ),
                    ),
                    child: _BackgroundDecoration(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<DocumentSnapshot<UserModel>>(
                                stream: steam,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    UserModel userModel =
                                        snapshot.data!.data()!;
                                    name = userModel.name ?? "";
                                    bio = userModel.bio ?? "";
                                    image = userModel.imageUrl;
                                    return GlowContainer(
                                      borderRadius: BorderRadius.circular(25),
                                      glowColor: Colors.lightBlueAccent,
                                      child: InactiveEmployeeCardSubTask(
                                        onTap: () {},
                                        bio: userModel.bio!,
                                        color: Colors.white,
                                        userImage: userModel.imageUrl,
                                        userName: userModel.userName!,
                                      ),
                                    );
                                  }

                                  if (!snapshot.hasData) {
                                    return image != null
                                        ? GlowContainer(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            glowColor: Colors.lightBlueAccent,
                                            child: InactiveEmployeeCardSubTask(
                                              onTap: () {},
                                              bio: bio,
                                              color: Colors.white,
                                              userImage: image!,
                                              userName: name,
                                            ),
                                          )
                                        : GlowContainer(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            glowColor: Colors.lightBlueAccent,
                                            child: InactiveEmployeeCardSubTask(
                                              onTap: () {},
                                              bio: bio,
                                              color: Colors.white,
                                              userImage: "",
                                              showicon: true,
                                              userName: name,
                                            ),
                                          );
                                  }
                                  return const CircularProgressIndicator
                                      .adaptive();
                                },
                              ),
                              AppSpaces.verticalSpace10,
                              SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildLabel(widget.task.name!),
                                    AppSpaces.horizontalSpace10,
                                    _buildStatus(widget.task.importance),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              buildLabel(
                                  "${AppConstants.description_key.tr}: ${widget.task.description ?? "no description"}"),
                              StreamBuilder(
                                stream: statusController
                                    .getStatusByIdStream(
                                        idk: widget.task.statusId)
                                    .asBroadcastStream(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot<StatusModel>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    print(snapshot.data);
                                    statusModel =
                                        snapshot.data!.data() as StatusModel;
                                    taskStatus = statusModel!.name!;
                                    return TaskWidget(
                                        status: getStatus(taskStatus));
                                  }
                                  return TaskWidget(
                                      status: getStatus(taskStatus));
                                },
                              ),
                              buildLabel(
                                  "${AppConstants.start_date_key.tr}:${formatDateTime(widget.task.startDate)}"),
                              buildLabel(
                                  "${AppConstants.end_date_key.tr}:${formatDateTime(widget.task.endDate!)}"),
                              const SizedBox(height: 10),

                              // Display the capsule buttons or 'NO WORK' text
                              _isLoading
                                  ? CircularProgressIndicator()
                                  : _downloadLinks.isEmpty
                                      ? const Text(
                                          'No Work Hass been Submitted',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'sans',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        )
                                      : Wrap(
                                          spacing: 8.0,
                                          runSpacing: 4.0,
                                          children: _downloadLinks
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            String link = entry.value;
                                            return GestureDetector(
                                              onTap: () => _launchURL(link),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Text(
                                                  'Attachment# ${index + 1}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'sans',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Opacity(
            opacity: getOpacity(widget.task.importance),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Material(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.primary, widget.primary.withOpacity(.7)],
                      begin: AlignmentDirectional.topCenter,
                      end: AlignmentDirectional.bottomCenter,
                    ),
                  ),
                  child: _BackgroundDecoration(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<DocumentSnapshot<UserModel>>(
                              stream: UserController()
                                  .getUserWhereMemberIsStream(
                                      memberId: widget.task.assignedTo)
                                  .asBroadcastStream(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container(
                                    height: 80,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryBackgroundColor,
                                        // border: Border.all(color: AppColors.primaryBackgroundColor, width: 4),
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    width: double.infinity,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (snapshot.hasData) {
                                  UserModel userModel = snapshot.data!.data()!;
                                  return GlowContainer(
                                    borderRadius: BorderRadius.circular(25),
                                    glowColor: Colors.lightBlueAccent,
                                    child: InactiveEmployeeCardSubTask(
                                      onTap: () {},
                                      bio: userModel.bio!,
                                      color: Colors.white,
                                      userImage: userModel.imageUrl,
                                      userName: userModel.userName!,
                                    ),
                                  );
                                }
                                return const CircularProgressIndicator
                                    .adaptive();
                              },
                            ),
                            AppSpaces.verticalSpace20,
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildLabel(widget.task.name!),
                                  _buildStatus(widget.task.importance),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildLabel(
                                "${AppConstants.description_key.tr}: ${widget.task.description}"),
                            StreamBuilder(
                              stream: statusController
                                  .getStatusByIdStream(
                                      idk: widget.task.statusId)
                                  .asBroadcastStream(),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot<StatusModel>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  print(snapshot.data);
                                  statusModel =
                                      snapshot.data!.data() as StatusModel;
                                  taskStatus = statusModel!.name!;
                                  return TaskWidget(
                                      status: getStatus(taskStatus));
                                }
                                return TaskWidget(
                                    status: getStatus(taskStatus));
                              },
                            ),
                            buildLabel(
                                "${AppConstants.start_date_key.tr}:${formatDateTime(widget.task.startDate)}"),
                            buildLabel(
                                "${AppConstants.end_date_key.tr}:${formatDateTime(widget.task.endDate!)}"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
  }

  double getOpacity(int importance) {
    double opacity = 1.0;

    switch (importance) {
      case 1:
        opacity = 1;
        break;
      case 2:
        opacity = 0.9;
        break;
      case 3:
        opacity = 0.8;
        break;
      case 4:
        opacity = 0.7;
        break;
      case 5:
        opacity = 0.6;
        break;
    }

    return opacity;
  }

  TaskStatus getStatus(String status) {
    switch (status) {
      case statusNotDone:
        return TaskStatus.notDone;
      case statusDoing:
        return TaskStatus.inProgress;
      case statusDone:
        return TaskStatus.done;
      case statusNotStarted:
        return TaskStatus.notStarted;
      default:
        return TaskStatus.notDone;
    }
  }

  Widget _buildStatus(int importance) {
    const maxOpacity = 0.9; // Maximum opacity for the task
    const minOpacity = 0.3; // Minimum opacity for the task
    const opacityStep =
        (maxOpacity - minOpacity) / 4; // Step size for opacity calculation

    return Row(
      children: List.generate(5, (index) {
        final isFilledStar = index < importance;
        final opacity = isFilledStar
            ? minOpacity + (importance - 1) * opacityStep
            : 1.0; // Set opacity to 1.0 for empty stars

        return GlowContainer(
          child: Icon(
            isFilledStar ? Icons.star_rate_rounded : Icons.star_border_rounded,
            color: Colors.yellow,
          ),
        );
      }),
    );
  }

  String formatDateTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    print(dateTime);
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "${AppConstants.today_key.tr} ${DateFormat('h:mma').format(dateTime)}";
    } else {
      return DateFormat('dd/MM/yy h:mma').format(dateTime);
    }
  }

  Widget buildLabel(String name) {
    return Text(
      name,
      style: AppTextStyles.header2_2,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Transform.translate(
            offset: const Offset(25, -25),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white10.withOpacity(.3),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Transform.translate(
            offset: const Offset(-70, 70),
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white10.withOpacity(0.3),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
