import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/Dashboard/search_bar_animation.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/constants/back_constants.dart';
import 'package:unisoft/controllers/topController.dart';
import 'package:unisoft/models/team/Project_main_task_Model.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/services/collectionsrefrences.dart';
import '../../BottomSheets/bottom_sheets.dart';
import '../../Values/values.dart';
import '../../controllers/manger_controller.dart';
import '../../controllers/projectController.dart';
import '../../controllers/project_main_task_controller.dart';
import '../../controllers/statusController.dart';
import '../../controllers/userController.dart';
import '../../models/User/User_model.dart';
import '../../models/statusmodel.dart';
import '../../models/team/Manger_model.dart';
import '../../models/team/Project_model.dart';

import '../../widgets/Navigation/app_header.dart';
import '../Snackbar/custom_snackber.dart';
import 'create_user_task.dart';
import 'dashboard_add_icon.dart';
import 'main_task.dart';

enum TaskSortOption {
  name,
  createDate,
  updatedDate,
  startDate,
  endDate,
  importance
  // Add more sorting options if needed
}

class MainTaskScreen extends StatefulWidget {
  MainTaskScreen({Key? key, required this.projectId}) : super(key: key);
  // ProjectModel projectModel;
  String projectId;
  @override
  State<MainTaskScreen> createState() => _MainTaskScreenState();
}

class _MainTaskScreenState extends State<MainTaskScreen> {
  TextEditingController editingController = TextEditingController();
  String search = "";
  TaskSortOption selectedSortOption = TaskSortOption.name;
  int crossAxisCount = 1; // Variable for crossAxisCount

  String _getSortOptionText(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.name:
        return AppConstants.name_key.tr;
      case TaskSortOption.updatedDate:
        return AppConstants.updated_Date_key.tr;
      case TaskSortOption.createDate:
        return AppConstants.created_date_key.tr;
      case TaskSortOption.startDate:
        return AppConstants.start_date_key.tr;
      case TaskSortOption.endDate:
        return AppConstants.end_date_key.tr;
      case TaskSortOption.importance:
        return AppConstants.importance_key.tr;
    // Add cases for more sorting options if needed
      default:
        return '';
    }
  }

  bool sortAscending = true; // Variable for sort order
  void toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending; // Toggle the sort order
    });
  }

  void toggleCrossAxisCount() {
    setState(() {
      crossAxisCount =
          crossAxisCount == 2 ? 1 : 2; // Toggle the crossAxisCount value
    });
  }

  @override
  void initState() {
    ismanagerStream();
    super.initState();
  }

  ismanagerStream() async {
    print("1234");
    ProjectModel? projectModel =
        await ProjectController().getProjectById(id: widget.projectId);
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
          updatedIsManager = false;
          print("${user.id}/////${AuthService.instance.firebaseAuth.currentUser!.uid}");
        } else {
          updatedIsManager = true;
        }
        print(updatedIsManager);
        isManager.value = updatedIsManager;
      });
    });
  }

  // bool isManager = false;
  RxBool isManager = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(
        () => Visibility(
          visible: isManager.value,
          child: DashboardAddButton(
            iconTapped: (() {
              _createTask2();
            }),
          ),
        ),
      ),
      backgroundColor: HexColor.fromHex("#181a1f"),
      body: Column(
        children: [
          SafeArea(
            child: TaskezAppHeader(
              title: AppConstants.main_tasks_key.tr,
              widget: MySearchBarWidget(
                searchWord: AppConstants.main_tasks_key.tr,
                editingController: editingController,
                onChanged: (String value) {
                  setState(() {
                    search = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(
            height:10,
          ),
          StreamBuilder<DocumentSnapshot<ProjectModel>>(
            stream:
                ProjectController().getProjectByIdStream(id: widget.projectId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ProjectModel projectModel = snapshot.data!.data()!;
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Utils.screenWidth * 0.04),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(projectModel.name!,
                            style: AppTextStyles.header2_2),
                        Text(projectModel.description!,
                            style: AppTextStyles.header2_2),
                      ],
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {}
              return const CircularProgressIndicator();
            },
          ),
          SizedBox(
            height: Utils.screenHeight * 0.04,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 10, // Adjust the percentage as needed
                  left: 10, // Adjust the percentage as needed
                ),
                padding: const EdgeInsets.only(
                  right: 10, // Adjust the 0percentage as needed
                  left: 10, // Adjust the percentage as needed
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<TaskSortOption>(
                  value: selectedSortOption,
                  onChanged: (TaskSortOption? newValue) {
                    setState(() {
                      selectedSortOption = newValue!;
                      // Implement the sorting logic here
                    });
                  },
                  items: TaskSortOption.values.map((TaskSortOption option) {
                    return DropdownMenuItem<TaskSortOption>(
                      value: option,
                      child: Text(
                        _getSortOptionText(option),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),

                  // Add extra styling
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 30,
                  ),
                  underline: const SizedBox(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    width: 2,
                    color: HexColor.fromHex("616575"),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    size: 25,
                    sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                  onPressed: toggleSortOrder, // Toggle the sort order
                ),
              ),
              IconButton(
                icon: const Icon(
                  size: 25,
                  Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed:
                    toggleCrossAxisCount, // Toggle the crossAxisCount value
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                stream: ProjectMainTaskController()
                    .getProjectMainTasksStream(projectId: widget.projectId),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<ProjectMainTaskModel>>
                        snapshot) {
                  if (snapshot.hasData) {
                    int taskCount = snapshot.data!.docs.length;
                    List<ProjectMainTaskModel> list = [];
                    if (taskCount > 0) {
                      if (search.isNotEmpty) {
                        for (var element in snapshot.data!.docs) {
                          ProjectMainTaskModel taskCategoryModel =
                              element.data();
                          if (taskCategoryModel.name!
                              .toLowerCase()
                              .contains(search)) {
                            list.add(taskCategoryModel);
                          }
                        }
                      } else {
                        for (var element in snapshot.data!.docs) {
                          ProjectMainTaskModel taskCategoryModel =
                              element.data();
                          list.add(taskCategoryModel);
                        }
                      }
                      switch (selectedSortOption) {
                        case TaskSortOption.name:
                          list.sort((a, b) => a.name!.compareTo(b.name!));
                          break;
                        case TaskSortOption.createDate:
                          list.sort(
                              (a, b) => a.createdAt.compareTo(b.createdAt));
                          break;
                        case TaskSortOption.updatedDate:
                          list.sort(
                              (a, b) => b.updatedAt.compareTo(a.updatedAt));
                        case TaskSortOption.endDate:
                          list.sort((a, b) => b.endDate!.compareTo(a.endDate!));
                        case TaskSortOption.startDate:
                          list.sort(
                              (a, b) => b.startDate.compareTo(a.startDate));
                        case TaskSortOption.importance:
                          list.sort(
                              (a, b) => b.importance.compareTo(a.importance));
                          break;
                        // Add cases for more sorting options if needed
                      }
                      if (!sortAscending) {
                        list = list.reversed
                            .toList(); // Reverse the list for descending order
                      }
                      return SizedBox(
                        width: 500, // Set your custom width here
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 240,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (_, index) {
                            return MainTaskProgressCard(
                              taskModel: list[index],
                            );
                          },
                          itemCount: list.length,
                        ),
                      );

                    }
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.lightMauveBackgroundColor,
                        backgroundColor: AppColors.primaryBackgroundColor,
                      ),
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //
                      const Icon(
                        Icons.search_off,
                        //   Icons.heart_broken_outlined,
                        color: Colors.red,
                        size: 90,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: Center(
                          child: Text(
                            AppConstants.no_main_tasks_found_key.tr,
                            style: GoogleFonts.laila(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createTask2() {
    showAppBottomSheet(CreateUserTask(
      addLateTask: (
          {required int priority,
          required String taskName,
          required DateTime startDate,
          required DateTime dueDate,
          required String? desc,
          required String color}) async {},
      isUserTask: false,
      addTask: (
          {required color,
          required desc,
          required dueDate,
          required priority,
          required startDate,
          required taskName}) async {
        if (startDate.isAfter(dueDate) || startDate.isAtSameMomentAs(dueDate)) {
          CustomSnackBar.showError(
              AppConstants.start_date_cannot_be_after_end_date_key.tr);
          return;
        }

        try {
          StatusController statusController = Get.put(StatusController());
          StatusModel statusModel =
              await statusController.getStatusByName(status: statusNotStarted);

          ProjectMainTaskModel userTaskModel = ProjectMainTaskModel(
              hexColorParameter: color,
              projectIdParameter: widget.projectId,
              descriptionParameter: desc!,
              idParameter: projectMainTasksRef.doc().id,
              nameParameter: taskName,
              statusIdParameter: statusModel.id,
              importanceParameter: priority,
              createdAtParameter: DateTime.now(),
              updatedAtParameter: DateTime.now(),
              startDateParameter: startDate,
              endDateParameter: dueDate);
          await ProjectMainTaskController()
              .addProjectMainTask(projectMainTaskModel: userTaskModel);
        } catch (e) {
          CustomSnackBar.showError(e.toString());
        }
      },
      checkExist: ({required String name}) async {
        return TopController().existByTow(
            reference: projectMainTasksRef,
            value: projectIdK,
            field: widget.projectId,
            value2: name,
            field2: nameK);
      },
      isEditMode: false,
    ));
  }
}
