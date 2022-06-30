import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/screens/registration_screen.dart';
import 'package:flutter_sendbird_fcm/services/firebase_services.dart';
import 'package:flutter_sendbird_fcm/services/shared_ervices.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/params/group_channel_params.dart';
import 'package:sendbird_sdk/query/channel_list/group_channel_list_query.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';
import 'package:sms_autofill/sms_autofill.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedServices _sharedServices = SharedServices();
  final FirebaseServices _services = FirebaseServices();
  String smsOtp = "";
  String? verificationId;
  String error = '';
  bool otpSubmit = false;
  bool loading = false;
  String? screen;
  double? latitude;
  double? longitude;
  String? address;
  String? location;
  String? username;
  String? phoneNumber;
  String? email;
  String? uid;

  //DocumentSnapshot snapshot;
  final TextEditingController _pinEditingController = TextEditingController();
  final PinDecoration _pinDecoration = const BoxLooseDecoration(
    gapSpace: 8,
    textStyle: TextStyle(color: Colors.black, fontSize: 20),
    hintText: '******',
    hintTextStyle: TextStyle(color: Colors.grey, fontSize: 20),
    strokeColorBuilder: FixedColorBuilder(Colors.blue),
  );

  Future<void> verifyPhone(
      {required BuildContext context, required String number}) async {
    loading = true;
    notifyListeners();

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = true;
      notifyListeners();
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = true;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;
      print(number);
      this.loading = false;
      notifyListeners();
      smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  smsOtpDialog(BuildContext context, String number) {
    this.loading = false;
    notifyListeners();
    return showModalBottomSheet(
            isDismissible: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
            ),
            backgroundColor: Colors.white,
            isScrollControlled: true,
            context: context,
            builder: (context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter state) {
                  return Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: new Container(
                            width: MediaQuery.of(context).size.width / 5,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'OTP Sent to $number',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Enter 6 digit OTP received as SMS",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .copyWith(color: Colors.grey[500], fontSize: 10),
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 50,
                          child: PinFieldAutoFill(
                            codeLength: 6,
                            autoFocus: true,
                            decoration: _pinDecoration,
                            controller: _pinEditingController,
                            //currentCode: _code,
                            onCodeSubmitted: (code) {
                              this.smsOtp = code;
                              otpSubmit = true;
                              notifyListeners();
                            },
                            onCodeChanged: (code) async {
                              if (code!.length == 6) {
                                this.smsOtp = code;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                this.smsOtp = code;
                                otpSubmit = true;
                                notifyListeners();
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 30.0),
                      ],
                    ),
                  );
                }))

        // showCupertinoDialog(
        //     barrierDismissible: false,
        //     context: context,
        //     builder: (BuildContext context) {
        //       return CupertinoAlertDialog(
        //         title: Column(
        //           children: [
        //             Text('Verification Code'),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             Text(
        //               'Enter 6 digit OTP received as SMS',
        //               style: TextStyle(color: Colors.grey, fontSize: 12),
        //             ),
        //             SizedBox(
        //               height: 10,
        //             ),
        //           ],
        //         ),
        //         content: Container(
        //           height: 50,
        //           child: PinFieldAutoFill(
        //             codeLength: 6,
        //             autoFocus: true,
        //             decoration: _pinDecoration,
        //             controller: _pinEditingController,
        //             //currentCode: _code,
        //             onCodeSubmitted: (code) {
        //               this.smsOtp = code;
        //               otpSubmit = true;
        //               notifyListeners();
        //             },
        //             onCodeChanged: (code) async {
        //               if (code!.length == 6) {
        //                 this.smsOtp = code;
        //                 FocusScope.of(context).requestFocus(FocusNode());
        //                 this.smsOtp = code;
        //                 otpSubmit = true;
        //                 notifyListeners();
        //                 Navigator.of(context, rootNavigator: true).pop();
        //               }
        //             },
        //           ),
        //         ),
        //       );
        //     })

        .whenComplete(() async {
      this.loading = true;
      notifyListeners();
      if (smsOtp.length == 6 && otpSubmit)
        try {
          // Navigator.of(context).pop();

          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verificationId!, smsCode: smsOtp);
          final User? user =
              (await _auth.signInWithCredential(phoneAuthCredential)).user;
          if (user != null) {
            print("Login SuccessFul");
            _services.getUserById(user.uid).then((snapShot) {
              if (snapShot.exists) {
                //user data already exists

                if (this.screen == 'Login') {
                  username = "${snapShot['name']}";
                  phoneNumber = '${snapShot["number"]}';
                  email = '${snapShot['email']}';
                  notifyListeners();
                  _sharedServices.addUserDataToSF(
                    name: '${snapShot['name']}',
                    phone: '${snapShot['number']}',
                    email: '${snapShot['email']}',
                    picURL: '${snapShot['profile_Pic_URL']}',
                  );
                  Navigator.pushReplacementNamed(context, '/Landing_Screen');
                } else {
                  //need to update new selected address
                  //  updateUser(id: user.uid, number: user.phoneNumber);

                }
              } else {
                // user data does not exists
                // will create new data in db
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen(
                              phoneNumber: user.phoneNumber!,
                              uid: user.uid,
                            )));

                // createUser(id: user.uid, number: user.phoneNumber);
                // Navigator.pushReplacementNamed(context, LandingPage.idScreen);
              }
            });
          } else {
            print('Login failed');
          }
        } catch (e) {
          this.error = 'Invalid OTP';
          this.loading = false;
          notifyListeners();

          print(e.toString());
        }
      this.loading = false;
      notifyListeners();
    });
  }
}
