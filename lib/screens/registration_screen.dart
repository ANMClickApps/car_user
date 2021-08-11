import 'package:car_user/constant_text.dart';
import 'package:car_user/screens/login_screen.dart';
import 'package:car_user/screens/main_screen.dart';
import 'package:car_user/widgets/progress_dialog.dart';
import 'package:car_user/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();

  void registerUser() async {
    //show please wait dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: textSignUpDialog,
            ));
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
      //check if user registration is successful
      if (userCredential.user != null) {
        DatabaseReference newUserRef = FirebaseDatabase.instance
            .reference()
            .child('user/${userCredential.user.uid}');
        //Prepare data to be saved on users table
        Map userMap = {
          'fullname': fullNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
        };
        newUserRef.set(userMap);

        //Take the user to the mainScreen
        Navigator.pushNamedAndRemoveUntil(
            context, MainScreen.id, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      //check error and display message
      Navigator.pop(context);
      PlatformException thisEx = e;
      showSnackBar(thisEx.message);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 36.0,
                ),
                Image(
                  height: 100.0,
                  width: 100.0,
                  alignment: Alignment.center,
                  image: AssetImage('assets/images/logo-min.png'),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  textSignUpTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 25.0, height: 1.5),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: 20.0, top: 5.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: [
                      //Full name
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: textFieldName,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Email Address
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: textFieldEmail,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Phone number
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: textFieldPhone,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: textFieldPassword,
                            labelStyle: TextStyle(
                              fontSize: 14.0,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 36.0,
                      ),
                      TaxiButton(
                        text: textSignUpButton,
                        onPressed: () async {
                          //check network
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar(textConnectivityError);
                            return;
                          }

                          if (fullNameController.text.length < 3) {
                            showSnackBar(textNameError);
                            return;
                          }
                          if (!emailController.text.contains('@')) {
                            showSnackBar(textEmailError);
                            return;
                          }
                          if (phoneController.text.length < 10) {
                            showSnackBar(textPhoneError);
                            return;
                          }
                          if (passwordController.text.length < 8) {
                            showSnackBar(textPasswordError);
                            return;
                          }

                          registerUser();
                        },
                      )
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginScreen.id, (route) => false);
                    },
                    child: Text(textAccount))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
