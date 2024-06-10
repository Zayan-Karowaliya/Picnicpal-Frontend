import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String eventId; // List of event IDs passed from myevents screen

  const ChatScreen({required this.eventId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late String token;
  late String username = '';
  late TextEditingController messageController;
  late Map<String, IO.Socket> sockets =
      {}; // Map to store socket connections for each event ID
  late List<dynamic> messagesMap =
      []; // Map to store messages for each event ID
  late IO.Socket socket;
  @override
  void initState() {
    connectToServer(widget.eventId);
    super.initState();
    messageController = TextEditingController();
    _loadToken();
  }

  @override
  void dispose() {
    // Disconnect all socket connections when the screen is disposed
    sockets.values.forEach((socket) => socket.disconnect());
    super.dispose();
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
      // Handle incoming messages here
      print('Message received from server: $data');
      setState(() {
        messagesMap.add(data);
      });
      // You can update UI, display notifications, etc. based on the received message
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
      print("Event ID: "+eventId);
      socket.emit('joinEvent', eventId);
    });
    socket.emit('prev_message',eventId);
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
      socket.emit('message',
          {'message': message, 'sender': username, 'eventId': eventId});
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

  @override
  Widget build(BuildContext context) {
    final String eventId = widget.eventId;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Socket.IO Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Disconnect from the current event and close the chat screen
              disconnectAndClose(widget.eventId);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: Column(
            children: [
              Text('Event ID: $eventId'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: messagesMap.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final message = messagesMap[index];
                  final isCurrentUserMessage = message['sender'] == username;

                  return Align(
                    alignment: isCurrentUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isCurrentUserMessage
                            ? Colors.blueAccent
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${message['sender']}:',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            message['message'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  sendMessage(eventId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}