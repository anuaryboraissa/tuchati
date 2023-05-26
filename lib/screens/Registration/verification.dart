import 'dart:async';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/Registration/profile.dart';
import 'package:tuchati/screens/main_tab_bar/main_tab_bar.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:tuchati/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key, required this.phone});
  final String phone;
  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  bool attempt = false;
  StreamController<ErrorAnimationType>? errorcontroller;
  TextEditingController pins = TextEditingController();
  bool haserror = false;
  String currentText = '';
  final formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    errorcontroller!.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    errorcontroller = StreamController<ErrorAnimationType>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.fill)),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0, left: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: FadeAnimation(
                          1,
                          Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  Positioned(
                    left: 110,
                    top: 50,
                    width: 200,
                    height: 150,
                    child: FadeAnimation(
                        1.5,
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Verification",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                  ),
                  Positioned(
                    child: FadeAnimation(
                        1.6,
                        Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Tuchati",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
            Card(
              elevation: 8,
              child: Container(
                width: 500,
                padding: EdgeInsets.all(30),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(40)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Let Us Verfify Your phone number",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.8333333333,
                        letterSpacing: 1,
                        color: Color(0xff77838f),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Phone Number Verification",
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.8333333333,
                          letterSpacing: 0.5,
                          color: Color(0xff77838f),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Enter verification code received via sms",
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.6333333333,
                          letterSpacing: 0.5,
                          color: Color(0xff77838f),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Form(
                        key: formkey,
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                              color: AppColors.appColor,
                              fontWeight: FontWeight.bold),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          obscuringWidget: Icon(
                            Icons.pets,
                            color: AppColors.appColor,
                            size: 24,
                          ),
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (value) {
                            if (value!.length < 3) {
                              return "validate me";
                            }
                            return null;
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeColor: Colors.white,
                            inactiveColor: Colors.white,
                          ),
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorcontroller,
                          controller: pins,
                          keyboardType: TextInputType.number,
                          boxShadows: [
                            BoxShadow(
                                offset: Offset(0, 1),
                                color: Colors.black12,
                                blurRadius: 10)
                          ],
                          onCompleted: (value) {
                            // print("completed");
                          },
                          beforeTextPaste: (text) {
                            return true;
                          },
                          onChanged: (String value) {
                            // print(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        haserror ? "*please fill the cells properly" : "",
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive the text? ",
                          style: TextStyle(fontSize: 15),
                        ),
                        TextButton(
                            onPressed: () {
                              //resend otp
                              FirebaseService().sendOTP(widget.phone, context);
                            },
                            child: Text("RESEND",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.appColor,
                                    fontWeight: FontWeight.bold)))
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: AppColors.appColor,
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 80,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13))),
                        onPressed: () {
                          if (formkey.currentState!.validate()) {
                            if (currentText.length != 6) {
                              errorcontroller!.add(ErrorAnimationType.shake);
                              setState(() {
                                haserror = true;
                              });
                            } else {
                              setState(() {
                                attempt = true;
                              });
                              verifyOTP(currentText);
                              //verify otp
                            }
                          }
                        },
                        child: attempt
                            ? CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              )
                            : Text("Verify",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void verifyOTP(String currentText) async {
    try {
      // sendOTP(widget.phone);
      FirebaseAuth auth = FirebaseAuth.instance;
      String? verificationid =
          await SecureStorageService().readSecureData("otp");
      if (verificationid != null) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationid, smsCode: currentText);
        await auth.signInWithCredential(credential);
        String uid = await auth.currentUser!.uid;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Profile(
            phone: widget.phone,
            uid: uid,
          ),
        ));

        // DocumentReference ref = FirebaseFirestore.instance
        //     .collection("users")
        //     .doc("${widget.email}");
        // final data = {"uid": uid};
        // ref.update(data);
        await auth.signOut();
        setState(
          () {
            snackBar("OTP Verified!!");
          },
        );
      } else {
        // ignore: use_build_context_synchronously
        FirebaseService().sendOTP(widget.phone, context);
      }
      setState(() {
        attempt = false;
      });
    } catch (e) {
      snackBar("OTP expired!! please Resend to get new one..");
      setState(() {
        attempt = false;
      });
    }
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
        width: 280.0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
