
import 'package:flutter_sendbird_fcm/constants.dart';

class SharedServices {
  static const String userName = "_userName";
  static const String userEmail = "_userEmail";
  static const String userPhone = "_userPhone";
  static const String userPic = "_userPicURL";
  void addUserDataToSF({
    required String name,
    required String email,
    required String phone,
    required String picURL,
  }) async {
    print("Email : $email");
    print('Name : $name');
    print("Phone:  $phone");
    print('PicURL : $picURL');

    prefs!.setString(userName, name);
    prefs!.setString(userEmail, email);
    prefs!.setString(userPhone, phone);
    prefs!.setString(userPic, picURL);
  }
}
