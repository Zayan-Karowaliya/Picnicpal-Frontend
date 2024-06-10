import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Vehiclelist extends StatefulWidget {
  const Vehiclelist({super.key});

  @override
  State<Vehiclelist> createState() => _VehiclelistState();
}

class _VehiclelistState extends State<Vehiclelist> {
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
            "Vehicles For You",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F4434),
            ),
          ),
        ],
      ),
      SizedBox(height: 10), // Add some space between the text and the additional message
      Text(
        "Tap to choose the vehicle or click Next",
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F4434),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          // Navigate to the next page when the button is clicked
          // Replace `NextPage()` with the actual page you want to navigate to
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => checklist()),
          );
        },
        child: Text("Next"),
      ),
    ],
  ),
),
          Expanded(
            child:
                 showvehicle()
             
          ),
        ],
      ),
     
         
        )
        );
  }


}

class showvehicle extends StatefulWidget {
  const showvehicle({super.key});

  @override
  State<showvehicle> createState() => _showvehicleState();
}

class _showvehicleState extends State<showvehicle> {
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
final Dio dio = Dio();
 Future<void> fetchAllVehicles() async {
    try {
     var response = await dio.get(
            '${ApiUrls.baseUrl}/getallvehicle');

      if (response.statusCode == 200) {
        setState(() {
          showvehiclelist = List<Map<String, dynamic>>.from(
            response.data['vehicles'],
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
  Future<void> saveVehicle(String vehicleId) async {
  try {
    var response = await dio.post(
      '${ApiUrls.baseUrl}/savevehicle/$vehicleId',
      data: {
        'token': token,
      },
    );

    if (response.statusCode == 200) {
      // Vehicle saved successfully, do something if needed
      print('Vehicle saved successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => checklist()), // Assuming checklist() is a widget
      );
    }
  } on DioError catch (dioError) {
    if (dioError.response != null) {
      // Dio error with a response from the server
      if (dioError.response?.statusCode == 400) {
        // Handle vehicle already saved case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehicle already saved')),
        );
          Navigator.pop(context);
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save vehicle')),
        );
        print('Failed to save vehicle. Status code: ${dioError.response?.statusCode}');
      }
    } else {
      // Dio error without a response from the server (e.g., network error)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving vehicle: ${dioError.message}')),
      );
      print('Error saving vehicle: ${dioError.message}');
    }
  } catch (error) {
    // Handle any other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $error')),
    );
    print('Unexpected error: $error');
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
              child: ListView.builder(
                itemCount: showvehiclelist.length,
                itemBuilder: (context, index) {
                  final place = showvehiclelist[index];

                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Save Vehicle?"),
                           content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Do you want to save this vehicle?",
      ),
      SizedBox(height: 10), // Add some spacing
      
    ],
  ),
                            
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Close the dialog without saving
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  saveVehicle(place['_id']);  // Save the vehicle and navigate to the next page
                               
                                },
                                child: Text("Save"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.fromLTRB(
                        5,
                        30,
                        5,
                        30,
                      ),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                ' ${place['type'].toUpperCase()}',
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
                                    'Number Plate: ${place['numberPlate']}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                    'Drivers Name:  ${place['drivername']}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                    'Drivers Contact No:  ${place['driverContact']}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                    'Number Of Seats:  ${place['numberofseats']}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
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
                                            // Add some spacing between icons
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     // _deletePlace(context, place.id);
                                            //   },
                                            //   child: Icon(
                                            //     CupertinoIcons.pencil,
                                            //     size: 30,
                                            //     color: Color(0xFF09C7BE),
                                            //   ),
                                            // ),
                                            // Add some spacing between icons
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
  }
   
