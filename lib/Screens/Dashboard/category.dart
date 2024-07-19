import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisoft/Screens/Dashboard/search_bar_animation.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/user_task_controller.dart';

import '../../Values/values.dart';
import '../../controllers/categoryController.dart';
import '../../models/task/UserTaskCategory_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/Navigation/app_header.dart';
import '../../widgets/User/categoryCardVertical.dart';

enum CategorySortOption {
  name,
  createDate,
  updatedDate,
  // Add more sorting options if needed
}

class CategoryScreen extends StatefulWidget {
   const CategoryScreen({Key? key}) : super(key: key);
  static String id = "/NotificationScreen";

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TaskCategoryController taskCategoryController =
      Get.put(TaskCategoryController());
  TextEditingController editingController = TextEditingController();
  UserTaskController taskController = Get.put(UserTaskController());
  String search = "";
  CategorySortOption selectedSortOption = CategorySortOption.name;
  int crossAxisCount = 2; // Variable for crossAxisCount

  String _getSortOptionText(CategorySortOption option) {
    switch (option) {
      case CategorySortOption.name:
        return AppConstants.name_key.tr;
      case CategorySortOption.updatedDate:
        return AppConstants.updated_Date_key.tr;
      case CategorySortOption.createDate:
        return AppConstants.created_date_key.tr;
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          child: TaskezAppHeader(
            title: AppConstants.categories_key.tr,
            widget: MySearchBarWidget(
              searchWord: AppConstants.categories_key.tr,
              editingController: editingController,
              onChanged: (String value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.only(
                right: 10,
                left:
10,
              ),
              padding: const EdgeInsets.only(
                right:10, // Adjust the 0percentage as needed
                left:
                   10, // Adjust the percentage as needed
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<CategorySortOption>(
                value: selectedSortOption,
                onChanged: (CategorySortOption? newValue) {
                  setState(() {
                    selectedSortOption = newValue!;
                    // Implement the sorting logic here
                  });
                },
                items:
                    CategorySortOption.values.map((CategorySortOption option) {
                  return DropdownMenuItem<CategorySortOption>(
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
                  size: 30, // Adjust the percentage as needed
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
                  size: 25, // Adjust the percentage as needed
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                onPressed: toggleSortOrder, // Toggle the sort order
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.grid_view,
                color: Colors.white,
              ),
              onPressed:
                  toggleCrossAxisCount, // Toggle the crossAxisCount value
            ),
          ],
        ),
        const SizedBox(height:20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: taskCategoryController.getUserCategoriesStream(
                userId: AuthService.instance.firebaseAuth.currentUser!.uid,
              ),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<UserTaskCategoryModel>>
                      snapshot) {
                if (snapshot.hasData) {
                  int taskCount = snapshot.data!.docs.length;
                  List<UserTaskCategoryModel> list = [];

                  if (taskCount > 0) {
                    if (search.isNotEmpty) {
                      print("${search}helli");
                      for (var element in snapshot.data!.docs) {
                        UserTaskCategoryModel taskModel = element.data();
                        if (taskModel.name!.toLowerCase().contains(search)) {
                          list.add(taskModel);
                        }
                      }
                    } else {
                      for (var element in snapshot.data!.docs) {
                        UserTaskCategoryModel taskCategoryModel =
                            element.data();

                        list.add(taskCategoryModel);
                      }
                    }
                    switch (selectedSortOption) {
                      case CategorySortOption.name:
                        list.sort((a, b) => a.name!.compareTo(b.name!));
                        break;
                      case CategorySortOption.createDate:
                        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                        break;
                      case CategorySortOption.updatedDate:
                        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                      // Add cases for more sorting options if needed
                    }
                    if (!sortAscending) {
                      list = list.reversed
                          .toList(); // Reverse the list for descending order
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            crossAxisCount, // Use the variable for crossAxisCount
                        mainAxisSpacing: 10,
                        mainAxisExtent: 220,
                        crossAxisSpacing: 10,
                      ),
                      itemBuilder: (_, index) {
                        return CategoryCardVertical(
                          userTaskCategoryModel: list[index],
                        );
                      },
                      itemCount: list.length,
                    );
                  }
                }
                if (!snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //
                      const Icon(
                        Icons.search_off,
                        //   Icons.heart_broken_outlined,
                        color: Colors.lightBlue,
                        size: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Adjust the percentage as needed
                          vertical:10,
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.loading_key.tr,
                            style: GoogleFonts.laila(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
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
                    Icon(
                      Icons.category_rounded,
                      //   Icons.heart_broken_outlined,
                      color: HexColor.fromHex("#999999"),
                      size: 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, // Adjust the percentage as needed
                        vertical: 10,
                      ),
                      child: Text(
                        AppConstants.no_categories_found_key.tr,
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize:20,
                          fontWeight: FontWeight.bold
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
    );
  }
}
