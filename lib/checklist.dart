import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistItem {
  final String id;
  final String name;
  final String description;
  final String status;

  ChecklistItem({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['_id'].toString(),
      name: json['name'],
      description: json['description'],
      status: json['status'],
    );
  }
}

class checklist extends StatefulWidget {
  const checklist({Key? key}) : super(key: key);

  @override
  State<checklist> createState() => _checklistState();
}

class _checklistState extends State<checklist> {
  late String token;
  late List<ChecklistItem> checklistItems;
  late String username = '';
  late String email = ' ';
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final Dio dio = Dio();

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDescriptionController = TextEditingController();

  void initState() {
    super.initState();
    _loadToken();
    checklistItems = [];
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
      _loadChecklistItems(); // Call _loadChecklistItems after setting the token
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

  Future<void> _loadChecklistItems() async {
    try {
      final response = await Dio().post(
        '${ApiUrls.baseUrl}/getchk',
        data: {'token': token},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('checklist')) {
          final List<dynamic> data = responseData['checklist'];
          setState(() {
            checklistItems =
                data.map((item) => ChecklistItem.fromJson(item)).toList();
          });
        } else {
          print('Key "checklist" not found in response data.');
        }
      } else {
        print('Failed to fetch checklist items');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  Future<void> deleteEvent(String itemId) async {
    try {
      final response = await dio.delete(
        '${ApiUrls.baseUrl}/deletechk/$itemId',
        data: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        // Successfully deleted event
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event deleted successfully.'),
          ),
        );

        _loadChecklistItems();
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      // ... handle Dio errors ...
      print('Dio Error: $e');
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  Future<void> _updateItemStatus(String itemId, bool? isChecked) async {
    try {
      if (isChecked == null) {
        // Handle the case where isChecked is null, if needed
        return;
      }
      await dio.post(
        '${ApiUrls.baseUrl}/updatests',
        // Pass additional data in the request body if needed
        data: {
          'token': token,
          'itemId': itemId,
          'status': isChecked ? 'done' : 'not done',
        },
      );

      // Refresh the checklist items after updating status
      _loadChecklistItems();
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  Future<void> _updateChecklistItem(String itemId) async {
    try {
      // Send the updated data to the server using Dio
      final response = await Dio().put(
        '${ApiUrls.baseUrl}/updatechk/$itemId',
        data: {
          'name': itemNameController.text,
          'description': itemDescriptionController.text,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        // Successfully updated checklist item on the server
        print('Checklist item updated successfully');
      } else {
        // Handle error cases
        print('Failed to update checklist item. Please try again.');
      }
    } catch (e) {
      // Handle Dio errors or other exceptions
      print('Error: $e');
    }
  }

  Future<void> _createChecklistItem() async {
    try {
      // Send data to the server using Dio
      final response = await Dio().post(
        '${ApiUrls.baseUrl}/createchk',
        data: {
          'name': itemNameController.text,
          'description': itemDescriptionController.text,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        // Successfully created checklist item on the server
        print('Checklist item created successfully');
      } else {
        // Handle error cases
        print('Failed to create checklist item. Please try again.');
      }
    } catch (e) {
      // Handle Dio errors or other exceptions
      print('Error: $e');
    }
  }

  Future<void> _showCreateChecklistDialog(
      {String? itemId, String? initialName, String? initialDescription}) async {
    // Use TextEditingController for the text fields
  itemNameController.text = initialName ?? '';
itemDescriptionController.text = initialDescription ?? '';

    bool isEdit = itemId != null;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isEdit ? "Edit Checklist Item" : "Create Checklist Item",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Set your preferred color
            ),
          ),
          content: Container(
            height: 150.0, // Set your preferred height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                TextField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: itemDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Item Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red, // Set your preferred color
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if both text fields are not empty
                if (itemNameController.text.trim().isEmpty ||
                    itemDescriptionController.text.trim().isEmpty) {
                  // Show a snackbar or alert dialog indicating that fields are required
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in both fields.'),
                    ),
                  );
                  return;
                }

                // Call the appropriate method based on whether it's an edit or create operation
                if (isEdit) {
                  await _updateChecklistItem(itemId);
                } else {
                  await _createChecklistItem();
                }

                // Refresh the checklist items after updating or creating
                _loadChecklistItems();

                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set your preferred color
              ),
              child: Text(isEdit ? "Save Changes" : "Create"),
            ),
          ],
        );
      },
    );
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
          onLogout: _logout,
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
                    "My Checklist",
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
              child: checklistItems.isEmpty
                  ? _buildEmptyChecklist()
                  : _buildChecklist(),
            ),
             GestureDetector(
                          onTap: () {
                            _showCreateChecklistDialog();
                          },
                          child: Icon(
                            CupertinoIcons.add_circled,
                            color: Color(0xFF09C7BE),
                            size: 60,
                          ),
                        ),
          ],
        ),
      
      ),
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
                itemCount: checklistItems.length,
                itemBuilder: (context, index) {
                  return Container(
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
                          offset:
                              Offset(0, 4), // shadow direction: bottom right
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(
                              checklistItems[index].name,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F4434),
                              ),
                            ),
                            subtitle: Text(
                              checklistItems[index].description,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF000000),
                              ),
                            ),
                            value: checklistItems[index].status == 'done',
                            onChanged: (bool? value) {
                              _updateItemStatus(
                                checklistItems[index].id,
                                value,
                              );
                            },
                            activeColor: Color(0xFF09C7BE),
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            _showCreateChecklistDialog(
                              itemId: checklistItems[index].id,
                              initialName: checklistItems[index].name,
                              initialDescription:
                                  checklistItems[index].description,
                            );
                          },
                          child: Icon(CupertinoIcons.pencil,
                              color: Color(0xFF1F4434)),
                        ),
                        CupertinoButton(
                          onPressed: () {
                            // Handle update action
                            deleteEvent(checklistItems[index].id);
                            // _showUpdateDialog(checklistItems[index]);
                          },
                          child: Icon(CupertinoIcons.delete,
                              color: Color(0xFF1F4434)),
                        ),
                      ],
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
          Text('No checklist items found.'),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _showCreateChecklistDialog();
            },
            child: Text('Create Checklist'),
          ),
        ],
      ),
    );
  }
}
