import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/provider/auth_provider.dart';
import 'package:flutter_sendbird_fcm/widgets/onboard_screen.dart';
import 'package:flutter_sendbird_fcm/widgets/rounded_icon_btn.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final SmsAutoFill _autoFill = SmsAutoFill();
  TextEditingController _phoneNumberController = new TextEditingController();
  late String completePhoneNumber;
  bool isValid2 = false;
  bool isValid = false;
  bool numberSubmit = false;

  String? validateMobile(String value) {
    if (value.length == 0) {
      return "*Mobile Number is Required";
    } else if (value.length < 10 || value.length > 10) {
      return "*Enter valid Number";
    } else {
      return null;
    }
  }

  Future<Null> validatePhone(StateSetter updateState) async {
    print("in validate : ${_phoneNumberController.text.length}");
    if (_phoneNumberController.text.length > 9 &&
        _phoneNumberController.text.length < 11) {
      updateState(() {
        isValid = true;
      });
      print(isValid);
    } else {
      updateState(() {
        isValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    void validatePhoneNumber(BuildContext context) async {
      if (Platform.isAndroid) {
        try {
          completePhoneNumber = (await _autoFill.hint)!;
          setState(() {
            _phoneNumberController.text = completePhoneNumber.substring(3);
          });
        } catch (e) {
          print(e.toString());
        }
      }

      showModalBottomSheet(
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
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'OTP Verification',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "* You need to verify your Phone Number via OTP Verification process to Register / Login to your account.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.grey[500], fontSize: 10),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (val) => validateMobile(val!),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(fontSize: 18),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    top: 10, bottom: 10, left: 15, right: 15),
                                prefix: Container(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text("+91",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            color: Colors.grey,
                                            fontSize: 17,
                                          )),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      width: 0.2,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    gapPadding: 1),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
                                ),
                                labelText: " Mobile Number",
                                labelStyle:
                                    Theme.of(context).textTheme.bodyText1,
                                hintText: 'Mobile Number *',
                                hintStyle:
                                    Theme.of(context).textTheme.bodyText1,
                              ),
                              //maxLength: 10,

                              keyboardType: TextInputType.number,
                              controller: _phoneNumberController,
                              autofocus: true,
                              onChanged: (text) {
                                validatePhone(state);
                              },
                              autovalidateMode: AutovalidateMode.always,
                              autocorrect: false,
                            ),
                          ),
                          SizedBox(width: 10),
                          Visibility(
                              visible: _phoneNumberController.text.length > 9 &&
                                  _phoneNumberController.text.length < 11,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 0),
                                child: RoundedIconBtn(
                                  bgColor: Colors.white,
                                  showShadow: true,
                                  radius: 26,
                                  icon: Icons.send_outlined,
                                  iconColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  iconSize: 25,
                                  press: () {
                                    print("IsValid : $isValid");
                                    print("IsValid2 : $isValid2");
                                    state(() {
                                      numberSubmit = true;
                                    });
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  },
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                );
              })).whenComplete(() {
        if (_phoneNumberController.text.length == 10 && numberSubmit) {
          print(_phoneNumberController.text);
          setState(() {
            auth.loading = true;
          });
          String number = '+91${_phoneNumberController.text}';

          auth
              .verifyPhone(
            context: context,
            number: number,
          )
              .then((value) {
            _phoneNumberController.clear();
          });
        } else {
          _phoneNumberController.clear();
        }
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: OnBaordScreen(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text.rich(
                      TextSpan(
                          text: 'A Basic',
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: ' Chat Application',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () => Container(),
                            ),
                            TextSpan(
                              text:
                                  ' made with Flutter, Firebase and SendBird ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                              recognizer: new TapGestureRecognizer()
                                ..onTap = () => Container(),
                            )
                          ]),
                      textAlign: TextAlign.center),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            // side: BorderSide(color: bgColor, width: 0.0),
                            borderRadius: BorderRadius.circular(8)),
                        primary: primaryColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "LOGIN",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  letterSpacing: 2,
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          auth.screen = 'Login';
                        });

                        validatePhoneNumber(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: auth.loading,
              child: glassLoading(),
            )
          ],
        ),
      ),
    );
  }
}

//Lets do a restart.
