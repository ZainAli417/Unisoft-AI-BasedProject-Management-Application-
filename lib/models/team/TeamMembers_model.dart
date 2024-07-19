import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:unisoft/constants/app_constans.dart';

import '../../constants/back_constants.dart';
import '../../utils/back_utils.dart';
import '../tops/TopModel_model.dart';

class TeamMemberModel with TopModel {
  TeamMemberModel({
    //primary kay
    required String idParameter,
    //foriegn kay from UserModel
    required String userIdParameter,
    required String teamIdParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
  }) {
    setUserId = userIdParameter;
    setTeamId = teamIdParameter;
    setId = idParameter;
    setCreatedAt = createdAtParameter;
    setUpdatedAt = updatedAtParameter;
  }
  TeamMemberModel.firestoreConstructor({
    //primary kay
    required String idParameter,
    //foriegn kay from UserModel
    required String userIdParameter,
    required String teamIdParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
  }) {
    userId = userIdParameter;
    teamId = teamIdParameter;
    id = idParameter;
    createdAt = createdAtParameter;
    updatedAt = updatedAtParameter;
  }
  //forgin kay from UserModel
  late String userId;
  //forgin kay from TeamModel
  late String teamId;

  set setTeamId(String teamId) {
    this.teamId = teamId;
  }

  set setUserId(String userId) {
    this.userId = userId;
  }

  @override
  set setId(String idParameter) {
    Exception exception;
    if (idParameter.isEmpty) {
      exception = Exception(AppConstants.team_member_id_empty_error_key.tr);
      throw exception;
    }
    id = idParameter;
  }

  @override
  set setCreatedAt(DateTime createdAtParameter) {
    Exception exception;
    createdAtParameter = firebaseTime(createdAtParameter);
    DateTime now = firebaseTime(DateTime.now());
    createdAtParameter = firebaseTime(createdAtParameter);
    if (createdAtParameter.isAfter(now)) {
      exception =
          Exception(AppConstants.team_member_creating_time_future_error_key.tr);
      throw exception;
    }
    if (firebaseTime(createdAtParameter).isBefore(now)) {
      exception = Exception(AppConstants.team_member_creating_time_past_error_key.tr);
      throw exception;
    }
    createdAt = createdAtParameter;
  }

  @override
  set setUpdatedAt(DateTime updatedAtParameter) {
    Exception exception;
    updatedAtParameter = firebaseTime(updatedAtParameter);
    if (updatedAtParameter.isBefore(createdAt)) {
      exception =
          Exception(AppConstants.team_member_updating_time_before_create_error_key.tr);
      throw exception;
    }
    updatedAt = updatedAtParameter;
  }

  factory TeamMemberModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    return TeamMemberModel.firestoreConstructor(
      idParameter: data[idK],
      userIdParameter: data[userIdK],
      teamIdParameter: data[teamIdK],
      createdAtParameter: data[createdAtK].toDate(),
      updatedAtParameter: data[updatedAtK].toDate(),
    );
  }
  @override
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[idK] = id;
    data[userIdK] = userId;
    data[teamIdK] = teamId;
    data[createdAtK] = createdAt;
    data[updatedAtK] = updatedAt;
    return data;
  }
}
