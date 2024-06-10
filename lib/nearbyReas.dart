import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:picnicpalfinal/nearbynew.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:io' show Platform;

class nearbyreas extends StatefulWidget {
  const nearbyreas({super.key});

  @override
  State<nearbyreas> createState() => _nearbyreasState();
}

class _nearbyreasState extends State<nearbyreas> {
   late String token;
   late String username = '';
  late String email = '';
  List<Map<String, dynamic>> savedEvents = [];
  final Dio dio = Dio();
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
Map<String, int> unreadMessageCounts = {};
  List<Map<String, dynamic>> _restaurants = [];
  @override
  void initState() {
    super.initState();
 _loadToken();
    
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false, // This makes sure to remove all previous routes
    );
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
   getSavedPlaces(); // Call _loadChecklistItems after setting the token
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }
  Future<void> getSavedPlaces() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/getsaveevent',
        data: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          savedEvents = List<Map<String, dynamic>>.from(
            response.data['savedEvents'],
          );
        });
      } else {
        // Handle error, show a snackbar, or display an error message
        print('Failed to load saved places');
      }
    } catch (error) {
      // Handle error, show a snackbar, or display an error message
      print('Error getting saved places: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
      return WillPopScope(
      onWillPop: () async {
        // Handle back button press here
        return false; // Returning false will prevent the back operation
      },
    child: Scaffold(
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
      body: Column(
        children: <Widget>[
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
                  "Nearby Restaurents",
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
          Expanded(
            child: savedEvents.isEmpty
                ? _buildEmptyChecklist()
                : _buildChecklist(),
          ),
        ],
      ),
     
         
        )
        );
  }
Widget _buildChecklist() {
  return Scaffold(
    body: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(26, 0, 0, 10),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              itemCount: savedEvents.length,
              itemBuilder: (context, index) {
                final place = savedEvents[index];

               
                return GestureDetector( // Add GestureDetector here
                 onTap: () {
    // Navigate to the chat screen with event-specific information when the event is tapped
 Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NearbyRestaurantsScreen(
          latitude: place['latitude'], // Pass latitude of the place
          longitude: place['longitutde'], // Pass longitude of the place
        ),
      ),
 );
                    // Handle onTap event
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.fromLTRB(
                      5,
                      30,
                      5,
                      30,
                    ),
                    // Adjust vertical margin as needed
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Color(0xFFffffff),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFebe6e6),
                          blurRadius: 5,
                          offset: Offset(0, 4), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              ' ${place['NameOfPlace']}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F4434),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                                Text(
                                   ' ${place['location']}',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              
                                SizedBox(height: 8),
                                
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    ),
  );
}

Widget _buildEmptyChecklist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No places found.'),
          SizedBox(height: 16.0),
 
        ],
      ),
    );  
  }
}
