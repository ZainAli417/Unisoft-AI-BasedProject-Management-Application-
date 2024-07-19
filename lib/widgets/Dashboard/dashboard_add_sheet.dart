import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unisoft/Screens/Projects/createProject.dart';
import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/manger_controller.dart';
import 'package:unisoft/models/team/Manger_model.dart';
import 'package:unisoft/services/auth_service.dart';
import 'package:unisoft/widgets/Snackbar/custom_snackber.dart';

import '../../BottomSheets/bottom_sheets.dart';
import '../../Values/values.dart';
import '../BottomSheets/bottom_sheet_holder.dart';
import '../Onboarding/labelled_option.dart';
import 'create_category.dart';

import 'dashboard_meeting_details.dart';

class DashboardAddBottomSheet extends StatelessWidget {
  const DashboardAddBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        AppSpaces.verticalSpace10,
        const BottomSheetHolder(),
        AppSpaces.verticalSpace10,
        //TODO add this in the category and in the project
        // LabelledOption(
        //   label: 'Create Task',
        //   icon: Icons.add_to_queue,
        //   callback: _createTask2,
        // ),

        LabelledOption(
            label: AppConstants.create_project_key.tr,
            icon: Icons.device_hub,
            callback: () async {
              await _createProject();
            }),
        LabelledOption(
            label: AppConstants.create_team_key.tr,
            icon: Icons.people,
            callback: () {
              Get.to(() => const DashboardMeetingDetails());
            }),
        LabelledOption(
            label: AppConstants.create_category_key.tr,
            icon: Icons.category,
            callback: () {
              showAppBottomSheet(
                 const CreateUserCategory(),
                isScrollControlled: true,
                popAndShow: true,
              );
            }),
      ]),
    );
  }


  Future<void> _createProject() async {
    try {
      ManagerModel? managerModel = await ManagerController()
          .getMangerWhereUserIs(
              userId: AuthService.instance.firebaseAuth.currentUser!.uid);
      if (managerModel == null) {
        print("object");
      }
      showAppBottomSheet(
        CreateProject(
          managerModel: managerModel,
          //   userTaskCategoryModel: widget.categoryModel,
          isEditMode: false,
        ),
        isScrollControlled: true,
        popAndShow: true,
      );
    } on Exception catch (e) {
      CustomSnackBar.showError(e.toString());
    }
  }
}
