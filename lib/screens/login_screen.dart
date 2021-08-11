import 'package:car_user/constant_text.dart';
import 'package:car_user/screens/main_screen.dart';
import 'package:car_user/screens/registration_screen.dart';
import 'package:car_user/widgets/progress_dialog.dart';
import 'package:car_user/widgets/taxi_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void login() async {
    //show please wait dialog
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: textLoginDialog,
            ));
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      if (userCredential.user != null) {
        DatabaseReference userRef = FirebaseDatabase.instance
            .reference()
            .child('user/${userCredential.user.uid}');

        userRef.once().then((DataSnapshot snapshot) => {
              if (snapshot.value != null)
                {
                  Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.id, (route) => false),
                }
            });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
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
                  height: 70.0,
                ),
                Image(
                  height: 100.0,
                  width: 100.0,
                  alignment: Alignment.center,
                  image: AssetImage('assets/images/logo-min.png'),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  textLoginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
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
                        height: 40.0,
                      ),
                      TaxiButton(
                        text: textLoginButton,
                        onPressed: () async {
                          var connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi) {
                            showSnackBar(textConnectivityError);
                            return;
                          }

                          if (!emailController.text.contains('@')) {
                            showSnackBar(textEmailError);
                            return;
                          }
                          if (passwordController.text.length < 8) {
                            showSnackBar(textPasswordError);
                            return;
                          }
                          login();
                        },
                      ),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, RegistrationScreen.id, (route) => false);
                    },
                    child: Text(textNoAccount))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
