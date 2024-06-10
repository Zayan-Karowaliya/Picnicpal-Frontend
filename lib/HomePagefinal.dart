// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:picnicpalfinal/joinplaces.dart';
import 'package:picnicpalfinal/myevents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';

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

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late List<Place> placesWithImages;
  late String token;
  late String username = '';
  late String email = ' ';

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

  File? file;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  TextEditingController newNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final Dio dio = Dio();

  late List<Place> searchedPlaces = [];
  List<Place> allPlaces = [];

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

  Future<List<Place>> fetchItems() async {
    try {
      var response = await dio.get('${ApiUrls.baseUrl}/getall');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        allPlaces = data.map((item) {
          String image = item['image'] ?? '';
          return Place.fromJson(item, image: image);
        }).toList();

        return allPlaces;
        ;
      } else {
        // Handle error case
        print('Failed to fetch places. Status code: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      return [];
    }
  }

  TextEditingController Eventtypecontroller = TextEditingController();
  TextEditingController addnewNameController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  TextEditingController BriefController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  double? _latitude;
  double? _longitude;
  Future<void> _createChecklistItem() async {
    if (file == null ||
      Eventtypecontroller.text.isEmpty ||
      addnewNameController.text.isEmpty ||
      BriefController.text.isEmpty ||
      DescriptionController.text.isEmpty ||
      locationController.text.isEmpty ||
      dateController.text.isEmpty ||
      fromController.text.isEmpty ||
      toController.text.isEmpty ||
      _latitude == null ||
      _longitude == null) {
    // Show an error message if any field is empty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fill all the fields and select a file.'),
      ),
    );
    return;
  }


    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file!.path,
          filename: 'place_file.${file!.path.split('.').last}',
        ), // Preserve the original file extension

        'EventType': Eventtypecontroller.text,
        'NameOfPlace': addnewNameController.text,
        'Brief': BriefController.text,
        'Description': DescriptionController.text,
        'location': locationController.text,
        'addby': username,
        'date': dateController.text,
        'from': fromController.text,
        'to': toController.text,
        'latitude': _latitude.toString(), // Add latitude to the form data
        'longitutde': _longitude.toString(),
      });

      var response = await dio.post(
        '${ApiUrls.baseUrl}/addmyplace',
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
    fromController.text = place?.from ?? ''; // Initialize from field
    toController.text = place?.to ?? '';
    bool isUpdate = place != null;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Data'), // Always show 'Add Data' title
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                // Text fields for input data
                TextField(
                  controller: Eventtypecontroller,
                  decoration: InputDecoration(labelText: 'Event Type'),
                ),
                TextField(
                  controller: addnewNameController,
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
                  googleAPIKey:
                      'AIzaSyDRsSVJu_Z3geRw5aatpB_pOdj4qQ5Bk9w', // Replace with your API key
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
                    print(
                        'Latitude: ${prediction.lat}, Longitude: ${prediction.lng}');
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
                  controller: TextEditingController(
                      text:
                          username), // Use the username obtained from SharedPreferences
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
            ElevatedButton(
              onPressed: () async {
                // Call the function to create a new checklist item
                await _createChecklistItem();

                // Close the dialog
                Navigator.of(context).pop();

                // Refresh the UI or update the checklist items
                fetchItems();
              },
              child: Text('Add'),
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
                  "Home",
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
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterPlaces(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search here',
                  hintStyle: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                      color: Color(0xff6B6B6B),
                      fontSize: 16),
                  border: InputBorder.none,
                  suffixIcon: Icon(
                    CupertinoIcons.search,
                    color: Color(0xffA3A3A3),
                    size: 25,
                  ),
                ),
                cursorColor: Colors.black,
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
                          "For You",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F4434),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAddDataDialog(); // Call the function to show the add data dialog
                          },
                          child: Icon(
                            Icons.add, // You can choose any icon for adding
                            color: Color(0xFF09C7BE),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
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
                          final places = snapshot.data!;

                          return Column(
                            children: searchedPlaces.isNotEmpty
                                ? searchedPlaces.map((place) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              place.image,
                                              width: 140,
                                              height: 170,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            20, 5, 20, 5),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffBA339C)
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      place.EventType,
                                                      style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xffBA339C),
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
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    place.numberOfPeople
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff898A8D),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Created by: ${place.addby}',
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xffA3A3A3),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          joinplaces(
                                                              token: token,
                                                              place: place),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "View More >>",
                                                  style: TextStyle(
                                                    color: Color(0xFF09C7BE),
                                                    fontFamily: 'Poppins',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
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
                                        ),
                                      ],
                                    );
                                  }).toList()
                                : places.map((place) {
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: Image.network(
                                              place.image,
                                              width: 140,
                                              height: 170,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            20, 5, 20, 5),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffBA339C)
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      place.EventType,
                                                      style: TextStyle(
                                                        fontFamily: "Poppins",
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xffBA339C),
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
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    place.numberOfPeople
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xff898A8D),
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Created by: ${place.addby}',
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xffA3A3A3),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          joinplaces(
                                                              token: token,
                                                              place: place),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "View More >>",
                                                  style: TextStyle(
                                                    color: Color(0xFF09C7BE),
                                                    fontFamily: 'Poppins',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
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
                                        ),
                                      ],
                                    );
                                  }).toList(),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 15,
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

  void filterPlaces(String query) {
    setState(() {
      searchedPlaces = allPlaces
          .where(
              (place) => place.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
