import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/backup/Home.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/UpdateScreen.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String username;
  final String email;
  final int age;
  final String gender;
  final String data;

  UserProfile({
    required this.username,
    required this.email,
    required this.age,
    required this.gender,
    required this.data,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      email: json['email'],
      age: json['age'],
      gender: json['gender'],
      data: json['data'],
    );
  }
}

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  late String token;
  late UserProfile _userProfile;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  late String username = '';
  late String email = ' ';
late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _preferenceController;

  @override
  void initState() {
    super.initState();
    _loadToken();
    _fetchUserProfile();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _ageController = TextEditingController();
    _genderController = TextEditingController();
    _preferenceController = TextEditingController();
     
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
        _fetchUserProfile();
      });
    } else {
      print('Token not found');
    }
  }


  File? _image;
  late Dio dio = Dio();

  Future<void> _fetchUserProfile() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/getalluser',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        setState(() {
          _userProfile = UserProfile(
            username: responseData['username'] ?? '',
            email: responseData['email'] ?? '',
            age: responseData['age'] ?? 0,
            gender: responseData['gender'] ?? '',
            data: responseData['data'] ?? '',
          );
          _usernameController.text = _userProfile.username;
        _emailController.text = _userProfile.email;
        _ageController.text = _userProfile.age.toString();
        _genderController.text = _userProfile.gender;
        _preferenceController.text = _userProfile.data;
        });
      } else {
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }





   Future<void> _updateUserProfile() async {
  try {
    if (_emailController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _preferenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final int? age = int.tryParse(_ageController.text);
    if (age == null || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid age less than or equal to 100.')),
      );
      return;
    }

    final Dio dio = Dio();
    final Map<String, dynamic> updateData = {
      'email': _emailController.text,
      'age': age,
      'gender': _genderController.text,
      'preference': _preferenceController.text,
      'token': token,
    };

    final Response response = await dio.post(
      '${ApiUrls.baseUrl}/updateuser',
      data: updateData,
    );

    if (response.statusCode == 200) {
      setState(() {
        _userProfile = UserProfile(
          username: _usernameController.text,
          email: _emailController.text,
          age: age,
          gender: _genderController.text,
          data: _preferenceController.text,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile. Please try again.')),
      );
    }
  } catch (error) {
    print('Error updating user profile: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred. Please try again.')),
    );
  }
}

  Future<void> _showEditDialog() async {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildEditField('Email', _emailController),
                _buildEditField('Age', _ageController, isNumber: true),
                _buildEditField('Gender', _genderController),
                _buildEditField('Preference', _preferenceController),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateUserProfile();
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newpasswordController = TextEditingController();
  Future<void> _updatepasswordDialog() async {
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildPasswordField('Old password', oldPasswordController, _isOldPasswordVisible, (bool value) {
                    setState(() {
                      _isOldPasswordVisible = value;
                    });
                  }),
                  _buildPasswordField('New Password', newpasswordController, _isNewPasswordVisible, (bool value) {
                    setState(() {
                      _isNewPasswordVisible = value;
                    });
                  }),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _updatePassword();
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
Widget _buildPasswordField(String label, TextEditingController controller, bool isPasswordVisible, Function(bool) setState) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(!isPasswordVisible);
              },
              child: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

 Widget _buildEditField(String label, TextEditingController controller, {bool isNumber = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (isNumber) {
              final intValue = int.tryParse(value);
              if (intValue == null) {
                return 'Please enter a valid number for $label';
              }
              if (intValue > 100) {
                return 'Age cannot be greater than 100';
              }
            }
            return null;
          },
        ),
      ],
    ),
  );
}

  Future<void> _updatePassword() async {
    try {
      Dio dio = Dio();

      // Prepare the data to be sent to the backend
      final Map<String, dynamic> passwordData = {
        'oldPassword': oldPasswordController.text,
        'password': newpasswordController.text,
        "token":token
      };

      // Make a Dio request to update the user's password
      final Response response = await dio.post(
        '${ApiUrls.baseUrl}/updatepass',
        data: passwordData,
        
      );

      // Check if the update was successful (you may need to adjust the condition based on your API response)
      if (response.statusCode == 200) {
        // Show a success message (you can customize this part based on your UI)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password updated successfully!'),
          ),
        );
      } else {
        // Handle error scenarios (you can customize this part based on your UI)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password. Please try again.'),
          ),
        );
      }
    } 
     on DioError catch (e) {
    if (e.response!.statusCode == 400) {
      // Handle 401 Unauthorized error (incorrect credentials)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('old password is not correct ${e.response!.statusCode}'),
      ));
    } else {
      // Handle other Dio errors
      print('Dio Error: $e');
     }
     }catch (error) {
      print('Error updating password: $error');
    }
    
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      drawer: drawer(
        username: username,
        email: email,
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        },
      ),
     body: SingleChildScrollView(
  child: Column(
    children: [
      Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 40, 0, 0),
          child: GestureDetector(
            onTap: () {
              _globalKey.currentState?.openDrawer();
            },
            child: Icon(
              CupertinoIcons.bars,
              size: 50,
              color: Color(0xFF09C7BE),
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(26, 0, 0, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "My Profile",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F4434),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _userProfile != null
              ? SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      _buildField('Username', _userProfile.username),
                      _buildField('Email', _userProfile.email),
                      _buildField('Age', _userProfile.age.toString()),
                      _buildField('Gender', _userProfile.gender),
                      _buildField('Preference', _userProfile.data),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showEditDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434), minimumSize: Size(200, 80),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10), // Add spacing between buttons
                      ElevatedButton(
                        onPressed: () {
                        _updatepasswordDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, minimumSize: Size(200, 80), backgroundColor: Color(0xFF1F4434),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    ],
  ),
),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            value.isNotEmpty ? value : 'Value not set',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
