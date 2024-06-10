import 'package:flutter/material.dart';
import 'package:picnicpalfinal/auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class test extends StatefulWidget {


  const test({super.key});

  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
 late String token;
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
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

  @override
  
  Widget build(BuildContext context) {
final authToken = Provider.of<AuthProvider>(context);

       return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('Token: $token'),
      ),
    );
  }
}