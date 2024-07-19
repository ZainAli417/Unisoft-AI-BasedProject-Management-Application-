import 'package:firebase_storage/firebase_storage.dart';

DateTime firebaseTime(DateTime dateTime) {
  DateTime newDate = DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    0,
  );
  return newDate;
}

final firebaseStorage = FirebaseStorage.instance;
const String defaultGroupPathInStorage =
    "https://firebasestorage.googleapis.com/v0/b/unisoft-tmp.appspot.com/o/Default%2FdefaultGroup.png?alt=media&token=07c2430a-1d8e-4c2f-82e5-8097ab387147";
const String defaultUserImageProfile =
    "https://firebasestorage.googleapis.com/v0/b/unisoft-tmp.appspot.com/o/Default%2Fdummy-profile.png?alt=media&token=ebbb29f7-0ab8-4437-b6d5-6b2e4cfeaaf7";

const String defaultProjectImage =
    "https://firebasestorage.googleapis.com/v0/b/unisoft-tmp.appspot.com/o/Default%2FprojectImage.jpg?alt=media&token=e36e1ef3-0250-4381-8b34-06343ac6ce7a";

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}
