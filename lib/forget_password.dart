// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:picnicpalfinal/verification.dart';
import 'package:email_otp/email_otp.dart';

class forget_password extends StatelessWidget {
  TextEditingController email = TextEditingController();
  EmailOTP myauth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 40, right: 40),
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Image.asset("assets/Logo.png"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Forget Password",
                      style: TextStyle(
                        color: Color(0xFF1F4434),
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter your Email to get the Code to Reset your Password",
                      style: TextStyle(
                        color: Color(0xFF505050),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (email.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter your email")),
                      );
                    } else {
                      // Show a loading indicator while sending OTP
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Sending OTP...")),
                      );

                      myauth.setConfig(
                        appEmail: "me@rohitchouhan.com",
                        appName: "Email OTP",
                        userEmail: email.text,
                        otpLength: 6,
                        otpType: OTPType.digitsOnly,
                      );

                      final isOTPsent = await myauth.sendOTP();
                      if (isOTPsent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("OTP has been sent")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Oops, OTP send failed")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF09C7BE), minimumSize: Size(200, 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Send",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
