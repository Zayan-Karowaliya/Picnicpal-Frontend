import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';

class AuthProvider extends ChangeNotifier {
  String? _authToken;
  String? _userId;
  String? get authToken => _authToken;
  String? get userid => _userId;
Future<String?> login(String username, String password) async {
try {
      
      final dio = Dio();

      // Make a POST request with the username and password in the request body
     final response = await dio.post(
        '${ApiUrls.baseUrl}/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      // Check if the response contains the token
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data.containsKey('token') && data.containsKey('id')) {
          String authToken = data['token'];
          String userid=data['id'];
         print('User ID: $userid');
         print('User ID: $authToken');

        // Notify listeners of the change
        notifyListeners();
        
      } else {
        // Handle authentication failure, e.g., show an error message
        print('Authentication failed');
      }
      }
    } catch (error) {
      // Handle any network or other errors
      print('Error during authentication: $error');
    }
    

    notifyListeners();
    return null;
  }

  void logout() {
    // TODO: Implement your logout logic
    _authToken = null;
    notifyListeners();
  }
}

