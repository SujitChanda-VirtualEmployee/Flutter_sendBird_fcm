import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sendbird_fcm/constants.dart';
import 'package:flutter_sendbird_fcm/provider/auth_provider.dart';
import 'package:flutter_sendbird_fcm/services/firebase_services.dart';
import 'package:flutter_sendbird_fcm/services/shared_ervices.dart';
import 'package:flutter_sendbird_fcm/utility/size_config.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";
  final String uid;
  final String phoneNumber;

  RegistrationScreen({
    Key? key,
    required this.phoneNumber,
    required this.uid,
  }) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? _userName,
      _email,
      _myPic =
          "https://firebasestorage.googleapis.com/v0/b/demologinapp-8cf00.appspot.com/o/user1-2.jpg?alt=media&token=cfe5c023-e6c3-480f-98bc-17c46b95865a";
  double? height;
  double? width;
  SharedServices? _sharedServices;
  File? driverImage;
  File? blueBook;
  File? drivingLicence;
  File? cropped;
  String? token;

  String? data1;
  var imageData;

  final _formKey = GlobalKey<FormState>();

  GlobalKey<ScaffoldState>? globalKey;

  bool? checkBoxSubmit;

  FirebaseServices _userServices = new FirebaseServices();

  AuthProvider? authProvider;
  @override
  void initState() {
    _sharedServices = new SharedServices();
    //getToken();
    super.initState();
    globalKey = GlobalKey<ScaffoldState>();

    checkBoxSubmit = false;
  }

  // getToken() async {
  //   token = await firebaseMessaging.getToken();
  // }

  void showErrorSnack(String errorMsg) {
    final snackbar = SnackBar(
      //  behavior: SnackBarBehavior.floating,
      //  padding:EdgeInsets.only(bottom: 45),

      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5))),
      duration: Duration(days: 365),
      content: Text("Error :  $errorMsg",
          style: TextStyle(
              fontFamily: "poppins",
              fontSize: 14.0,
              color: Colors.white,
              fontWeight: FontWeight.normal)),
      action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          // ignore: deprecated_member_use
          onPressed: globalKey!.currentState!.hideCurrentSnackBar),
    );
    // ignore: deprecated_member_use
    globalKey!.currentState!.showSnackBar(snackbar);

    //throw Exception('Error registering: $errorMsg');
  }

  void showSuccessSnack(String successMsg) {
    final snackbar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      duration: Duration(days: 365),
      content: Text(
        "Success :  $successMsg",
        style: TextStyle(
            fontFamily: "poppins",
            fontSize: 14.0,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      ),
      action: SnackBarAction(
          label: 'Close',
          textColor: Colors.white,
          // ignore: deprecated_member_use
          onPressed: globalKey!.currentState!.hideCurrentSnackBar),
    );
    // ignore: deprecated_member_use
    globalKey!.currentState!.showSnackBar(snackbar);

    //throw Exception('Error registering: $errorMsg');
  }

  mHeight() {
    return height = MediaQuery.of(context).size.height;
  }

  mWidth() {
    return width = MediaQuery.of(context).size.width;
  }

  String? _emailValidator(String? value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value!)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  void createUser({String? id, String? number, String? name, String? emailId}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'name': name,
      'email': emailId,
      'profile_Pic_URL': this._myPic,
      'token': token,
      'courses': []
    });
    _sharedServices!.addUserDataToSF(
      name: name!,
      phone: number!,
      email: emailId!,
      picURL: this._myPic!,
    );
    setState(() {
      authProvider!.loading = false;
    });
  }

  void _registerUser({String? name, String? emailId}) async {
    try {
      createUser(
        id: this.widget.uid,
        number: this.widget.phoneNumber,
        name: name,
        emailId: emailId,
      );
      Navigator.pushReplacementNamed(context, '/Landing_Screen');
    } catch (e) {
      setState(() {
        authProvider!.loading = false;
      });
      // errorSnack(context, e.message);
    }
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      if (checkBoxSubmit == true) {
        print("Username: $_userName \n Email: $_email");
        setState(() {
          authProvider!.loading = true;
        });
        _registerUser(name: _userName, emailId: _email);
      } else {
        showAlertDialogForError(
            context, '\n\u2022 CheckBox is Not selected \n');
      }
    } else {
      print("CheckBox Submit ");
      //  errorSnack(context, "Please Select the CheckBox");

    }
  }

  Widget _checkBox() {
    return Padding(
      padding: EdgeInsets.only(
          top: 0.5 * SizeConfig.heightMultiplier!,
          bottom: 0.5 * SizeConfig.heightMultiplier!),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: checkBoxSubmit,
            onChanged: (value) {
              setState(() {
                checkBoxSubmit = !checkBoxSubmit!;
              });
            },
            activeColor: primaryColor,
            checkColor: Colors.white,
            tristate: false,
          ),
          Text.rich(TextSpan(
              text: 'I agree with   ',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white),
              children: <InlineSpan>[
                TextSpan(
                  text: 'Terms & Conditions',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () => Container(),
                )
              ])),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text.rich(TextSpan(
          text: 'Welcome,\n',
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: primaryColor, fontSize: 2.5 * SizeConfig.textMultiplier!),
          children: <InlineSpan>[
            TextSpan(
              text: 'Create New Account.',
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontSize: 2 * SizeConfig.textMultiplier!,
                    color: Colors.grey.shade600,
                  ),
            )
          ])),
    );
  }

  Widget _showUserNameInput() {
    return Padding(
      padding: EdgeInsets.only(top: 0.5 * SizeConfig.heightMultiplier!),
      child: TextFormField(
          onSaved: (val) => _userName = val!.trim(),
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) => value!.length < 3 ? "UserName too Short" : null,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(
                top: 1 * SizeConfig.heightMultiplier!,
                bottom: 1 * SizeConfig.heightMultiplier!,
                left: 15,
                right: 15),
            prefixIcon: Icon(
              EvaIcons.personOutline,
              color: primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            errorMaxLines: 1,
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            labelText: 'Full Name',
            labelStyle: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            hintText: "Enter Full Name* ",
            hintStyle: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            errorStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _showEmailInput() {
    return Padding(
      padding: EdgeInsets.only(top: 1.5 * SizeConfig.heightMultiplier!),
      child: TextFormField(
          onSaved: (val) => _email = val!.trim().toLowerCase(),
          validator: _emailValidator,
          keyboardType: TextInputType.emailAddress,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.only(
                top: 1 * SizeConfig.heightMultiplier!,
                bottom: 1 * SizeConfig.heightMultiplier!,
                left: 15,
                right: 15),
            prefixIcon: Icon(
              EvaIcons.emailOutline,
              color: primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            errorMaxLines: 1,
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 0.7, color: primaryColor),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            labelText: 'Email ID',
            labelStyle: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            hintText: "Enter Email ID* ",
            hintStyle: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            errorStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _showPhoneNumber() {
    return Padding(
        padding: EdgeInsets.only(top: 1.5 * SizeConfig.heightMultiplier!),
        child: Container(
          width: double.infinity,
          // height:55,
          child: Card(
              margin: EdgeInsets.zero,
              color: secondaryColor,
              elevation: 0,
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: primaryColor, width: 0.7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 14, bottom: 14, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            EvaIcons.phoneOutline,
                            size: 18,
                            color: primaryColor,
                          ),
                          SizedBox(width: 10),
                          Text(widget.phoneNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(EvaIcons.checkmarkCircle,
                          size: 22, color: primaryColor),
                    ],
                  ))),
        ));
  }

  Widget _signUpButton() {
    return Center(
      child: Container(
        height: 6.5 * SizeConfig.heightMultiplier!,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
                // side: BorderSide(color: bgColor, width: 0.0),
                borderRadius: BorderRadius.circular(50)),
            elevation: 3,
            primary: primaryColor,
          ),
          child: Text("CONTINUE",
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  fontSize: 20, color: Colors.white, letterSpacing: 1.5)),
          onPressed: () {
            _submit();
          },
        ),
      ),
    );
  }

  Widget _inputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 2 * SizeConfig.heightMultiplier!,
                  vertical: 2 * SizeConfig.heightMultiplier!),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _header(),
                    _showUserNameInput(),
                    _showEmailInput(),
                    _showPhoneNumber(),
                    SizedBox(height: 2 * SizeConfig.heightMultiplier!),
                    _checkBox(),
                    SizedBox(height: 2 * SizeConfig.heightMultiplier!),
                    _signUpButton()
                  ]),
            ),
          ),
        ),
        SizedBox(height: 2 * SizeConfig.heightMultiplier!),
        // SizedBox(height: 1 * SizeConfig.heightMultiplier),
      ],
    );
  }

  Widget brandLogo() {
    return Center(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(500),
        ),
        color: Colors.transparent,
        child: Container(
            width: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                'assets/appLogo1.png',
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(color: secondaryColor),
          height: mHeight(),
          width: mWidth(),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    brandLogo(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!,
                            left: 1 * SizeConfig.heightMultiplier!,
                            right: 1 * SizeConfig.heightMultiplier!,
                          ),
                          child: Text("Let's Get Started!",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 1 * SizeConfig.heightMultiplier!,
                            left: 1 * SizeConfig.heightMultiplier!,
                            right: 1 * SizeConfig.heightMultiplier!,
                          ),
                          child: Text(
                              "Please Sign up to continue using our app.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                      letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 1 * SizeConfig.heightMultiplier!,
                        right: 1 * SizeConfig.heightMultiplier!,
                        top: 1 * SizeConfig.heightMultiplier!,
                      ),
                      child: _inputForm(),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
                Visibility(
                    visible: authProvider!.loading, child: glassLoading())
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
        //backgroundColor: Colors.transparent,
        key: globalKey,
        //  resizeToAvoidBottomInset: false,
        body: _body());
  }

  showAlertDialogForError(BuildContext context, String title) {
    // set up the button
    Widget okButton = TextButton(
        style: TextButton.styleFrom(
            // elevation: 4,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.all(Radius.circular(8))),
            primary: Theme.of(context).colorScheme.secondary),
        child: Text(
          "CLOSE",
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: Colors.black),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
        });

    // set up the AlertDialog
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text("Error !",
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primaryColor)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyText1),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   crossAxisAlignment: CrossAxisAlignment.end,
          //   children: [
          //     Text("\n\u2022 Check Box",
          //         style: Theme.of(context).textTheme.bodyText1),

          //   ],
          // ),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context1) {
        return alert;
      },
    );
  }
}
