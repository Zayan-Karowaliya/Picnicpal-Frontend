// import necessary packages
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
// import 'package:email_auth/email_auth.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:dio/dio.dart';
import 'package:picnicpalfinal/apiclass.dart';
class verification extends StatefulWidget {
  final String email;
  final String username;
  final String password;
  final EmailOTP myAuth;
verification({required this.email,required this.username, required this.password, required this.myAuth});

  @override
_VerificationScreenState createState() => _VerificationScreenState();

}
class _VerificationScreenState extends State <verification> {
TextEditingController email = new TextEditingController();
  TextEditingController otp = new TextEditingController();
  
  bool proceedWithSaving = false;
  void _saveDataToDatabase() async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        '${ApiUrls.baseUrl}/register', // Replace with your actual server URL
        data: {
          'username': widget.username,
          'email': widget.email,
          'password': widget.password,
        },
      );

      if (response.statusCode == 200) {

         Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
        print('User registered successfully');
        // Add any additional logic after successful registration
      } else {
        print('Failed to register user. Status code: ${response.statusCode}');
        // Handle registration failure
      }
    } catch (e) {
      print('Error: $e');
      // Handle other errors
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(40),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: 300,
                  height: 200,
                  child: Image.asset("assets/Logo.png"),
                ),
                SizedBox(height: 20),
                Text(
                  "Enter 4 Digit Code",
                  style: TextStyle(
                    color: Color(0xFF1F4434),
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                 
                Text(
                  "Enter the 4-digit code that you received on your email.",
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
               Container(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextFormField(
            controller: otp,
            decoration: InputDecoration(
              labelText: "OTP Code",
            ),
          ),
        ],
      ),
    ),
                SizedBox(height: 30),
                   
                ElevatedButton(
                        onPressed: () async {
                         bool OTP_results = await widget.myAuth.verifyOTP(otp: otp.text);
                          if (OTP_results==true) {
                              _saveDataToDatabase();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("OTP is verified"),
                            ));
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Invalid OTP"),
                            ));
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF09C7BE), minimumSize: Size(200, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

         
                      //   onPressed: () 
                      //   async {
                      //  _saveDataToDatabase();
                      //     myauth.setConfig(
                      //       appEmail: "karowaliyazayan@gmail.com",
                      //       appName: "Email OTP",
                      //       userEmail: widget.email,
                      //       otpLength: 6,
                      //       otpType: OTPType.digitsOnly
                      //     );
                      //     if (await myauth.sendOTP() == true) {
                      //       ScaffoldMessenger.of(context)
                      //           .showSnackBar(const SnackBar(
                      //         content: Text("OTP has been sent"),
                      //       ));
                      //     } else {
                      //       ScaffoldMessenger.of(context)
                      //           .showSnackBar(const SnackBar(
                      //         content: Text("Oops, OTP send failed"),
                      //       ));
                      //     }
                      //   },
                      //   child: const Text("Send OTP")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Verification Screen'),
  //     ),
  //     body: Center(
  //       child: Text('Verification for $email'),
  //     ),
  //   );
  // }

