import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:unisoft/constants/app_constans.dart';

import '../../constants/back_constants.dart';
import '../../utils/back_utils.dart';
import '../team/Task_model.dart';

class UserTaskModel extends TaskClass {
  UserTaskModel({
    //foriegn key
    required String userIdParameter,
    //foriegn key
    required String folderIdParameter,
    //foriegn key
    required DocumentReference? taskFatherIdParameter,
    required String descriptionParameter,
    //primary key
    required String idParameter,
    required String nameParameter,
    //foriegn key
    required String statusIdParameter,
    required int importanceParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
    required DateTime startDateParameter,
    required DateTime endDateParameter,
    required String hexColorParameter,
  }) {
    setFolderId = folderIdParameter;
    setId = idParameter;
    setName = nameParameter;
    setDescription = descriptionParameter;
    setStatusId = statusIdParameter;
    setimportance = importanceParameter;
    setCreatedAt = createdAtParameter;
    setUpdatedAt = updatedAtParameter;
    setStartDate = startDateParameter;
    setEndDate = endDateParameter;
    setUserId = userIdParameter;
    setTaskFatherId = taskFatherIdParameter;
    setHexColor = hexColorParameter;
  }
  UserTaskModel.lateTask({
    required String userIdParameter,
    required String folderIdParameter,
    required DocumentReference? taskFatherIdParameter,
    required String descriptionParameter,
    required String idParameter,
    required String nameParameter,
    required String statusIdParameter,
    required int importanceParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
    required DateTime startDateParameter,
    required DateTime endDateParameter,
    required String color,
  }) {
    setHexColor = color;
    setFolderId = folderIdParameter;
    setId = idParameter;
    setName = nameParameter;
    setDescription = descriptionParameter;
    setStatusId = statusIdParameter;
    setimportance = importanceParameter;
    setCreatedAt = createdAtParameter;
    setUpdatedAt = updatedAtParameter;
    startDate = startDateParameter;
    setEndDate = endDateParameter;
    setUserId = userIdParameter;
    setTaskFatherId = taskFatherIdParameter;
  }
  UserTaskModel.firestoreConstructor({
    //foriegn key
    required this.userId,
    //foriegn key
    required this.folderId,
    //foriegn key
    this.taskFatherId,
    String? descriptionParameter,
    //primary key
    required String idParameter,
    required String nameParameter,
    //foriegn key
    required String statusIdParameter,
    required int importanceParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
    required DateTime startDateParameter,
    required DateTime endDateParameter,
    required String colorParameter,
  }) {
    hexcolor = colorParameter;
    id = idParameter;
    name = nameParameter;
    description = descriptionParameter;
    statusId = statusIdParameter;
    importance = importanceParameter;
    createdAt = createdAtParameter;
    updatedAt = updatedAtParameter;
    startDate = startDateParameter;
    endDate = endDateParameter;
  }

  late String userId;

  late String folderId;

  DocumentReference? taskFatherId;

  set setUserId(String userIdParameter) {
    Exception exception;
    if (userIdParameter.isEmpty) {
      exception = Exception(AppConstants.task_user_id_empty_error_key);
      throw exception;
    }

    userId = userIdParameter;
  }

  set setFolderId(String folderIdParameter) {
    Exception exception;
    if (folderIdParameter.isEmpty) {
      exception = Exception(AppConstants.user_task_category_id_empty_error_key);
      throw exception;
    }

    folderId = folderIdParameter;
  }

  set setTaskFatherId(DocumentReference? taskFatherIdParameter) {
    taskFatherId = taskFatherIdParameter;
  }
  // TODO:this method is just for demo make the method to make a query in firebase to know that if the task name already been stored in the firebase for this project for this model

  @override
  set setName(String? nameParameter) {
    Exception exception;
    if (nameParameter == null) {
      exception = Exception(AppConstants.user_task_name_null_error_key);
      throw exception;
    }
    if (nameParameter.isEmpty) {
      exception = Exception(AppConstants.user_task_name_empty_error_key.tr);
      throw exception;
    }
    // () async {
    //   if (await exist(
    //           reference: usersTasksRef,
    //           field: "userId",
    //           value: firebaseAuth.currentUser!.uid,
    //           field2: "name",
    //           value2: nameParameter) >
    //       1) {
    //     exception = Exception("task already been added");
    //     throw exception;
    //   }
    // }();

    name = nameParameter;
  }

  @override
  set setDescription(String? descriptionParameter) {
    description = descriptionParameter;
  }

  @override
  set setId(String idParameter) {
    Exception exception;
    if (idParameter.isEmpty) {
      exception = Exception(AppConstants.user_task_id_empty_error_key.tr);
      throw exception;
    }
    id = idParameter;
  }

  @override
  set setStatusId(String statusIdParameter) {
    Exception exception;
    if (statusIdParameter.isEmpty) {
      exception = Exception(AppConstants.task_status_id_empty_error_key.tr);
      throw exception;
    }
    statusId = statusIdParameter;
  }

  @override
  set setimportance(int importanceParameter) {
    Exception exception;
    if (importanceParameter <= 0) {
      exception = Exception(AppConstants.importance_less_than_zero_error_key.tr);
      throw exception;
    }
    if (importanceParameter > 5) {
      exception = Exception(AppConstants.importance_greater_than_five_error_key.tr);
      throw exception;
    }
    importance = importanceParameter;
  }

  @override
  set setHexColor(String hexcolorParameter) {
    Exception exception;
    if (hexcolorParameter.isEmpty) {
      exception = Exception(AppConstants.task_color_empty_error_key.tr);
      throw exception;
    }
    hexcolor = hexcolorParameter;
  }

  @override
  set setCreatedAt(DateTime createdAtParameter) {
    Exception exception;
    createdAtParameter = firebaseTime(createdAtParameter);
    DateTime now = firebaseTime(DateTime.now());

    if (createdAtParameter.isAfter(now)) {
      exception = Exception(AppConstants.user_task_create_future_error_key.tr);
      throw exception;
    }
    if (firebaseTime(createdAtParameter).isBefore(now)) {
      exception = Exception(AppConstants.user_task_create_past_error_key.tr);
      throw exception;
    }
    createdAt = firebaseTime(createdAtParameter);
  }

  @override
  set setUpdatedAt(DateTime updatedAtParameter) {
    Exception exception;

    updatedAtParameter = firebaseTime(updatedAtParameter);
    if (updatedAtParameter.isBefore(createdAt)) {
      exception =
          Exception(AppConstants.task_update_before_create_error_key.tr);
      throw exception;
    }
    updatedAt = firebaseTime(updatedAtParameter);
  }

  @override
  set setStartDate(DateTime? startDateParameter) {
    Exception exception;

    if (startDateParameter == null) {
      exception = Exception(AppConstants.user_task_start_date_null_error_key.tr);
      throw exception;
    }
    startDateParameter = firebaseTime(startDateParameter);
    DateTime now = firebaseTime(DateTime.now());
    if (startDateParameter.isBefore(now)) {
      exception =
          Exception(AppConstants.user_task_start_date_past_error_key.tr);
      throw exception;
    }
    //TODO check this line
    // if (dateduplicated(startDateParameter)) {
    //   exception = Exception("start date can't be after end date");
    //   throw exception;
    // }

    startDate = firebaseTime(startDateParameter);
  }

  @override
  set setEndDate(DateTime? endDateParameter) {
    Exception exception;
    if (endDateParameter == null) {
      exception = Exception(AppConstants.user_task_end_date_null_error_key.tr);
      throw exception;
    }
    endDateParameter = firebaseTime(endDateParameter);
    if (endDateParameter.isAtSameMomentAs(startDate)) {
      exception = Exception(
        AppConstants.user_task_start_end_date_same_time_error_key.tr,
      );
    }
    if (differeInTime(getStartDate, endDateParameter).inMinutes < 5) {
      exception = Exception(
      AppConstants.task_time_difference_error_key.tr);
      throw exception;
    }
    if (endDateParameter.isBefore(startDate)) {
      exception = Exception(AppConstants.user_task_end_date_error_key.tr);
      throw exception;
    }
    endDate = firebaseTime(endDateParameter);
  }

  factory UserTaskModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic>? data = snapshot.data()!;
    return UserTaskModel.firestoreConstructor(
      colorParameter: data[colorK],
      nameParameter: data[nameK],
      idParameter: data[idK],
      descriptionParameter: data[descriptionK],
      userId: data[userIdK],
      folderId: data[folderIdK],
      taskFatherId: data[taskFatherIdK],
      statusIdParameter: data[statusIdK],
      importanceParameter: data[importanceK],
      createdAtParameter: data[createdAtK].toDate(),
      updatedAtParameter: data[updatedAtK].toDate(),
      startDateParameter: data[startDateK].toDate(),
      endDateParameter: data[endDateK].toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return {
      colorK: hexcolor,
      nameK: name,
      idK: id,
      descriptionK: description,
      userIdK: userId,
      folderIdK: folderId,
      taskFatherIdK: taskFatherId,
      statusIdK: statusId,
      importanceK: importance,
      createdAtK: createdAt,
      updatedAtK: updatedAt,
      startDateK: startDate,
      endDateK: endDate,
    };
  }

  @override
  String toString() {
    return "user task name is $name id:$id description:$description userId:$userId folderId$folderId \n task_father_id:$taskFatherId statusId:$statusId importance:$importance createdAt:$createdAt updatedAt:$updatedAt startDate:$startDate endDate:$endDate";
  }
}
