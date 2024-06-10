import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class savedvehicle extends StatefulWidget {
  const savedvehicle({super.key});

  @override
  State<savedvehicle> createState() => _savedvehicleState();
}

class _savedvehicleState extends State<savedvehicle> {
  late String username = '';
  late String email = '';

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "My Vehicle List ",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F4434),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 10), // Add some space between the text and the additional message
                    // Text(
                    //   "Tap to choose the vehicle or click Next",
                    //   style: TextStyle(
                    //     fontFamily: "Poppins",
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w500,
                    //     color: Color(0xFF1F4434),
                    //   ),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Navigate to the next page when the button is clicked
                    //     // Replace `NextPage()` with the actual page you want to navigate to
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(builder: (context) => checklist()),
                    //     );
                    //   },
                    //   child: Text("Next"),
                    // ),
                  ],
                ),
              ),
              Expanded(child: myvehcile()),
            ],
          ),
        ));
  }
}

class myvehcile extends StatefulWidget {
  const myvehcile({super.key});

  @override
  State<myvehcile> createState() => _myvehcileState();
}

class _myvehcileState extends State<myvehcile> {
  List<Map<String, dynamic>> showvehiclelist = [];
  late String token;
  @override
  void initState() {
    super.initState();
    // Fetch vehicles when the widget is initialized
    _loadToken();
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
      print('Token: $token');
      fetchAllVehicles(); // Call _loadChecklistItems after setting the token
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }
Future<void> _deleteVehicle(String vehicleId) async {
  try {
    var response = await dio.delete('${ApiUrls.baseUrl}/deletevehicle/$vehicleId',  
    data: {
        'token': token,
      });
;
    if (response.statusCode == 200) {
      // Vehicle deleted successfully
      // Reload the list of vehicles
      fetchAllVehicles();
    } else {
      // Handle error
      print('Failed to delete vehicle');
    }
  } catch (error) {
    // Handle error
    print('Error deleting vehicle: $error');
  }
}
  final Dio dio = Dio();
  Future<void> fetchAllVehicles() async {
  try {
    var response = await dio.post('${ApiUrls.baseUrl}/getmyvehicle', 
      data: {
        'token': token,
      });

    if (response.statusCode == 200) {
         if (response.statusCode == 200) {
  print('Received data: ${response.data}');
   if (response.data is List) {
        setState(() {
          showvehiclelist = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        print('Received data is not in the expected format');
      }
}
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
          child: showvehiclelist.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: showvehiclelist.length,
                  itemBuilder: (context, index) {
                    final vehicleWrapper = showvehiclelist[index];
                    final vehicle = vehicleWrapper['myvehicles'][0];
                    print('Vehicle data: $vehicle');
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.fromLTRB(5, 30, 5, 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Color(0xFFffffff),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFebe6e6),
                            blurRadius: 5,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          vehicle['type'] ?? 'Type not available',
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F4434),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              'Number Plate: ${vehicle['numberPlate'] ?? 'Not available'}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                            Text(
                              'Driver\'s Name:  ${vehicle['drivername'] ?? 'Not available'}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                           
                            Text(
                              'Number Of Seats:  ${vehicle['numberofseats'] ?? 'Not available'}',
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                             GestureDetector(
                              onTap: () {
                                _launchCaller(vehicle['driverContact'] ?? '');
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Driver\'s Contact No: ${vehicle['driverContact'] ?? 'Not available'}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),

                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _showDeleteConfirmationDialog(vehicle['_id']);
                                        },
                                        child: Icon(
                                          CupertinoIcons.delete,
                                          size: 30,
                                          color: Color(0xFF09C7BE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
  void _showDeleteConfirmationDialog(String vehicleId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Vehicle?"),
        content: Text("Are you sure you want to delete this vehicle?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _deleteVehicle(vehicleId); // Delete the vehicle
            },
            child: Text("Delete"),
          ),
        ],
      );
    },
  );
}
void _launchCaller(String phoneNumber) async {
  final url = 'tel:$phoneNumber';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
}

