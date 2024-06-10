//   import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
//   import 'package:flutter/material.dart';
//   import 'package:untitled1/apiclass.dart';
//   import 'package:shared_preferences/shared_preferences.dart';
//   import 'package:socket_io_client/socket_io_client.dart' as IO;


//   class Chat extends StatefulWidget {
//     final String eventId; // Event ID passed from myevents screen

//     const Chat({required this.eventId});

//     @override
//     _ChatScreenState createState() => _ChatScreenState();
//   }

//   class _ChatScreenState extends State<Chat> {
//     bool _isOnline = true;
//     late String token;
//     late String username = '';
//     late TextEditingController messageController;
//     late Map<String, IO.Socket> sockets =
//         {}; // Map to store socket connections for each event ID
//     late List<dynamic> messagesMap =
//         []; // Map to store messages for each event ID
//     late IO.Socket socket;
// String placeName='';
// String imageUrl='';

//     @override
//     void initState() {
//       connectToServer(widget.eventId);
//       super.initState();
//       messageController = TextEditingController();
//       _loadToken();
      
//       fetchPlaceName(widget.eventId).then((filename) {
//     setState(() {
//       imageUrl = '${ApiUrls.baseUrl}/uploads/$filename';
//     });
//   }).catchError((error) {
//     print('Error fetching image filename: $error');
//   });
//     }

//     @override
//     void dispose() {
//       sockets.values.forEach((socket) => socket.disconnect());
//       super.dispose();
//     }



//   // Function to filter messages based on the search query
 

//     Future<void> _loadToken() async {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       final String? storedToken = prefs.getString('token');

//       if (storedToken != null) {
//         print('Token loaded: $storedToken');
//         setState(() {
//           token = storedToken;
//           _loadUserProfile();
//         });
//       } else {
//         print('Token not found');
//       }
//     }

//     void listenToMessages() {
//       socket.on('message', (data) {
//         print('Message received from server: $data');
//         setState(() {
//           messagesMap.add(data);
//         });
//       });
//     }

//     Future<void> _loadUserProfile() async {
//       try {
//         final response = await Dio().post(
//           '${ApiUrls.baseUrl}/singleuser',
//           data: {'token': token},
//         );

//         if (response.statusCode == 200) {
//           final userData = response.data;

//           setState(() {
//             username = userData['username'];
//             print('Username loaded: $username');
//           });
//         } else {
//           print('Failed to fetch user profile. Status code: ${response.statusCode}');
//         }
//       } catch (error) {
//         print('An error occurred: $error');
//       }
//     }

//     void connectToServer(String eventId) {
//       print('Connecting to server for event: $eventId');
//       socket = IO.io('${ApiUrls.baseUrl}', <String, dynamic>{
//         'transports': ['websocket'],
//         'autoConnect': false,
//       });
//       socket.connect();

//       socket.on('connect', (_) {
//         print("Event ID: $eventId");
//         socket.emit('joinEvent', eventId);
//       });
//       socket.emit('prev_message', eventId);
//       socket.on('previous_messages', (data) {
//         setState(() {
//           messagesMap = data;
//         });
//       });
//       listenToMessages();
//     }

//     void sendMessage(String eventId) {
//       String message = messageController.text.trim();
//       if (message.isNotEmpty) {
//         socket.emit('message', {'message': message, 'sender': username, 'eventId': eventId});
//         messageController.clear();
//       }
//     }

//   void disconnectAndClose(String eventId) {
//       print(
//           'Before disconnection for Event ID $eventId - Socket connected: ${sockets[eventId]?.connected}');
//       // socket.disconnect();
//       socket.on('disconnect', (_) {
//         print('disconnected');
//         print(eventId);
//         socket.emit('leaveEvent', eventId);
//       });
//       socket.dispose();
//       print(
//           'After disconnection for Event ID $eventId - Socket connected: ${sockets[eventId]?.connected}');
//       sockets.remove(eventId); // Remove the socket associated with the event ID
//       messagesMap
//           .remove(eventId); // Remove the messages associated with the event ID
//       // Close the chat screen
//       Navigator.of(context).pop();
//     }

//     Future<String> fetchPlaceName(String eventId) async {
//   try {
//     final response = await Dio().get('${ApiUrls.baseUrl}/singleplace/$eventId');
//    // Replace with the actual image filename

//     if (response.statusCode == 200) {
//       final placeData = response.data['event']; // Assuming the place name is under 'event' key
//       placeName = placeData['NameOfPlace'];
//       imageUrl = placeData['image']; 
//       final filename = placeData['image']; // Assuming the key for the image filename is 'image'
//       return filename;// Assuming the key for place name is 'placeName'
//       print(imageUrl);
//       return placeName;
//     } else {
//       throw Exception('Failed to load place name');
//     }
//   } catch (error) {
//     throw error;
//   }
// }
// Future<String> fetchImageFilename(String eventId) async {
//   try {
//     final response = await Dio().get('${ApiUrls.baseUrl}/getImageFilename/$eventId');
//     if (response.statusCode == 200) {
//       return response.data['filename']; // Assuming your response contains the filename
//     } else {
//       throw Exception('Failed to fetch image filename');
//     }
//   } catch (error) {
//     throw error;
//   }
// }
//     @override
//     Widget build(BuildContext context) {
//       final String eventId = widget.eventId;

//       return Scaffold(
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//     ClipOval(
//   child: Image.network(
//     imageUrl,
//     width: 100,
//     height: 100,
//     fit: BoxFit.cover,
//   ),
// ),
//                       SizedBox(width: 20.0),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             placeName,
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 30.0,
//                               fontWeight: FontWeight.bold,
//                                color: Color(0xFF1F4434),
//                             ),
//                           ),
//                            SizedBox(height: 1), // Add some spacing between the placeName and chat group text
//     Text(
//       'Chat Group', // Text for the chat group
//       style: TextStyle(
//         fontFamily: 'Poppins',
//         fontSize: 15.0, // Adjust the font size as needed
//         color: Colors.grey[600], // Adjust the color as needed
//       ),
//     ),
//                         ],
//                       ),
//                       Spacer(), // Add spacer to push the close icon to the right
//               InkWell(
//   onTap: () {
//     disconnectAndClose(eventId);
//   },
//   child: Container(
//     padding: EdgeInsets.all(8.0),
//     decoration: BoxDecoration(
//       shape: BoxShape.circle,
//       color: Colors.grey[200], // Background color
//     ),
//     child: Icon(
//          CupertinoIcons.clear,
//       color: Color(0xFF1F4434), // Icon color
//     ),
//   ),
// ),
//                     ],
//                   ),

//                   SizedBox(height: 10.0),
//                   Divider(
//                     color: Colors.black26,
//                     thickness: 1.0,
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
//                 reverse: true, // To start from the bottom
//                 itemCount: messagesMap.length,
//                 itemBuilder: (context, index) {
//                   final reversedIndex = messagesMap.length - 1 - index;
//                   final message = messagesMap[reversedIndex];
//                   final sender = message['sender'];
//                   final messageText = message['message'];
//                   final isSentByMe = sender == username;
//                   return _buildMessageBubble(messageText, sender, isSentByMe);
//                 },
//               ),
//             ),
//             _buildMessageInputField(eventId),
//           ],
//         ),
//       );
//     }

//     Widget _buildMessageBubble(String message, String sender, bool isSentByMe) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//             child: Row(
//               mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//               children: [
//                 Text(
//                   sender,
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 12.0,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
//             child: Container(
//               margin: EdgeInsets.symmetric(vertical: 8.0),
//               padding: EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: isSentByMe ? Color(0xFF09C7BE) : Colors.grey[200],
//                 borderRadius: BorderRadius.circular(20.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 5.0,
//                     spreadRadius: 1.0,
//                     offset: Offset(0.0, 2.0),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message,
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   color: isSentByMe ? Colors.white : Colors.black,
//                   fontSize: 16.0,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }





//     Widget _buildMessageInputField(String eventId) {
//       return Container(
//         margin: EdgeInsets.all(10.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: messageController,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   hintText: 'Type a message...',
//                   contentPadding: EdgeInsets.all(16.0),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 10.0),
//             Material(
//               color: Color(0xFF09C7BE),
//               borderRadius: BorderRadius.circular(30.0),
//               child: IconButton(
//                 icon: Icon(Icons.send, color: Colors.white),
//                 onPressed: () {
//                   sendMessage(eventId);
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Chat extends StatefulWidget {
  final String eventId; // Event ID passed from myevents screen

  const Chat({required this.eventId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chat> {
  bool _isOnline = true;
  late String token;
  late String username = '';
  late TextEditingController messageController;
  late Map<String, IO.Socket> sockets =
      {}; // Map to store socket connections for each event ID
  late List<dynamic> messagesMap =
      []; // Map to store messages for each event ID
  late IO.Socket socket;
  String placeName = '';
  String imageUrl = '';
  late String searchQuery = ''; // New variable to store the search query

  @override
  void initState() {
    connectToServer(widget.eventId);
    super.initState();
    messageController = TextEditingController();
    _loadToken();

    fetchPlaceName(widget.eventId).then((filename) {
      setState(() {
        imageUrl = '${ApiUrls.baseUrl}/uploads/$filename';
      });
    }).catchError((error) {
      print('Error fetching image filename: $error');
    });
  }

  @override
  void dispose() {
    sockets.values.forEach((socket) => socket.disconnect());
    super.dispose();
  }

  // Function to filter messages based on the search query
  List<dynamic> filterMessages(String query) {
    return messagesMap.where((message) {
      final String messageText =
          message['message'].toString().toLowerCase();
      return messageText.contains(query.toLowerCase());
    }).toList();
  }

  // Function to update the search query
  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      print('Token loaded: $storedToken');
      setState(() {
        token = storedToken;
        _loadUserProfile();
      });
    } else {
      print('Token not found');
    }
  }

  void listenToMessages() {
    socket.on('message', (data) {
      print('Message received from server: $data');
      setState(() {
        messagesMap.add(data);
      });
    });
  }

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
          print('Username loaded: $username');
        });
      } else {
        print(
            'Failed to fetch user profile. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  void connectToServer(String eventId) {
    print('Connecting to server for event: $eventId');
    socket = IO.io('${ApiUrls.baseUrl}', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    socket.on('connect', (_) {
      print("Event ID: $eventId");
      socket.emit('joinEvent', eventId);
    });
    socket.emit('prev_message', eventId);
    socket.on('previous_messages', (data) {
      setState(() {
        messagesMap = data;
      });
    });
    listenToMessages();
  }

  void sendMessage(String eventId) {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      socket.emit('message', {
        'message': message,
        'sender': username,
        'eventId': eventId
      });
      messageController.clear();
    }
  }

  void disconnectAndClose(String eventId) {
    print(
        'Before disconnection for Event ID $eventId - Socket connected: ${sockets[eventId]?.connected}');
    // socket.disconnect();
    socket.on('disconnect', (_) {
      print('disconnected');
      print(eventId);
      socket.emit('leaveEvent', eventId);
    });
    socket.dispose();
    print(
        'After disconnection for Event ID $eventId - Socket connected: ${sockets[eventId]?.connected}');
    sockets.remove(eventId); // Remove the socket associated with the event ID
    messagesMap
        .remove(eventId); // Remove the messages associated with the event ID
    // Close the chat screen
    Navigator.of(context).pop();
  }

  Future<String> fetchPlaceName(String eventId) async {
    try {
      final response = await Dio().get('${ApiUrls.baseUrl}/singleplace/$eventId');
      // Replace with the actual image filename

      if (response.statusCode == 200) {
        final placeData = response.data['event']; // Assuming the place name is under 'event' key
        placeName = placeData['NameOfPlace'];
        imageUrl = placeData['image'];
        final filename = placeData['image']; // Assuming the key for the image filename is 'image'
        return filename; // Assuming the key for place name is 'placeName'
        print(imageUrl);
        return placeName;
      } else {
        throw Exception('Failed to load place name');
      }
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String eventId = widget.eventId;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          placeName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F4434),
                          ),
                        ),
                        SizedBox(
                            height:
                                1), // Add some spacing between the placeName and chat group text
                        Text(
                          'Chat Group', // Text for the chat group
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.0, // Adjust the font size as needed
                            color: Colors.grey[600], // Adjust the color as needed
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // Add spacer to push the close icon to the right
                    InkWell(
                      onTap: () {
                        disconnectAndClose(eventId);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200], //
                        ),
                        child: Icon(
                          CupertinoIcons.clear,
                          color: Color(0xFF1F4434), // Icon color
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Divider(
                  color: Colors.black26,
                  thickness: 1.0,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              reverse: true, // To start from the bottom
              itemCount: filterMessages(searchQuery).length,
              itemBuilder: (context, index) {
                final reversedIndex =
                    filterMessages(searchQuery).length - 1 - index;
                final message = filterMessages(searchQuery)[reversedIndex];
                final sender = message['sender'];
                final messageText = message['message'];
                final isSentByMe = sender == username;
                return _buildMessageBubble(
                    messageText, sender, isSentByMe);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Type a message...',
                      contentPadding: EdgeInsets.all(16.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                Material(
                  color: Color(0xFF09C7BE),
                  borderRadius: BorderRadius.circular(30.0),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      sendMessage(eventId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMessageBubble(String message, String sender, bool isSentByMe) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isSentByMe ? Color(0xFF09C7BE) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isSentByMe ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      );
    }





    Widget _buildMessageInputField(String eventId) {
      return Container(
        margin: EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Type a message...',
                  contentPadding: EdgeInsets.all(16.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Material(
              color: Color(0xFF09C7BE),
              borderRadius: BorderRadius.circular(30.0),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  sendMessage(eventId);
                },
              ),
            ),
          ],
        ),
      );
    }
  }