import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/Registration/countries.dart';
import 'package:tuchati/screens/Registration/profile.dart';
import 'package:tuchati/screens/Registration/verification.dart';
import 'package:tuchati/screens/main_tab_bar/main_tab_bar.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Phone extends StatefulWidget {
  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final GlobalKey<FormState> _phonekey = GlobalKey<FormState>();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController countryflag = TextEditingController(text: "TZ");
  String selected = "TZ";
  @override
  void initState() {
    phoneNumber.text = "+255";
    super.initState();
  }

  bool attempt = false;
  bool isPhone(phone) => phone.isNotEmpty && phone.toString().length > 11;
  @override
  Widget build(BuildContext context) {
    var c;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 40,
                      left: 20,
                      width: 80,
                      height: 200,
                      child: FadeAnimation(
                          1,
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      top: 20,
                      child: FadeAnimation(
                          1.3,
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/profile.png'))),
                          )),
                    ),
                    Positioned(
                      right: 40,
                      top: 40,
                      width: 80,
                      height: 150,
                      child: FadeAnimation(
                          1.5,
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png'))),
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
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                        1.8,
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: _phonekey,
                            child: Column(
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Verification code will be sent to your phone number",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    controller: phoneNumber,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter phone number";
                                      } else if (!isPhone(phoneNumber.text)) {
                                        return "Invalid phone number";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        prefix: SizedBox(
                                          height: 40,
                                          width: 60,
                                          child: CountryPickerDropdown(
                                            initialValue: 'TZ',
                                            itemBuilder: _buildDropdownItem,
                                            itemFilter: (country) {
                                              return true;
                                            },
                                            priorityList: [
                                              CountryPickerUtils
                                                  .getCountryByIsoCode('TZ'),
                                              CountryPickerUtils
                                                  .getCountryByIsoCode('KN'),
                                            ],
                                            sortComparator: (Country a,
                                                    Country b) =>
                                                a.isoCode.compareTo(b.isoCode),
                                            onValuePicked: (Country country) {
                                               phoneNumber.text="+${country.phoneCode}";
                                            },
                                          ),
                                        ),
                                        border: InputBorder.none,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                        2,
                        GestureDetector(
                          onTap: () async {
                            if (_phonekey.currentState!.validate()) {
                              setState(() {
                                attempt = true;
                              });
                              bool result = await FirebaseService()
                                  .sendOTP(phoneNumber.text, context);
                              if (result) {
                                setState(() {
                                  attempt = false;
                                });
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PhoneVerification(
                                      phone: phoneNumber.text),
                                ));
                              } else {
                                snackBar("something went wrong!!!!");
                              }
                            }
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  AppColors.appColor,
                                  AppColors.primaryColor,
                                ])),
                            child: Center(
                              child: attempt
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    )
                                  : Text(
                                      "Continue",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
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

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
          ],
        ),
      );
}
