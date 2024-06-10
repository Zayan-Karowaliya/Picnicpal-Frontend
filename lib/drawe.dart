import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/adminhome.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/eventcreate.dart';
import 'package:picnicpalfinal/myevents.dart';
import 'package:picnicpalfinal/nearbyReas.dart';
import 'package:picnicpalfinal/nearbynew.dart';
import 'package:picnicpalfinal/profile.dart';
import 'package:picnicpalfinal/savedvehicle.dart';
import 'package:picnicpalfinal/vehicles.dart';
import 'package:picnicpalfinal/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';

class drawer extends StatefulWidget {
   final Function() onLogout;
  const drawer({required this.onLogout, super.key, required String username, required String email});

  @override
  State<drawer> createState() => _drawerState();
}

class _drawerState extends State<drawer> {
   late String token;
      late String username='';
  late String email=' ' ;
  

   
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
        _loadUserProfile();
      });
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
 TextEditingController newNameController = TextEditingController();
 final Dio dio = Dio();

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
      return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 80, 30, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
               
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username.toUpperCase(),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F4434),
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFc7c7c7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.house,
                      size: 32,
                      color: Color(0xFF292929),
                    ),
                    title: Text(
                      'Home',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F4434),
                      ),
                    ),
                    onTap: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Homescreen()),
                        );
                    },
                  ),
                   SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.calendar,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'Saved Events',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => myevents(authToken: token)),
                        ); // Close the drawer
                        // Close the drawer
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.envelope,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'My Events',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                           Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => eventcreated()),
                        ); // Close the drawer
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.person_crop_circle,
                        size: 32,
                        color: Color(0xFF292929),
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF292929),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => profile()),
                        ); 
                      // Close the drawer
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(
                       Icons.check_box,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'My Checklist',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => checklist()),
                        ); // Close the drawer
                     
                      },
                    ),
                     SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.car_rental_rounded,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'Vehciles List',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Vehiclelist()),
                        ); // Close the drawer
                     
                      },
                    ),
                     ListTile(
                      leading: Icon(
                        Icons.car_rental,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'My Vehciles',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => savedvehicle()),
                        ); // Close the drawer
                     
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                      ListTile(
                      leading: Icon(
                       Icons.food_bank,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'Nearby Reastarents',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => nearbyreas()),
                        ); // Close the drawer
                     
                      },
                    ),
                     SizedBox(
                      height: 10,
                    ),
                      ListTile(
                      leading: Icon(
                        Icons.cloud,
                        color: Color(0xFF292929),
                        size: 32,
                      ),
                      title: Text(
                        'weather',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F4434),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => weather()),
                        ); // Close the drawer
                     
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                 
                  // Add more drawer items here...
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.square_arrow_left,
                      size: 32,
                      color: Color(0xFFdb0202),
                    ),
                    title: Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF292929),
                      ),
                    ),
                    onTap: () {
                    widget.onLogout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
//     return Scaffold(
// drawer: Drawer(
//         child: Column(
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.fromLTRB(0, 80, 30, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.asset(
//                       'assets/Profile.jpg', // Replace with your image URL
//                       width: 60,
//                       height: 70,
//                       fit: BoxFit.fill,
//                     ),
//                   ),
//                   SizedBox(width: 10), // Add some space between image and text
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         username.toUpperCase(),
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1F4434),
//                         ),
//                       ),
//                       Text(
//                         email,
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 14,
//                           fontWeight: FontWeight.w400,
//                           color: Color(0xFFc7c7c7),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 80, horizontal: 30),
//                 child: ListView(
//                   children: <Widget>[
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.house,
//                         size: 32,
//                         color: Color(0xFF292929),
//                       ),
//                       title: Text(
//                         'Home',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF1F4434),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);  // Close the drawer
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.calendar,
//                         color: Color(0xFF292929),
//                         size: 32,
//                       ),
//                       title: Text(
                        
//                         'My Events',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF1F4434),
//                         ),
                        
//                       ),
//                       onTap: () {
                         
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => myevents(authToken: token)),
//                         ); // Close the drawer
//                    // Close the drawer
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.envelope,
//                         color: Color(0xFF292929),
//                         size: 32,
//                       ),
//                       title: Text(
//                         'Messages',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF1F4434),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context); // Close the drawer
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.person_crop_circle,
//                         size: 32,
//                         color: Color(0xFF292929),
//                       ),
//                       title: Text(
//                         'Profile',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF292929),
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.pop(context); // Close the drawer
//                       },
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.calendar,
//                         color: Color(0xFF292929),
//                         size: 32,
//                       ),
//                       title: Text(
                        
//                         'My Events',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF1F4434),
//                         ),
                        
//                       ),
//                       onTap: () {
                         
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => checklist()),
//                         ); // Close the drawer
//                    // Close the drawer
//                       },
//                     ),
//                     SizedBox(
//                       height: 40,
//                     ),
//                     ListTile(
//                       leading: Icon(
//                         CupertinoIcons.square_arrow_left,
//                         size: 32,
//                         color: Color(0xFFdb0202),
//                       ),
//                       title: Text(
//                         'Logout',
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF292929),
//                         ),
//                       ),
//                       onTap: () async {
//                         final prefs = await SharedPreferences.getInstance();
//                   await prefs.remove('token');
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => Login()),
//                   );
//                         // Navigator.pop(context); // Close the drawer
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
  }
}