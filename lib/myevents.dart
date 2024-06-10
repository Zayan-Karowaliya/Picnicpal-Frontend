import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/backup/Chat.dart';
import 'package:picnicpalfinal/chatscreen.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
class myevents extends StatefulWidget {
  final String authToken;
  const myevents({required this.authToken, super.key});

  @override
  State<myevents> createState() => _myeventsState();
}

class _myeventsState extends State<myevents> {
  late String username = '';
  late String email = '';
  DateTime? selectedGoingTime;
  DateTime? selectedLeavingTime;
  List<Map<String, dynamic>> savedEvents = [];
  final Dio dio = Dio();
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
Map<String, int> unreadMessageCounts = {};
  @override
  void initState() {
    super.initState();
    getSavedPlaces();
  }


Future<void> _selectGoingTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedGoingTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedGoingTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectLeavingTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLeavingTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedLeavingTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }




  Future<void> setEventPreferences(
      String placeId ) async {
    try {
      if (selectedGoingTime == null || selectedLeavingTime == null) {
      // Show an error message or handle the case where times are not selected
      return;
    }

      final response = await dio.post(
        '${ApiUrls.baseUrl}/time/${placeId}',
        data: {
          'token': widget.authToken,
            'goingTime': selectedGoingTime?.toString(), // Convert DateTime to string
        'leavingTime': selectedLeavingTime?.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Successfully set event preferences
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event preferences set successfully.'),
          ),
        );

        Navigator.pop(context); // Close the dialog
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to set event preferences. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      // ... handle Dio errors ...
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  AlertDialog buildUpdateDialog(String placeId) {
    return AlertDialog(
      title: Text("Update Time"),
      content: Text("Choose the time to update:"),
      actions: [
        // Update Going Time Button
        TextButton(
          onPressed: () async {
            await _selectGoingTime(); // Show the dialog to get new going time
            setEventPreferences(placeId);
            Navigator.pop(context); // Close the dialog
          },
          child: Text("Update Going Time"),
        ),
        // Update Leaving Time Button
        TextButton(
          onPressed: () async {
            await _selectLeavingTime(); // Show the dialog to get new leaving time
            setEventPreferences(placeId);
            Navigator.pop(context); // Close the dialog
          },
          child: Text("Update Leaving Time"),
        ),
      ],
    );
  }
    Future<void> _showAddThoughtDialog(String placeId) async {
    TextEditingController thoughtController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Shared Thought"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: thoughtController,
                decoration: InputDecoration(
                  labelText: 'Your Shared Thought',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String thought = thoughtController.text;
                Navigator.pop(context); // Close the dialog
                await shareThought(placeId, thought);
              },
              child: Text("Share"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }


   Future<void> shareThought(String placeId, String thought) async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/sharedthought/$placeId',
        data: {
          'token': widget.authToken,
          'fact': thought,
        },
      );

      if (response.statusCode == 200) {
        // Successfully shared the thought
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared thought successfully.'),
          ),
        );
        // Refresh the saved events list
        getSavedPlaces();
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share thought. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      // ... handle Dio errors ...
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }



  Future<void> getSavedPlaces() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/getsaveevent',
        data: {
          'token': widget.authToken,
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
String composeMessageForEvent(Map<String, dynamic> event) {
    String eventName = event['NameOfPlace'];
    String eventDescription = event['Description'];
    String location = event['location'];
    String goingTime = event['GoingTime'];
    String leavingTime = event['LeavingTime'];

    // Format the going and leaving time
    String formattedGoingTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(goingTime));
    String formattedLeavingTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(leavingTime));

    String message =
        'Check out this event: $eventName, $eventDescription\n'
        'Going Time: $formattedGoingTime\n'
        'Leaving Time: $formattedLeavingTime\n'
        "Location:\n$location\n";

    return message;
  }

  void shareEventOnWhatsApp( event) {
  String eventName = event['NameOfPlace'];
  String eventDescription = event['Description'];
  String location = event['location'];
  String goingTime = event['GoingTime'];
  String leavingTime = event['LeavingTime'];

  // Format the going and leaving time
  String formattedGoingTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(goingTime));
  String formattedLeavingTime = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(leavingTime));

  // Replace 'your_apk_file.apk' with the actual filename of your APK
  String apkFilename = 'app-debug.apk';

  // Construct the local path to your APK


  String message =
      'Check out this event: $eventName, $eventDescription\n'
      'Going Time: $formattedGoingTime\n'
      'Leaving Time: $formattedLeavingTime\n'
      "Location:\n$location\n";
      

  // Use the share function from the share_plus package
 
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
                  "My Events",
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

                  String goingTime = place['GoingTime'] ?? '';
                  String leavingTime = place['LeavingTime'] ?? '';

                  String formattedGoingTime = '';
                  String formattedLeavingTime = '';

                  // Format going time
                  if (goingTime.isNotEmpty) {
                    formattedGoingTime = DateFormat('EEE, MMM d, yyyy - hh:mm a').format(DateTime.parse(goingTime));
                  } else {
                    formattedGoingTime = 'Going Time: Not specified';
                  }

                  // Format leaving time
                  if (leavingTime.isNotEmpty) {
                    formattedLeavingTime = DateFormat('EEE, MMM d, yyyy - hh:mm a').format(DateTime.parse(leavingTime));
                  } else {
                    formattedLeavingTime = 'Leaving Time: Not specified';
                  }

                  return GestureDetector(
                    onTap: () {
                      print('Event ID: ${place['_id']}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(eventId: place['_id'] ?? ''), // Add null check here
                        ),
                      );
                    },
                    child: Container(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                ' ${place['NameOfPlace'] ?? ''}',
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
                                  // Text(
                                  //   ' ${place['_id'] ?? ''}',
                                  //   style: TextStyle(
                                  //     fontFamily: "Poppins",
                                  //     fontSize: 15,
                                  //     fontWeight: FontWeight.w400,
                                  //     color: Color(0xFF000000),
                                  //   ),
                                  // ),
                                  Text(
                                    'Going time '' $formattedGoingTime',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                     'Leaving time '' $formattedLeavingTime',
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
                                        GestureDetector(
                                          onTap: () {
                                            _showAddThoughtDialog(place['_id'] ?? '');
                                          },
                                          child: Text(
                                            'Share Your Thought here',
                                            style: TextStyle(
                                              color: Color(0xFF09C7BE),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            
                                                // String imagePath = await getImageForPlace();
                                              CupertinoButton(
  onPressed: () async {
    String message = composeMessageForEvent(place); // Assuming you have a function named composeMessageForEvent
    await Share.share(message);
  },
  child: Icon(CupertinoIcons.share),
),
                                                
                                           
                                            CupertinoButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return buildUpdateDialog(place['_id'] ?? '');
                                                  },
                                                );
                                              },
                                              child: Icon(CupertinoIcons.pencil),
                                            ),
                                            CupertinoButton(
                                              onPressed: () {
                                                _showLeaveEventDialog(place['_id'] ?? '');
                                              },
                                              child: Icon(CupertinoIcons.delete),
                                            ),
                 
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
          ),
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

  Future<void> _showLeaveEventDialog(String placeId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Leave Event"),
          content: Text("Are you sure you want to leave this event?"),
          actions: [
            TextButton(
              onPressed: () async {
                await leaveEvent(placeId); // Call the leave event function
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Leave"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> leaveEvent(String placeId) async {
    try {
      final response = await dio.delete(
        '${ApiUrls.baseUrl}/leaveevent/$placeId',
        data: {
          'token': widget.authToken,
        },
      );

      if (response.statusCode == 200) {
        // Successfully left the event
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully left the event.'),
          ),
        );
        getSavedPlaces(); // Refresh the saved events list
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave the event. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      // ... handle Dio errors ...
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }
}
