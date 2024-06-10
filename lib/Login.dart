import 'dart:math';

import 'package:email_otp/email_otp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';

import 'package:picnicpalfinal/adminhome.dart';

import 'package:picnicpalfinal/apiclass.dart';

// import 'package:picnicpalfinal/HomePage.dart';
import 'package:picnicpalfinal/verification.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double logoWidth = screenWidth * 0.9;
    final double logoHeight = screenHeight * 0.25;

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Image.asset(
              "assets/Logo.png",
              width: logoWidth,
              height: logoHeight,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF1F4434),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: TabBar(
                  indicatorColor: Color(0xFF09C7BE),
                  indicatorPadding: EdgeInsets.fromLTRB(10, 0, 10, 15), // Adjusted padding
                  indicatorWeight: 2.5,
                  tabs: [
                    Tab(
                      text: 'LOGIN',
                    ),
                    Tab(
                      text: 'SIGN UP',
                    ),
                  ],
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 90,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: TabBarView(
                      children: [
                        FormFields(),  // Replace with your FormFields widget
                        Signup_FormFields(),  // Replace with your Signup_FormFields widget
                      ],
                    ),
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

class FormFields extends StatefulWidget {
  const FormFields({Key? key}) : super(key: key);

  @override
  State<FormFields> createState() => _FormFields();
}

class _FormFields extends State<FormFields> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;
  bool isButtonHovered = false;
  bool user = false;

  Future<String?> checkUserExistenceAndProceed() async {
    final dio = Dio();
    final username = usernameController.text;
    final password = passwordController.text;
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Check the response data for user existence or any other relevant information.
        // Replace with the actual field name

        final Map<String, dynamic> data = response.data;

        if (data.containsKey('token') && data.containsKey('role')) {
          String authToken = data['token'];
          String role = data['role'];
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', authToken);

          if (role == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homescreen()),
            );
          } else if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => adminhome()),
            );
          }
         
        }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(
            child: Text(
              'Welcome, $username',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Color(0xFF1F4434),
          duration: Duration(seconds: 5),
        ));
      } else {
        // Handle HTTP request errors
        print('Error: ${response.statusCode}');
      }
    } 
    on DioError catch (e) {
    if (e.response!.statusCode == 400) {
      // Handle 401 Unauthorized error (incorrect credentials)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('field emoty ${e.response!.statusCode}'),
      ));
    } else if (e.response!.statusCode == 401) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Username or Pasword not correct'),
      ));
    } else {
      // Handle other Dio errors
      print('Dio Error: $e');
     }
     }
     catch (e) {
      print('Dio Error: $e');
    }
  

   
   }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F4434),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sign in with your account",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF505050),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter Your Email or Username",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.person_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            _isObscured
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Color(0xFF1F4434),
                            size: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 50, 30, 10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      checkUserExistenceAndProceed();
                      //                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      // final authToken = await authProvider.login(usernameController.text, passwordController.text);

                      // Navigate to the home page or any other page after successful login
                      // if(authToken!=null){

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => test(authToken: authToken),
                      //   ),
                      // );
                      // }
                      if (_formKey.currentState!.validate()) {
                        // Access the entered values using controllers
                        final username = usernameController.text;
                        final password = passwordController.text;

                        // Now you can use username and password for further processing
                        // Handle login button press with valid input
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFF09C7BE), minimumSize: Size(200, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 50, 30, 10),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Forgot your password? ",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF505050),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Reset here",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Handle the tap event here, e.g., navigate to a reset password screen.
                              print("Reset password link tapped");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ]),
      ),
    );
  }
}

class Signup_FormFields extends StatefulWidget {
  const Signup_FormFields({Key? key}) : super(key: key);

  @override
  State<Signup_FormFields> createState() => S_FormFields();
}

class S_FormFields extends State<Signup_FormFields> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  bool _isObscured = true;
  bool _confirmObscured = true;

  Future<bool> _checkUsernameExists(String username) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/checkuser', // Replace with your actual backend URL
        data: {'username': username},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data['exists'];
      } else {
        // Handle API error
        throw Exception('Failed to check username existence');
      }
    } catch (e) {
      // Handle Dio error
      throw Exception('Failed to check username existence');
    }
  }

  void _validateAndSendOTP() async {
    if (_validateFields()) {
      // Check if the user already exists
      try {
        bool usernameExists = await _checkUsernameExists(
          usernameController.text,
        );
        if (usernameExists) {
          _showSnackBar('Username already exists. ');
        } else {
          // If the username doesn't exist, proceed with sending OTP
          print("test");
          _sendOTP();
        }
      } catch (e) {
        // Handle error
        print(e.toString());
        _showSnackBar('Failed to check username existence.');
      }
    }
  }

  bool _validateFields() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return false;
    } else if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
        .hasMatch(emailController.text)) {
      _showSnackBar('Please enter a valid email address.');
      return false;
    } else if (passwordController.text != confirmpasswordController.text) {
      _showSnackBar('Passwords do not match.');
      return false;
    }
    return true;
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  EmailOTP myAuth = EmailOTP();
  void _sendOTP() async {
    myAuth.setConfig(
        appEmail: "karowaliyazayan@gmail.com",
        appName: "PicnicPal ~ Email OTP",
        userEmail: emailController.text,
        otpLength: 4,
        otpType: OTPType.digitsOnly);

    var template = 'Thank you for choosing {{app_name}}. Your OTP is {{otp}}.';
    // myAuth.setTemplate(render: template);
  await myAuth.sendOTP();
    // print(response);
  
    // Navigate to OTP verification screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => verification(
          email: emailController.text,
          username: usernameController.text,
          password: passwordController.text,
          myAuth: myAuth,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30, 40, 30, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create account",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F4434),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Fill form below to register your account",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF505050),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter Your Username",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.person_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "Enter Your Email",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.envelope_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: _isObscured,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Your Password",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            _isObscured
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Color(0xFF1F4434),
                            size: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextFormField(
                  controller: confirmpasswordController,
                  obscureText: _confirmObscured,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    hintText: "Confirm Your Password",
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF949494),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.lock_fill,
                      color: Color(0xFF1F4434),
                      size: 25.0,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF1F4434),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 5),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _confirmObscured = !_confirmObscured;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            _confirmObscured
                                ? CupertinoIcons.eye_fill
                                : CupertinoIcons.eye_slash_fill,
                            color: Color(0xFF1F4434),
                            size: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password is required';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _validateAndSendOTP();
                      // registerUser();
                      // if (_formKey.currentState!.validate()) {

                      //         // Access the entered values using controllers
                      //         final username = usernameController.text;
                      //          final email= emailController.text;
                      //         final password = passwordController.text;
                      //         final ConfirmPassword=confirmpasswordController;

                      //       }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, minimumSize: Size(200, 80), backgroundColor: Color(0xFF09C7BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: Center(
                  child: Text(
                    "By tap Register button you accept terms and privacy this app",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF505050),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  String _generateOTP() {
    // Generate a 6-digit OTP
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  OTPVerificationScreen({required this.email, required this.otpCode});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late String enteredOTP;

  @override
  void initState() {
    super.initState();
    enteredOTP = '';
  }

  void _submitOTP() {
    if (enteredOTP == widget.otpCode) {
      // If OTP is verified, save user data to the database
      _saveUserDataToDatabase();
    } else {
      _showSnackBar('Invalid OTP. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _saveUserDataToDatabase() {
    // Replace with your logic to save user data to the database
    print('Saving user data to the database for ${widget.email}');
    // After saving, you might navigate to another screen or perform additional actions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OTP has been sent to ${widget.email}',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  enteredOTP = value;
                });
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _submitOTP();
              },
              child: Text('Submit OTP'),
            ),
          ],
        ),
      ),
    );
  }
}