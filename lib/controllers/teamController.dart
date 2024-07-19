import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:unisoft/constants/app_constans.dart';
import 'package:unisoft/controllers/manger_controller.dart';
import 'package:unisoft/controllers/team_member_controller.dart';

import 'package:unisoft/controllers/topController.dart';
import 'package:unisoft/models/team/Manger_model.dart';
import 'package:unisoft/models/team/TeamMembers_model.dart';

import '../constants/back_constants.dart';
import '../models/team/Project_model.dart';
import '../models/team/Team_model.dart';
import '../models/tops/TopModel_model.dart';
import '../services/collectionsrefrences.dart';

class TeamController extends TopController {
  Future<void> addTeam(TeamModel teamModel) async {
    if (await existByOne(
        collectionReference: managersRef,
        field: idK,
        value: teamModel.managerId)) {
      await addDoc(reference: teamsRef, model: teamModel);
    } else {
      Exception exception =
          Exception(AppConstants.manager_not_found_error_key.tr);
      throw exception;
    }
  }

  Future<List<TeamModel>> getAllTeams() async {
    List<Object?>? list = await getAllListDataForRef(refrence: teamsRef);

    return list!.cast<TeamModel>();
  }

  Stream<QuerySnapshot<TeamModel>> getAllTeamsStream() {
    Stream<QuerySnapshot> stream =
        getAllListDataForRefStream(refrence: teamsRef);
    return stream.cast<QuerySnapshot<TeamModel>>();
  }

  Stream<DocumentSnapshot<TeamModel>> getTeamByIdStream<t extends TopModel>(
      {required String id}) {
    Stream<DocumentSnapshot> stream =
        getDocByIdStream(reference: teamsRef, id: id);
    return stream.cast<DocumentSnapshot<TeamModel>>();
  }

  Future<List<TeamModel>> getTeamsofMemberWhereUserId({required userId}) async {
    TeamMemberController teamMemberController = TeamMemberController();
    List<TeamMemberModel> listMembers =
        await teamMemberController.getMemberWhereUserIs(userId: userId);

    List<TeamModel> listOfTeams = <TeamModel>[];
    for (TeamMemberModel member in listMembers) {
      print(" 1 member ${member.id}");
      TeamModel team = await getTeamById(id: member.teamId);
      print("the team id  ${team.id}");
      listOfTeams.add(team);
    }
    return listOfTeams;
  }

  Stream<QuerySnapshot<TeamModel>> getTeamsofProjectsStream(
      {required List<ProjectModel> projects}) {
    List<String> teamsId = <String>[];
    for (var project in projects) {
      teamsId.add(project.teamId!);
    }
    return teamsRef
        .where(idK, whereIn: teamsId)
        .snapshots()
        .cast<QuerySnapshot<TeamModel>>();
  }

  Stream<QuerySnapshot<TeamModel>> getTeamsofMemberWhereUserIdStream(
      {required userId}) async* {
    TeamMemberController teamMemberController = TeamMemberController();
    List<TeamMemberModel> listMembers =
        await teamMemberController.getMemberWhereUserIs(userId: userId);
    if (listMembers.isEmpty) {
      throw Exception(AppConstants.not_member_in_any_team_error_key.tr);
    }
    List<String> teamsId = <String>[];
    for (TeamMemberModel member in listMembers) {
      teamsId.add(member.teamId);
    }
    Stream<QuerySnapshot<Object?>> teams =
        teamsRef.where(idK, whereIn: teamsId).snapshots();
    yield* teams.cast<QuerySnapshot<TeamModel>>();
  }

  Future<List<TeamModel>?> getTeamsOfUser({required String userId}) async {
    ManagerController controller = Get.put(ManagerController());
    ManagerModel? managerModel =
        await controller.getMangerWhereUserIs(userId: userId);
    if (managerModel != null) {
      return getTeamsOfManager(managerId: managerModel.id);
    }
    return null;
  }

  Stream<QuerySnapshot<TeamModel>?> getTeamsOfUserStream(
      {required String userId}) async* {
    ManagerController controller = Get.put(ManagerController());
    ManagerModel? managerModel =
        await controller.getMangerWhereUserIs(userId: userId);
    if (managerModel == null) {
      throw Exception("You dont have any team yet");
    }
    yield* getTeamsOfManagerStream(managerId: managerModel.id);
  }

  Future<List<TeamModel>> getTeamsOfManager({required String managerId}) async {
    List<Object?>? list = await getListDataWhere(
        collectionReference: teamsRef, field: managerIdK, value: managerId);
    return list!.cast<TeamModel>();
  }

  Stream<QuerySnapshot<TeamModel>> getTeamsOfManagerStream(
      {required String managerId}) {
    Stream<QuerySnapshot> stream = queryWhereStream(
        reference: teamsRef, field: managerIdK, value: managerId);
    return stream.cast<QuerySnapshot<TeamModel>>();
  }

  Future<TeamModel> getTeamById({required String id}) async {
    DocumentSnapshot? documentSnapshot = await getDocSnapShotWhere(
        collectionReference: teamsRef, field: idK, value: id);
    print("Team controller  ${documentSnapshot!.id}");
    return documentSnapshot.data() as TeamModel;
  }

  Future<TeamModel> getTeamByName(
      {required String name, required String managerId}) async {
    DocumentSnapshot? doc = await getDocSnapShotByNameInTow(
        reference: teamsRef, field: managerIdK, value: managerId, name: name);
    return doc.data() as TeamModel;
  }

  Stream<DocumentSnapshot<TeamModel>> getTeamByNameNameStream(
      {required String name, required String managerId}) async* {
    Stream<DocumentSnapshot> stream = getDocByNameInTowStream(
        reference: teamsRef, field: managerIdK, value: managerId, name: name);
    yield* stream.cast<DocumentSnapshot<TeamModel>>();
  }

  Future<TeamModel> getTeamOfProject({required ProjectModel project}) async {
    DocumentSnapshot? doc = await getDocSnapShotWhere(
        collectionReference: teamsRef, field: idK, value: project.teamId);
    return doc!.data() as TeamModel;
  }

  Stream<DocumentSnapshot<TeamModel>> getTeamOfProjectStream(
      {required ProjectModel project}) {
    Stream<DocumentSnapshot> stream = getDocWhereStream(
        collectionReference: teamsRef, field: idK, value: project.teamId);
    return stream.cast<DocumentSnapshot<TeamModel>>();
  }

  Future<void> updateTeam(String id, Map<String, dynamic> data) async {
    if (data.containsKey(managerIdK)) {
      Exception exception =
          Exception(AppConstants.manager_id_update_error_key.tr);
      throw exception;
    }
    ManagerController managerController = Get.put(ManagerController());
    ManagerModel managerModel =
        await managerController.getMangerOfTeam(teamId: id);
    await updateRelationalFields(
        reference: teamsRef,
        data: data,
        id: id,
        fatherField: managerIdK,
        fatherValue: managerModel.id,
        nameException: Exception(""));
  }

  deleteTeam({required String id, required List<String> projectIds}) async {
    WriteBatch batch = fireStore.batch();
    DocumentSnapshot team = await getDocById(reference: teamsRef, id: id);
    deleteDocUsingBatch(documentSnapshot: team, refbatch: batch);
    for (var projectId in projectIds) {
      // Retrieve the project document snapshot
      DocumentSnapshot? project =
          await getDocById(reference: projectsRef, id: projectId);

      // Delete the project document
      deleteDocUsingBatch(documentSnapshot: project, refbatch: batch);

      // Retrieve all members of the current project
      List<DocumentSnapshot> projectMembers = await getDocsSnapShotWhere(
        collectionReference: teamMembersRef,
        field: projectIdK,
        value: projectId,
      );

      // Delete the members associated with the current project
      deleteDocsUsingBatch(list: projectMembers, refBatch: batch);

      // Retrieve all main tasks of the current project
      List<DocumentSnapshot> mainTasks = await getDocsSnapShotWhere(
        collectionReference: projectMainTasksRef,
        field: projectIdK,
        value: projectId,
      );

      // Delete the main tasks of the current project
      deleteDocsUsingBatch(list: mainTasks, refBatch: batch);

      // Retrieve all subtasks of the current project's members
      List<DocumentSnapshot> subTasks = [];
      for (var member in projectMembers) {
        List<DocumentSnapshot> memberSubTasks = await getDocsSnapShotWhere(
          collectionReference: projectSubTasksRef,
          field: assignedToK,
          value: member.id,
        );
        subTasks.addAll(memberSubTasks);
      }

      // Delete the subtasks of the current project's members
      deleteDocsUsingBatch(list: subTasks, refBatch: batch);
    }
    batch.commit();
  }
}
