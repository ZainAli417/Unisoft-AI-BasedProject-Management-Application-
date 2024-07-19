
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:unisoft/constants/app_constans.dart';

import '../../constants/back_constants.dart';
import '../../utils/back_utils.dart';
import '../../services/auth_service.dart';
import '../tops/VarTopModel.dart';

class UserModel extends VarTopModel {
  late String imageUrl;
  late String? userName;
  late String? bio;
  late String? email;

  late List<String> tokenFcm = [];

  UserModel({
    required String nameParameter,
    String? userNameParameter,
    required String imageUrlParameter,
    String? emailParameter,
    this.bio,

    //primary kay
    required String idParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
  }) {
    setEmail = emailParameter;
    setUserName = userNameParameter;
    setImageUrl = imageUrlParameter;
    setName = nameParameter;
    setId = idParameter;
    setCreatedAt = createdAtParameter;
    setUpdatedAt = updatedAtParameter;
  }

  UserModel.firestoreConstructor({
    required String nameParameter,
    String? userNameParameter,
    required String imageUrlParameter,
    String? emailParameter,
    String? bioParameter,
    required this.tokenFcm,
    //primary kay
    required String idParameter,
    required DateTime createdAtParameter,
    required DateTime updatedAtParameter,
  }) {
    bio = bioParameter;
    email = emailParameter;
    userName = userNameParameter;
    imageUrl = imageUrlParameter;
    name = nameParameter;
    id = idParameter;
    updatedAt = updatedAtParameter;
    createdAt = createdAtParameter;
    tokenFcm = tokenFcm;
  }
  RegExp regEx = RegExp(r"(?=.*[0-9])\w+");
  RegExp regEx2 = RegExp(r'[^\w\d\u0600-\u06FF\s]');
  @override
  set setName(String name) {
    Exception exception;


    if (name.isEmpty) {
      exception = Exception(AppConstants.name_not_empty_key.tr);
      throw exception;
    }
    if (name.length <= 3) {
      exception = Exception(AppConstants.name_min_length_key.tr);
      throw exception;
    }
    if (regEx.hasMatch(name) || regEx2.hasMatch(name)) {
      exception = Exception(AppConstants.name_letters_only_key.tr);
      throw exception;
    }

    this.name = name;
  }

  set setUserName(String? userName) {
    Exception exception;
    if (userName == null) {
      this.userName = userName;
      return;
    }
    if (userName.isEmpty) {
      exception = Exception(AppConstants.username_not_empty_key.tr);
      throw exception;
    }
    if (userName.length < 3) {
      exception = Exception(AppConstants.username_min_length_key.tr);
      throw exception;
    }
    if (userName.length >= 20) {
      exception = Exception(AppConstants.username_max_length_key.tr);
      throw exception;
    }
    this.userName = userName;
  }

  set setImageUrl(String imageUrl) {
    Exception exception;
    if (imageUrl.isEmpty) {
      exception = Exception(AppConstants.user_imageUrl_empty_key.tr);
      throw exception;
    }
    this.imageUrl = imageUrl;
  }

  set setEmail(String? email) {
    if (email != null) {
      if (!EmailValidator.validate(email)) {
        throw Exception(AppConstants.valid_email_error_key.tr);
      }
      this.email = email;
    } else {
      this.email = email;
    }
  }

  set setBio(String? bio) {
    this.bio = bio;
  }


  Future<void> addTokenFcm() async {
    String tokenFcm = await getFcmToken();
    this.tokenFcm.add(tokenFcm);
  }

  @override
  set setId(String id) {
    Exception exception;
    if (id.isEmpty) {
      exception = Exception(AppConstants.user_id_empty_error_key.tr);
      throw exception;
    }
    this.id = id;
  }

  @override
  set setCreatedAt(DateTime createdAtParameter) {
    Exception exception;
    createdAtParameter = firebaseTime(createdAtParameter);
    DateTime now = firebaseTime(DateTime.now());
    createdAtParameter = firebaseTime(createdAtParameter);
    if (createdAtParameter.isAfter(now)) {
      exception =
          Exception(AppConstants.user_creating_time_future_error_key.tr);
      throw exception;
    }
    if (createdAtParameter.isBefore(now)) {
      exception = Exception(AppConstants.user_creating_time_past_error_key.tr);
      throw exception;
    }
    createdAt = createdAtParameter;
  }

  @override
  set setUpdatedAt(DateTime updatedAtParameter) {
    Exception exception;
    updatedAtParameter = firebaseTime(updatedAtParameter);
    if (updatedAtParameter.isBefore(createdAt)) {
      exception = Exception(
          AppConstants.user_account_updating_time_before_creating_error_key.tr);
      throw exception;
    }
    updatedAt = updatedAtParameter;
  }

  factory UserModel.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data()!;
    return UserModel.firestoreConstructor(
      nameParameter: data[nameK],
      userNameParameter: data[userNameK],
      bioParameter: data[bioK],
      imageUrlParameter: data[imageUrlK],
      emailParameter: data[emailK],
      tokenFcm: data[tokenFcmK].cast<String>(),
      idParameter: data[idK],
      createdAtParameter: data[createdAtK].toDate(),
      updatedAtParameter: data[updatedAtK].toDate(),
    );
  }
  @override
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[nameK] = name;
    data[idK] = id;
    data[userNameK] = userName;
    data[bioK] = bio;
    data[imageUrlK] = imageUrl;
    data[emailK] = email;
    data[tokenFcmK] = tokenFcm;
    data[createdAtK] = createdAt;
    data[updatedAtK] = updatedAt;
    return data;
  }

  @override
  String toString() {
    return "name $name id $id userName $userName boi $bio imageUrl $imageUrl email $email tokenfcm $tokenFcm createdAt $createdAt updatedAt $updatedAt";
  }
}
CollectionReference userCollection =
FirebaseFirestore.instance.collection('users');
Stream<QuerySnapshot> getUserList() {
  print('getMessage');
  return userCollection
      .where('id', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
}