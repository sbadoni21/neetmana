import 'package:flutter/material.dart';
import 'package:matrimonial/screens/homepage.dart';
import 'package:matrimonial/screens/signupscreen.dart';
import 'package:matrimonial/services/auth/authentication.dart';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:matrimonial/utils/static.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  AuthenticationServices authenticationService = AuthenticationServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 150, 16, 16),
        child: ListView(
          children: [
            Container(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/placeholder_image.png",
                    fit: BoxFit.contain,
                    height: 230,
                    width: 180,
                  ),
                  Center(
                      child: Text(
                    "Matrimonial",
                    style: TextStyle(
                      color: bgColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Text(
                    "Login",
                    style: TextStyle(
                        color: bgColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: bgColor),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: bgColor),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if (email.isNotEmpty && password.isNotEmpty) {
                      User? user =
                          await authenticationService.signIn(email, password);

                      if (user != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                        print('Login successful');
                      } else {
                        print('Login failed');
                      }
                    } else {
                      print('Please enter email and password');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5.0,
                    backgroundColor: bgColor, // Background color
                    foregroundColor: Colors.white, // Text color
                    padding:
                        EdgeInsets.symmetric(horizontal: 45.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Login'),
                ),
                SizedBox(height: 16.0),
                // ElevatedButton(
                //   onPressed: () async {
                //     User? user = await authenticationService.signInWithGoogle();

                //     if (user != null) {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => HomePage()),
                //       );
                //       print('Login with Google successful');
                //     } else {
                //       print('Login with Google failed');
                //     }
                //   },
                //   style: ElevatedButton.styleFrom(
                //     shape: CircleBorder(),
                //     backgroundColor: bgColor,
                //     elevation: 5.0,
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(10.0),
                //     child: Image.asset(
                //       "assets/images/google.png",
                //       width: 32.0,
                //       height: 32.0,
                //     ),
                //   ),
                // ),
                // SizedBox(
                //   height: 20,
                //   child: Text(
                //     "login using google",
                //     style: TextStyle(color: bgColor),
                //   ),
                // ),
                // SizedBox(
                //   height: 30,
                // ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    backgroundColor: Colors.white, // Text color
                    side: BorderSide(color: bgColor), // Border color
                  ),
                  child: Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text('Sign Up')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
