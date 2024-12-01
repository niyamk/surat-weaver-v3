import 'package:get_storage/get_storage.dart';

class StoragePref {
  static GetStorage box = GetStorage();

  static Future setUsername({required String username}) async {
    await box.write("username", username);
  }

  static deleteLogin() async {
    await box.remove("username");
  }

  static getUsername() {
    return box.read("username");
  }
}
