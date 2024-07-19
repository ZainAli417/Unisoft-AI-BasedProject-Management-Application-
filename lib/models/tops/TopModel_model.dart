mixin TopModel {
  late String id;
  set setId(String id);

  //get getId => id;
  late DateTime createdAt;
  set setCreatedAt(DateTime createdAt);
  //DateTime get getCreatedAt => createdAt;
  late DateTime updatedAt;
  set setUpdatedAt(DateTime updatedAt);
  // DateTime get getUpdatedAt => updatedAt;
  Map<String, dynamic> toFirestore();
}
