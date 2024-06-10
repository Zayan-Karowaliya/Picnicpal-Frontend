// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:picnicpalfinal/joinplaces.dart';
import 'package:picnicpalfinal/myevents.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Place {
  final String id;
  String EventType;
  String name;
  String description;
  String brief;
  int? numberOfPeople;
  String location;
  String addby;
  String image;
  String date;
  String from;
  String to;
  String latitude;
  String longitutde;
  Place(
      {required this.id,
      required this.EventType,
      required this.name,
      required this.description,
      required this.brief,
      required this.numberOfPeople,
      required this.location,
      required this.image,
      required this.addby,
      required this.date,
    required this.from,
    required this.to,
      required this.latitude,
    required this.longitutde});

  factory Place.fromJson(Map<String, dynamic> json, {String image = ''}) {
    return Place(
        id: json['_id'].toString(),
        EventType: json['EventType'],
        name: json['NameOfPlace'],
        brief: json['Brief'],
        description: json['Description'],
        numberOfPeople: json['NumberOfPeople'] as int?,
        location: json['location'],
        addby: json['addby'],
          date: json['date'] ?? '', // Ensure date is initialized
      from: json['from'] ?? '', // Ensure from is initialized
      to: json['to'] ?? '',
        latitude: json['latitude'] ?? '',
        longitutde: json['longitutde'] ?? '',
        image: '${ApiUrls.baseUrl}/uploads/$image');
  }
}

class eventcreated extends StatefulWidget {
  const eventcreated({super.key});

  @override
  State<eventcreated> createState() => _eventcreatedState();
}

class _eventcreatedState extends State<eventcreated> {
  late String token;
  late String username = '';
  late String email = ' ';
  String searchInput = ''; // Added for search functionality
  List<Place> places = []; // List to store all places
  List<Place> filteredPlaces = [];

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
      });
      _loadUserProfile();
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

  File? file;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  TextEditingController Eventtypecontroller = TextEditingController();
  TextEditingController newNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  TextEditingController BriefController = TextEditingController();
  TextEditingController locationController = TextEditingController();
TextEditingController dateController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
double? _latitude;
  double? _longitude;
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
        fetchItems();
      } else {
        // Handle error (e.g., navigate to login page)
        print('Failed to fetch user profile');
      }
    } catch (error) {
      // Handle error (e.g., navigate to login page)
      print('An error occurred: $error');
    }
  }

void _updateSearchInput(String input) {
    setState(() {
      searchInput = input;
      filteredPlaces = places
          .where((place) =>
              place.EventType.toLowerCase().contains(input.toLowerCase()))
          .toList();
    });
  }
  Future<List<Place>> fetchItems() async {
    try {
      var response = await dio.get(
        '${ApiUrls.baseUrl}/getmyplace/$username',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data; // Extract the response data
        final List<dynamic> data = responseData[
            'event']; // Access the list of places from the response data

        List<Place> places = data.map((item) {
          String image = item['image'] ?? '';
          return Place.fromJson(item, image: image);
        }).toList();

        return places;
      } else {
        print('Failed to fetch places. Status code: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  Future<void> _updateChecklistItem(String id) async {
    try {
      FormData formData = FormData.fromMap({
        'file': file != null
            ? await MultipartFile.fromFile(
                file!.path,
                filename: 'place_file.${file!.path.split('.').last}',
              )
            : null, // Only include file if it's selected

        'EventType': Eventtypecontroller.text,
        'NameOfPlace': newNameController.text,
        'Brief': BriefController.text,
        'Description': DescriptionController.text,
        'location': locationController.text,
         'addby': username,
        'date':dateController.text,
        'from':fromController.text,
        'to':toController.text,
         'latitude': _latitude.toString(), // Add latitude to the form data
         'longitutde': _longitude.toString(),
      });

      var response = await dio.put(
        '${ApiUrls.baseUrl}/updatemyplace/$id',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Successfully updated place on the server
        print('Place updated successfully');

        // Clear the selected file after successful update
        setState(() {
          file = null;
        });
      } else {
        // Handle error cases
        print('Failed to update place. Please try again.');
      }
    } catch (e) {
      // Handle Dio errors or other exceptions
      print('Error: $e');
    }
  }

  Future<void> _deletePlace(BuildContext context, String id) async {
    // Show a confirmation dialog
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this place?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User didn't confirm
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // User confirmed
                fetchItems();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // Check if the user confirmed the deletion
    if (deleteConfirmed == true) {
      try {
        final response = await Dio().delete(
          '${ApiUrls.baseUrl}/deleteplace/$id',
        );

        if (response.statusCode == 200) {
          // Successfully deleted place on the server
          fetchItems();
          setState(() {
            places.removeWhere((place) => place.id == id);
          });
          print('Place deleted successfully');
        } else if (response.statusCode == 404) {
          // Place not found
          print('Place not found');
        } else {
          // Handle other error cases
          print('Failed to delete place. Please try again.');
        }
      } catch (e) {
        // Handle Dio errors or other exceptions
        print('Error: $e');
      }
    }
  }

  Future<void> _createChecklistItem() async {
    if (file == null) {
      // Show an error message, file is required
      return;
    }

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file!.path,
          filename: 'place_file.${file!.path.split('.').last}',
        ), // Preserve the original file extension

        'EventType': Eventtypecontroller.text,
        'NameOfPlace': newNameController.text,
        'Brief': BriefController.text,
        'Description': DescriptionController.text,
        'location': locationController.text,
         'addby': username,
        'date':dateController.text,
        'from':fromController.text,
        'to':toController.text,
        'latitude': _latitude.toString(), // Add latitude to the form data
       'longitutde': _longitude.toString(),
      });

      var response = await dio.post(
        '${ApiUrls.baseUrl}/addplace',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Place added successfully

        print('Place added successfully');

        // You can handle the response if needed
      } else {
        // Handle error case
        print('Failed to add place. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
  }

  File? selectedFile;
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _showAddDataDialog({Place? place}) async {
    newNameController.text = place?.name ?? '';
    Eventtypecontroller.text = place?.EventType ?? '';
    BriefController.text = place?.brief ?? '';
    DescriptionController.text = place?.description ?? '';
    locationController.text = place?.location ?? '';
    dateController.text = place?.date ?? ''; // Initialize date field
   fromController.text = place?.from ?? '';   // Initialize from field
   toController.text = place?.to ?? '';

    bool isUpdate = place != null;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isUpdate ? 'Update Data' : 'Add Data'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                selectedFile != null
                    ? Text('Selected File: ${selectedFile!.path}')
                    : Text('No file selected'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Pick File'),
                ),
                SizedBox(height: 16.0),

                // Show the picked file
                if (file != null)
                  Text(
                    'File: ${file!.path}',
                    style: TextStyle(fontSize: 16.0),
                  ),

                // Button to upload place

                TextField(
                  controller: Eventtypecontroller,
                  decoration: InputDecoration(labelText: 'Event Type'),
                ),
                TextField(
                  controller: newNameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: BriefController,
                  decoration: InputDecoration(labelText: 'Brief'),
                ),
                TextField(
                  controller: DescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                  GooglePlacesAutoCompleteTextFormField(
                textEditingController: locationController,
                googleAPIKey: 'AIzaSyDRsSVJu_Z3geRw5aatpB_pOdj4qQ5Bk9w', // Replace with your API key
                decoration: const InputDecoration(
                 hintText: 'Enter your address',
                 labelText: 'Location',
                 labelStyle: TextStyle(color: Colors.purple),
                 border: OutlineInputBorder(),
                ),
                validator: (value) {
                 if (value!.isEmpty) {
                    return 'Please enter some text';
                 }
                 return null;
                },
                maxLines: 1,
                overlayContainer: (child) => Material(
                 elevation: 1.0,
                 color: Colors.green,
                 borderRadius: BorderRadius.circular(12),
                 child: child,
                ),
                getPlaceDetailWithLatLng: (prediction) {
                 print('Latitude: ${prediction.lat}, Longitude: ${prediction.lng}');
                 // Update locationController with the selected place's description
                   setState(() {
        _latitude = double.tryParse(prediction.lat ?? '');
                    _longitude = double.tryParse(prediction.lng ?? '');
    });
    // Update locationController with the selected place's description
    locationController.text = prediction.description ?? '';
  },
                itmClick: (Prediction prediction) =>
                    locationController.text = prediction.description!,
              ),
              TextField(
                controller: TextEditingController(text: username), // Use the username obtained from SharedPreferences
                decoration: InputDecoration(
                  labelText: 'Username',
                  enabled: false, // Make the field non-editable
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date field
              Expanded(
  child: TextField(
    controller: dateController,
    readOnly: true, // Make the field read-only
    onTap: () async {
      // Show date picker
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      // Update the text field with the selected date
      if (pickedDate != null) {
        setState(() {
          dateController.text = pickedDate.toString();
        });
      }
    },
    decoration: InputDecoration(labelText: 'Date'),
  ),
),
SizedBox(width: 16),
// Going time field
Expanded(
  child: TextField(
    controller: fromController,
    readOnly: true, // Make the field read-only
    onTap: () async {
      // Show time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      // Update the text field with the selected time
      if (pickedTime != null) {
        setState(() {
          fromController.text = pickedTime.format(context);
        });
      }
    },
    decoration: InputDecoration(labelText: 'Going Time'),
  ),
),
SizedBox(width: 16),
// Leaving time field
Expanded(
  child: TextField(
    controller: toController,
    readOnly: true, // Make the field read-only
    onTap: () async {
      // Show time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      // Update the text field with the selected time
      if (pickedTime != null) {
        setState(() {
          toController.text = pickedTime.format(context);
        });
      }    
    },
    decoration: InputDecoration(labelText: 'Leaving Time'),
  ),
),
                ],
              ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate the data or perform any checks before saving
                if (isUpdate) {
                  await _updateChecklistItem(place.id);
                } else {
                  // Call the function to create a checklist item
                  await _createChecklistItem();
                }

                // Close the dialog
                Navigator.of(context).pop();

                // You may want to refresh the UI or update the checklist items
                fetchItems();
              },
              child: Text(isUpdate ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Color(0xffE7E7EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchInput = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        hintStyle: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: Color(0xff6B6B6B),
                            fontSize: 16),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle search based on the 'searchInput'
                      // You can modify your API call or filter the list locally
                      // For simplicity, I'm filtering the list locally here
                    setState(() {
                      filteredPlaces = places
                          .where((place) =>
                              place.EventType.toLowerCase().contains(
                                searchInput.toLowerCase(),
                              ))
                          .toList();
                    });
                  },
                  icon: Icon(
                      CupertinoIcons.search,
                      color: Color(0xffA3A3A3),
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Places You Added",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F4434),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     _showAddDataDialog();
                        //   },
                        //   child: Icon(
                        //     CupertinoIcons.add_circled,
                        //     color: Color(0xFF09C7BE),
                        //     size: 40,
                        //   ),
                        // ),
                        // Icon(
                        //   CupertinoIcons.add_circled,
                        //   color: Color(0xFF09C7BE),
                        //   size: 40,
                        // ),
                      ],
                    ),
                    SizedBox(
                      height:
                          15, // Add vertical space between the first row and the second row
                    ),
                    FutureBuilder<List<Place>>(
                      future: fetchItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text('No data available.');
                        } else {
                          // Replace this part with your actual data structure
                           places = snapshot.data!;
                  filteredPlaces = searchInput.isEmpty
                      ? places
                      : places
                          .where((place) => place.EventType
                              .toLowerCase()
                              .contains(searchInput.toLowerCase()))
                          .toList();

                  if (filteredPlaces.isEmpty) {
                    return Text('No results found.');
                  }

                          return Column(
                            children: places.map((place) {
                              return Container(
                                  child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Positioned(
                                    top: 0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        place
                                            .image, // Replace with the actual field name
                                        width: 140,
                                        height: 150,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),

                                  // Column for place details
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 170),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                20, 5, 20, 5),
                                            decoration: BoxDecoration(
                                              color: Color(0xffBA339C)
                                                  .withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              place.EventType,
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 22,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xffBA339C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        place.name,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        place.brief,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff898A8D),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        place.description,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff898A8D),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        place.location,
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff898A8D),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            place.numberOfPeople.toString(),
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff898A8D),
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "people going ",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xffA3A3A3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showAddDataDialog(place: place);
                                            },
                                            child: Icon(
                                              CupertinoIcons.pencil,
                                              size: 30,
                                              color: Color(0xFF09C7BE),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          GestureDetector(
                                            onTap: () {
                                              _deletePlace(context, place.id);
                                            },
                                            child: Icon(
                                              CupertinoIcons.delete,
                                              size: 30,
                                              color: Color(0xFF09C7BE),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: const Color.fromARGB(
                                            255, 235, 233, 233),
                                        thickness: 2,
                                        height: 20,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                            }).toList(),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height:
                          15, // Add vertical space between the first row and the second row
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
}
