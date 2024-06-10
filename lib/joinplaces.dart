import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/mapscreen.dart';
import 'package:picnicpalfinal/timeprefrence.dart';
import 'package:url_launcher/url_launcher.dart';
class joinplaces extends StatefulWidget {
  final Place place;
  final String token;

  const joinplaces({required this.place, required this.token});

  @override
  _joinplacesstate createState() => _joinplacesstate();
}

class _joinplacesstate extends State<joinplaces> {
  final Dio dio = Dio();

  Future<void> joinEvent() async {
  try {
    final response = await dio.post(
      '${ApiUrls.baseUrl}/joinevent/${widget.place.id}',
      data: {
        'token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      // Successfully joined the event, you can handle the response accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined the event at ${widget.place.name}'),
        ),
      );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => timeprefrence(
              Placeid: widget.place.id,
              token: widget.token,
            ),
          ),
        );
    
    } else {
      // Handle error cases
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to join the event. Please try again.'),
        ),
      );
    }
  } on DioError catch (e) {
    // Handle Dio errors or exceptions
    if (e.response!.statusCode == 400) {
      // Handle 401 Unauthorized error (incorrect credentials)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You have already registered for the event'),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    }
  } catch (e) {
    // Handle Dio errors
    print('Dio Error: $e');
  }
}

 void _openMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapScreen(
          latitude: double.parse(widget.place.latitude),
          longitude: double.parse(widget.place.longitutde),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 1.8,
              child: Image.network(
                widget.place.image,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Expanded Container with white background and text
          Positioned(
            top: MediaQuery.of(context).size.height / 2.5,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 1.6,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(
                        color: Color(0xffBA339C).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${widget.place.EventType}',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Color(0xffBA339C),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      ' ${widget.place.name}',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'People Going: ${widget.place.numberOfPeople}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff898A8D),
                                    ),
                                  ),
                                   SizedBox(height: 5),
          Text(
             "${widget.place.from != null ? 'Starting at: ${widget.place.from}' : 'No date for this event'}",
            style: TextStyle(
              
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xffA3A3A3),
            ),
          ),
            SizedBox(height: 5),
          Text(
              "${widget.place.to != null ? 'Ending at: ${widget.place.to}' : 'No date for this event'}",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xffA3A3A3),
            ),
          ),
          SizedBox(height: 5),
          Text(
            "${widget.place.date != null ? widget.place.date : ''}",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xffA3A3A3),
            ),
          ),
                                
                                  
                                ],
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Description: ${widget.place.description}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff5e5e5e),
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(),
                        SizedBox(height: 10),
                         GestureDetector(
                          onTap: _openMapScreen,
                        child:Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: Color(0xFF09C7BE),
                              size: 40,
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${breakTextOnCommas(widget.place.location)}',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff000000),
                                  ),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                    ),
                        SizedBox(height: 30),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // The new button above the "Join" button
                              ElevatedButton(
                                onPressed: () {
                                  getSharedThoughts();
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "Shared Thoughts",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              // The existing "Join" button
                              ElevatedButton(
                                onPressed: () {
                                  joinEvent();
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434), minimumSize: Size(200, 80),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  "Join",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  String breakTextOnCommas(String text) {
    List<String> lines = text.split(',');

    return lines.join('\n');
  }

  Future<void> _showSharedThoughtsDialog(
      List<Map<String, dynamic>> sharedThoughts) async {
    int currentIndex = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text('Shared Thoughts'),
          content: Container(
            width: double.maxFinite,
            height: 300, // Adjust the height as needed
            child: PageView.builder(
              itemCount: sharedThoughts.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final thought = sharedThoughts[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Username: ${thought['username']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Thought: ${thought['fact']}'),
                      onLongPress: () {
                        // Show reactions dialog on long press
                        _showReactionsDialog();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.black),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getSharedThoughts() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/getsharedthought/${widget.place.id}',
        data: {
          'token': widget.token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['sharedThoughts'];

        // Extract shared thoughts from the response
        final sharedThoughts = data.map((thought) {
          return {
            'username': thought['username'],
            'fact': thought['fact'],
          };
        }).toList();

        // Show the shared thoughts in a dialogue
        await _showSharedThoughtsDialog(sharedThoughts);
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch shared thoughts. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Handle Dio errors
      print('Dio Error: $e');
    }
  }

  List<String> reactions = ['👍', '❤️', '😂', '😊'];
  void _showReactionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reactions"),
          content: Column(
            children: reactions.map((emoji) {
              return InkWell(
                onTap: () {
                  // Handle reaction submission, e.g., send to the backend
                  _submitReaction(emoji);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 24),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _submitReaction(String emoji) async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/reaction/${widget.place.id}',
        data: {
          'token': widget.token,
          'emoji': emoji,
        },
      );

      if (response.statusCode == 200) {
        // Successfully added the reaction
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reaction added successfully'),
          ),
        );
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reaction. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      print('Dio Error: $e');
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  
}

class GoogleMapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const GoogleMapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Latitude: $latitude');
    print('Longitude: $longitude');
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('SelectedLocation'),
                  position: LatLng(latitude, longitude),
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _launchDirections();
            },
            child: Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchDirections() async {
    // Replace `latitude` and `longitude` with the coordinates of the selected location
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}