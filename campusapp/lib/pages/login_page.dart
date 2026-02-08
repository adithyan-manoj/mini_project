//import 'dart:io';
import 'package:campusapp/pages/home_dashboard.dart';
import 'package:campusapp/services/api_service.dart';
import 'package:campusapp/widgets/custom_button.dart';
import 'package:campusapp/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isActive = true;
  bool _isLoggingIn = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  void handleLogin() async {
    String email = _emailcontroller.text.trim();
    String password = _passwordcontroller.text.trim();
    print('Email: ${_emailcontroller.text}');
    print('Password: ${_passwordcontroller.text}');

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Fields cannot be empty!');
      return;
    }

    // if (!email.contains("@")) {
    //   _showErrorSnackBar("Please enter a valid email address");
    //   return;
    // }

    // 3. Password Length Check
    // if (password.length < 6) {
    //   _showErrorSnackBar("Password must be at least 6 characters");
    //   return;
    // }
    setState(() {
      _isLoggingIn = true;
    });

    final result = await ApiService.login(email, password);

    setState(() {
      _isLoggingIn = false;
    });

    if (result['statusCode'] == 200) {
      print("Success: ${result['body']['message']}");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      String error = result['body']['detail'] ?? "Login failed";
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(String message) {
    //alert message bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color.fromARGB(255, 255, 99, 99),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double toggleWidth = screenWidth * 0.9;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 30, 30),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'APP NAME',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 40),
                    child: Align(
                      alignment: AlignmentGeometry.bottomLeft,
                      child: Column(
                        children: [
                          Text(
                            isActive ? 'Welcome Back' : 'Signup now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Jump back in and continue right where you left off.',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 159, 80),
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Align(
                alignment: AlignmentGeometry.bottomCenter,
                //bottom container
                child: Container(
                  //margin: EdgeInsets.only(top: 350),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 251, 251, 251),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 35),
                      Padding(
                        //inner toggle selection
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          width: toggleWidth,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(235, 227, 227, 227),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Stack(
                            children: [
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: isActive
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Container(
                                  width: toggleWidth / 2,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 8,
                                        color: Colors.black.withOpacity(0.09),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //SizedBox(height: 20,),
                              SizedBox(
                                height: 65,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            isActive = true;
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isActive
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            isActive = false;
                                          });
                                        },
                                        child: Center(
                                          child: Text(
                                            "Signup",
                                            style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: !isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: !isActive
                                                  ? Colors.black
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        icon: Icons.mail_outline_rounded,
                        isPassword: false,
                        label: 'Email Address',
                        textController: _emailcontroller,
                      ),

                      CustomTextField(
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        label: 'Password',
                        textController: _passwordcontroller,
                      ),

                      if (!isActive)
                        CustomTextField(
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          label: 'Confirm Password',
                          textController: _passwordcontroller,
                        ),

                      // forgot password text
                      if (isActive)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      CustomButton(
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => HomePage()),
                          // );
                          handleLogin();

                          // if(_formKey.currentState!.validate()) {
                          //   print("Form is valid! Email: ${_emailcontroller.text}");
                          //   return;
                          // } else {
                          //   print("Form is invalid");
                          // }

                          // 2. Simple Email Check

                          // move to dashboard if verified
                          // If all checks pass:
                          //print("Success! Logging in...");
                        },
                        label: isActive ? 'Login' : 'Signup',
                        isLoading: _isLoggingIn,
                      ),

                      // or login area
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(thickness: 0.5, color: Colors.grey),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                isActive ? 'or login with' : 'or signup with',
                              ),
                            ),
                            Expanded(
                              child: Divider(thickness: 0.5, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 232, 232, 232),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10,
                                offset: Offset(2, 2),
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/google.png',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
