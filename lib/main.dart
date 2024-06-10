import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/api/notification.dart';
import 'package:picnicpalfinal/auth.dart';
import 'package:picnicpalfinal/backup/Home.dart';
import 'package:picnicpalfinal/chatscreen.dart';
import 'package:picnicpalfinal/firebase_options.dart';
import 'package:picnicpalfinal/image.dart';
import 'package:picnicpalfinal/splash_screen.dart';
import 'package:provider/provider.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
 await firebaseapi().initialize();
  runApp(

    
    MyApp()
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(), // Navigate to the LoginPage initially
      
      // other configurations...
    );
  }
}

