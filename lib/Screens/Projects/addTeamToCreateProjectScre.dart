import 'package:get/get.dart';
import 'package:unisoft/models/team/Team_model.dart';

class AddTeamToCreatProjectScreen extends GetxController {
  RxList<TeamModel> teams = <TeamModel>[].obs;

  void addUser(TeamModel user) {
    print("add team ");
    bool found = false;

    if (teams.isEmpty) {
      teams.add(user);
    } else {
      teams.first = user;
    }
    update();
    teams;
  }

  void removeUsers() {
    teams.clear();
    update();
  }

  @override
  void onClose() {
    removeUsers();
    super.onClose();
  }
}
