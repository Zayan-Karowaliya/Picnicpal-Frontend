import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class userget extends StatefulWidget {
  const userget({super.key});

  @override
  State<userget> createState() => _usergetState();
}

class _usergetState extends State<userget> {
  late String token;
  late String username='' ;
  late String email=' ' ;

  @override
  void initState() {
    super.initState();
    _loadToken();
    
  }
  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
     _loadUserProfile();
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

   Future<void> _loadUserProfile() async {
    try {
      final response = await Dio().post(
        '${ApiUrls.baseUrl}/singleuser',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        final userData = response.data;

        setState(() {
          username = userData['username'];
          email = userData['email'];
        });
      } else {
        // Handle error (e.g., navigate to login page)
        print('Failed to fetch user profile');
      }
    } catch (error) {
      // Handle error (e.g., navigate to login page)
      print('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(username),
          Text(email),
          Text(token)
        ],
      ),
    );
  }
}