// // // ignore_for_file: prefer_const_constructors



// // import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:untitled1/HomePagefinal.dart';
// import 'package:untitled1/myevents.dart';
// // import 'package:dio/dio.dart';
// // import 'package:untitled1/Login.dart';
// // import 'package:untitled1/joinplaces.dart';
// // import 'package:untitled1/updatescreen.dart';

// // class Place {
// //  final String id;
// //   String name;
// //   String description;
// //   int numberOfPeople;

// //     Place({
// //     required this.id,
// //     required this.name,
// //     required this.description,
// //     required this.numberOfPeople,
// //   });

// //  factory Place.fromJson(Map<String, dynamic> json) {
// //     return Place(
// //       id: json['_id'].toString(),
// //       name: json['NameOfPlace'],
// //       description: json['Description'],
// //       numberOfPeople: json['NumberOfPeople'],
// //     );
// //   }
// // }

// // class UpdatePlaceScreen extends StatelessWidget {
//     GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
//     final String authToken='';
//   //  UpdatePlaceScreen({super.key, required this.authToken});
      
// //  TextEditingController newNameController = TextEditingController();
// //  final Dio dio = Dio();

// //    Future<List<Place>> fetchItems() async {
// //     try {
// //       final response = await dio.get('http://192.168.1.106:3000/getall'); // Replace with your actual API endpoint

// //         if (response.statusCode == 200) {
// //         final List<dynamic> data = response.data;
// //         return data.map((item) => Place.fromJson(item)).toList();
// //       } else {
// //         throw Exception('Failed to fetch places');
// //       }
// //     } catch (error) {
// //       throw Exception('An error occurred: $error');
// //     }
// //   }
  
//   // @override
  
//   // Widget build(BuildContext context) {
     
// //  return Scaffold(
//    return Scaffold(
//       key: _globalKey,
//       drawer: Drawer(
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
//                         "Alex Wright",
//                         style: TextStyle(
//                           fontFamily: "Poppins",
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1F4434),
//                         ),
//                       ),
//                       Text(
//                         "Your Description",
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
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => HomeScreen(authToken: this.authToken,)),
//                         ); // Close the drawer
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
//                           MaterialPageRoute(builder: (context) => myevents(authToken: this.authToken,)),
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
//                       onTap: () {
//                         Navigator.pop(context); // Close the drawer
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//   );
//   }

// //   appBar: AppBar(
// //         // title: Text('User ID: $userId'),
// //       ),
// //   body: FutureBuilder<List<Place>>(
// //     future: fetchItems(),
// //     builder: (context, snapshot) {
// //       if (snapshot.connectionState == ConnectionState.waiting) {
// //         return Center(child: CircularProgressIndicator()); 
// //       } else if (snapshot.hasError) {
// //         return Center(child: Text('Error: ${snapshot.error}'));
// //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //         return Center(child: Text('No places available.'));
// //       } else {
// //         return Column(
// //           children: <Widget>[
// //             Padding(
// //               padding: EdgeInsets.fromLTRB(35, 65, 35, 0),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: <Widget>[
// //                   Text(
// //                     "Home",
// //                     style: TextStyle(
// //                       fontFamily: "Poppins",
// //                       fontSize: 26,
// //                       fontWeight: FontWeight.w600,
// //                       color: Color(0xFF1F4434),
// //                     ),
// //                   ),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       border: Border.all(
// //                         color: Color(0xffE7E7EE), // Border color
// //                         width: 1.5, // Border width
// //                       ),
// //                       borderRadius:
// //                           BorderRadius.circular(8), // Border radius to make it circular
// //                     ),
// //                     child: Icon(
// //                       CupertinoIcons.bars,
// //                       color: Color(0xFF09C7BE),
// //                       size: 60,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Padding(
// //               padding: EdgeInsets.fromLTRB(26, 26, 26, 0),
// //               child: Container(
// //                 padding: EdgeInsets.fromLTRB(25, 12, 25, 12),
// //                 decoration: BoxDecoration(
// //                   color: Color(0xffE7E7EE),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: TextField(
// //                   decoration: InputDecoration(
// //                     hintText: 'Search here',
// //                     hintStyle: TextStyle(
// //                       fontFamily: "Poppins",
// //                       fontWeight: FontWeight.w600,
// //                       color: Color(0xff6B6B6B),
// //                       fontSize: 16,
// //                     ),
// //                     border: InputBorder.none,
// //                     suffixIcon: Icon(
// //                       CupertinoIcons.search,
// //                       color: Color(0xffA3A3A3),
// //                       size: 25,
// //                     ),
// //                   ),
// //                   cursorColor: Colors.black,
// //                 ),
// //               ),
// //             ),
// //             SizedBox(
// //               height: 20,
// //             ),
// //             Expanded(
// //               child: Container(
// //                 padding: EdgeInsets.all(25),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(30),
// //                     topRight: Radius.circular(30),
// //                   ),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: <Widget>[
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: <Widget>[
// //                         Text(
// //                           "For You",
// //                           style: TextStyle(
// //                             fontFamily: "Poppins",
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.w600,
// //                             color: Color(0xFF1F4434),
// //                           ),
// //                         ),
// //                         Icon(
// //                           CupertinoIcons.square_grid_2x2,
// //                           color: Color(0xFF09C7BE),
// //                           size: 40,
// //                         ),
// //                       ],
// //                     ),
// //                     SizedBox(
// //                       height: 15,
// //                     ),
// //                     Expanded(
// //                       child: ListView.builder(
// //                         itemCount: snapshot.data!.length,
// //                         itemBuilder: (context, index) {
// //                           final place = snapshot.data![index];
// //                           return GestureDetector(
// //                             onTap: () {
// //                               // Handle the tap, e.g., navigate to a detailed view
// //     //                           Navigator.push(
// //     //   context,
// //     //   MaterialPageRoute(
// //     //     builder: (context) => joinplaces(place: place,)
// //     //   ),
// //     // );
// //                             },
// //                             child: Card(
// //                               elevation: 5,
// //                               margin: EdgeInsets.all(10),
// //                               child: Padding(
// //                                 padding: const EdgeInsets.all(16.0),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Text(
// //                                       ' ${place.name}',
// //                                       style: TextStyle(
// //                                         fontSize: 18,
// //                                         fontWeight: FontWeight.bold,
// //                                       ),
// //                                     ),
// //                                     SizedBox(height: 8),
// //                                     Text(
// //                                       ' ${place.description}',
// //                                       style: TextStyle(
// //                                         fontSize: 16,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       }
// //     },
// //   ),
// // );
// //   }
// //   }
//   // return Scaffold(
//   //     key: _globalKey,
//   //     drawer: Drawer(
//   //       child: Column(
//   //         children: <Widget>[
//   //           Container(
//   //             padding: EdgeInsets.fromLTRB(0, 80, 30, 0),
//   //             child: Row(
//   //               mainAxisAlignment: MainAxisAlignment.center,
//   //               children: <Widget>[
//   //                 ClipRRect(
//   //                   borderRadius: BorderRadius.circular(15),
//   //                   child: Image.asset(
//   //                     'assets/Profile.jpg', // Replace with your image URL
//   //                     width: 60,
//   //                     height: 70,
//   //                     fit: BoxFit.fill,
//   //                   ),
//   //                 ),
//   //                 SizedBox(width: 10), // Add some space between image and text
//   //                 Column(
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     Text(
//   //                       "Alex Wright",
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w600,
//   //                         color: Color(0xFF1F4434),
//   //                       ),
//   //                     ),
//   //                     Text(
//   //                       "Your Description",
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 14,
//   //                         fontWeight: FontWeight.w400,
//   //                         color: Color(0xFFc7c7c7),
//   //                       ),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           Expanded(
//   //             child: Padding(
//   //               padding: EdgeInsets.symmetric(vertical: 80, horizontal: 30),
//   //               child: ListView(
//   //                 children: <Widget>[
//   //                   ListTile(
//   //                     leading: Icon(
//   //                       CupertinoIcons.house,
//   //                       size: 32,
//   //                       color: Color(0xFF292929),
//   //                     ),
//   //                     title: Text(
//   //                       'Home',
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w500,
//   //                         color: Color(0xFF1F4434),
//   //                       ),
//   //                     ),
//   //                     onTap: () {
//   //                       Navigator.push(
//   //                         context,
//   //                         MaterialPageRoute(builder: (context) => HomeScreen(authToken: this.authToken,)),
//   //                       ); // Close the drawer
//   //                     },
//   //                   ),
//   //                   SizedBox(
//   //                     height: 10,
//   //                   ),
//   //                   ListTile(
//   //                     leading: Icon(
//   //                       CupertinoIcons.calendar,
//   //                       color: Color(0xFF292929),
//   //                       size: 32,
//   //                     ),
//   //                     title: Text(
                        
//   //                       'My Events',
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w500,
//   //                         color: Color(0xFF1F4434),
//   //                       ),
                        
//   //                     ),
//   //                     onTap: () {
                         
//   //                       Navigator.push(
//   //                         context,
//   //                         MaterialPageRoute(builder: (context) => myevents(authToken: this.authToken,)),
//   //                       ); // Close the drawer
//   //                  // Close the drawer
//   //                     },
//   //                   ),
//   //                   SizedBox(
//   //                     height: 10,
//   //                   ),
//   //                   ListTile(
//   //                     leading: Icon(
//   //                       CupertinoIcons.envelope,
//   //                       color: Color(0xFF292929),
//   //                       size: 32,
//   //                     ),
//   //                     title: Text(
//   //                       'Messages',
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w500,
//   //                         color: Color(0xFF1F4434),
//   //                       ),
//   //                     ),
//   //                     onTap: () {
//   //                       Navigator.pop(context); // Close the drawer
//   //                     },
//   //                   ),
//   //                   SizedBox(
//   //                     height: 10,
//   //                   ),
//   //                   ListTile(
//   //                     leading: Icon(
//   //                       CupertinoIcons.person_crop_circle,
//   //                       size: 32,
//   //                       color: Color(0xFF292929),
//   //                     ),
//   //                     title: Text(
//   //                       'Profile',
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w500,
//   //                         color: Color(0xFF292929),
//   //                       ),
//   //                     ),
//   //                     onTap: () {
//   //                       Navigator.pop(context); // Close the drawer
//   //                     },
//   //                   ),
//   //                   SizedBox(
//   //                     height: 40,
//   //                   ),
//   //                   ListTile(
//   //                     leading: Icon(
//   //                       CupertinoIcons.square_arrow_left,
//   //                       size: 32,
//   //                       color: Color(0xFFdb0202),
//   //                     ),
//   //                     title: Text(
//   //                       'Logout',
//   //                       style: TextStyle(
//   //                         fontFamily: "Poppins",
//   //                         fontSize: 20,
//   //                         fontWeight: FontWeight.w500,
//   //                         color: Color(0xFF292929),
//   //                       ),
//   //                     ),
//   //                     onTap: () {
//   //                       Navigator.pop(context); // Close the drawer
//   //                     },
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   // )