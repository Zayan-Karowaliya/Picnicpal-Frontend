// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:google_places_autocomplete_text_field/model/prediction.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:file_picker/file_picker.dart';
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
  //   String date;
  //   String from;
  // String to;
  String latitude;
  String longitutde;
  String image;
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
      //   required this.date,
      // required this.from,
      // required this.to,
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
        //  date: json['date'] ?? '', // Ensure date is initialized
        // from: json['from'] ?? '', // Ensure from is initialized
        // to: json['to'] ?? '',
        latitude: json['latitude'] ?? '',
        longitutde: json['longitutde'] ?? '',
        image: '${ApiUrls.baseUrl}/uploads/$image');
  }
}

class Vehicle {
  final String id;
  String type;
  String numberPlate;
  String drivername;
  String driverContact;
  String numberofseats;

  Vehicle({
    required this.id,
    required this.type,
    required this.numberPlate,
    required this.drivername,
    required this.driverContact,
    required this.numberofseats,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
        id: json['_id'].toString(),
        type: json['type'],
        numberPlate: json['numberPlate'],
        drivername: json['drivername'],
        driverContact: json['numberofseats'],
        numberofseats: json['numberofseats']);
  }
}

class adminhome extends StatefulWidget {
  const adminhome({super.key});
  @override
  State<adminhome> createState() => _adminhomeState();
}

class _adminhomeState extends State<adminhome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 40, 0, 0),
                child: GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');

                    // Navigate to the login page and prevent going back to admin home
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Icon(CupertinoIcons.square_arrow_left,
                      size: 40, color: Colors.red),
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
                    "Admin Home",
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
            // TabBar for switching between Places and Vehicles
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Color(0xFF1F4434),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: TabBar(
                  indicatorColor: Color.fromARGB(255, 85, 105, 104),
                  indicatorPadding:
                      EdgeInsets.fromLTRB(5, 0, 10, 0), // Adjusted padding
                  indicatorWeight: 2.5,
                  tabs: [
                    Tab(text: 'Places'),
                    Tab(text: 'Vehicles'),
                  ],
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(0, 69, 69, 69).withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    children: [
                      // Replace with your actual widget for displaying places
                      place(),
                      // Replace with your actual widget for displaying vehicles
                      vehicle(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class place extends StatefulWidget {
  const place({super.key});

  @override
  State<place> createState() => _placeState();
}

class _placeState extends State<place> {
  late String token;
  late String username = '';
  late String email = ' ';
  String searchInput = ''; // Added for search functionality
  List<Place> places = []; // List to store all places
  List<Place> filteredPlaces = [];
  List<Vehicle> vehicles = [];
  void initState() {
    super.initState();
    _loadToken();
    fetchItems();
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
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
  double? _latitude;
  double? _longitude;
  final Dio dio = Dio();

  Future<List<Place>> fetchItems() async {
    try {
      var response = await dio
          .get('${ApiUrls.baseUrl}/getall'); // Update with your actual endpoint

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Place> places = data.map((item) {
          String image =
              item['image'] ?? ''; // Update with your actual field name
          return Place.fromJson(item, image: image);
        }).toList();

        return places;
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
        'latitude': _latitude.toString(), // Add latitude to the form data
        'longitutde': _longitude.toString(),
      });

      var response = await dio.put(
        '${ApiUrls.baseUrl}/updateplace/$id',
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
     if (file == null ||
      Eventtypecontroller.text.isEmpty ||
      BriefController.text.isEmpty ||
      DescriptionController.text.isEmpty ||
      locationController.text.isEmpty ||
     
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
        'NameOfPlace': newNameController.text,
        'Brief': BriefController.text,
        'Description': DescriptionController.text,
        'location': locationController.text,
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                  color: Color.fromARGB(0, 69, 69, 69),
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
                        GestureDetector(
                          onTap: () {
                            _showAddDataDialog();
                          },
                          child: Icon(
                            CupertinoIcons.add_circled,
                            color: Color(0xFF09C7BE),
                            size: 40,
                          ),
                        ),
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

                          final filteredPlaces = searchInput.isEmpty
                              ? places
                              : places
                                  .where((place) =>
                                      place.EventType.toLowerCase().contains(
                                        searchInput.toLowerCase(),
                                      ))
                                  .toList();

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
                                      Text(
                                        'Created by: ${place.addby}',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xffA3A3A3),
                                        ),
                                      ),
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

class vehicle extends StatefulWidget {
  const vehicle({super.key});

  @override
  State<vehicle> createState() => _vehicleState();
}

class _vehicleState extends State<vehicle> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> savedvehicle = [];
  List<Vehicle> filteredVehiclePlaces = [];
  List<Vehicle> vehicles = [];
  @override
  void initState() {
    super.initState();
    // Fetch vehicles when the widget is initialized
    fetchAllVehicles();
  }

  final Dio dio = Dio();
  Future<void> fetchAllVehicles() async {
    try {
      var response = await dio.get('${ApiUrls.baseUrl}/getallvehicle');

      if (response.statusCode == 200) {
        setState(() {
          savedvehicle = List<Map<String, dynamic>>.from(
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

  TextEditingController vehicleTypecontroller = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController numberofseatsController = TextEditingController();
  TextEditingController driverContactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

//   Future<void> updatevehicle(String id, Map<String, dynamic> vehicleDetails) async {
//   try {
//     // Assuming you have a Dio instance named 'dio'
//     final String apiUrl = '${ApiUrls.baseUrl}/updatevehicle/$id'; // Replace with your actual API URL

//     // Prepare the request body
//     Map<String, dynamic> requestBody = vehicleDetails;

//     // Make the PUT request
//     final response = await dio.put(
//       apiUrl,
//       data: requestBody,
//     );

//     // Check the response
//     if (response.statusCode == 200) {
//       print('Vehicle updated successfully');
//       // Optionally, refresh your local state or show a success message
//     } else {
//       print('Failed to update vehicle. Status code: ${response.statusCode}');
//       // Handle the error, e.g., show an error message
//     }
//   } catch (error) {
//     print('Error updating vehicle: $error');
//     // Handle exceptions, e.g., show an error message
//   }
// }

 Future<void> addvehicle() async {
  try {
    String vehicleType = vehicleTypecontroller.text;
    String vehicleNumber = vehicleNumberController.text;
    String driverName = driverNameController.text;
    String numberOfSeats = numberofseatsController.text;
    String driverContact = driverContactController.text;
    
    Map<String, dynamic> requestBody = {
      'type': vehicleType,
      'numberPlate': vehicleNumber,
      'drivername': driverName,
      'numberofseats': numberOfSeats,
      'driverContact': driverContact,
    };

    print('Request Body: $requestBody');

    final response = await dio.post(
      '${ApiUrls.baseUrl}/addvehicle',
      data: requestBody,
    );

    if (response.statusCode == 201) {
      fetchAllVehicles(); // Refresh the vehicle list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle added successfully')),
      );
    } else {
      print('Request failed with status: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vehicle')),
      );
    }
  } on DioError catch (dioError) {
    String errorMessage = 'An error occurred';
    if (dioError.response != null) {
      if (dioError.response!.statusCode == 400) {
        errorMessage = dioError.response!.data['message'];
      } else {
        errorMessage = 'Failed to add vehicle: ${dioError.response!.statusMessage}';
      }
    } else {
      errorMessage = dioError.message!;
    }
    print('Error: $errorMessage');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (error) {
    print('Error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An unexpected error occurred')),
    );
  }
}
  
// Future<void> _editVehicleDialog(String id, Map<String, dynamic> vehicle) async {
//   // Variables to hold updated vehicle details
//   String updatedType = vehicle['type'];
//   String updatedNumberPlate = vehicle['numberPlate'];
//   String updatedDriverName = vehicle['drivername'];
//   String updatedDriverContact = vehicle['driverContact'];
//   String updatedNumberOfSeats = vehicle['numberofseats'];

//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Edit Vehicle'),
//         content: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               // Text fields to edit vehicle details
//               TextField(
//                 decoration: InputDecoration(labelText: 'Type'),
//                 onChanged: (value) {
//                   updatedType = value;
//                 },
//                 controller: TextEditingController(text: vehicle['type']),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Number Plate'),
//                 onChanged: (value) {
//                   updatedNumberPlate = value;
//                 },
//                 controller: TextEditingController(text: vehicle['numberPlate']),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Driver Name'),
//                 onChanged: (value) {
//                   updatedDriverName = value;
//                 },
//                 controller: TextEditingController(text: vehicle['drivername']),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Driver Contact'),
//                 onChanged: (value) {
//                   updatedDriverContact = value;
//                 },
//                 controller: TextEditingController(text: vehicle['driverContact']),
//               ),
//               TextField(
//                 decoration: InputDecoration(labelText: 'Number of Seats'),
//                 onChanged: (value) {
//                   updatedNumberOfSeats = value;
//                 },
//                 controller: TextEditingController(text: vehicle['numberofseats']),
//               ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Perform update operation here
//               _updateVehicle(id, updatedType, updatedNumberPlate, updatedDriverName, updatedDriverContact, updatedNumberOfSeats);
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: Text('Save'),
//           ),
//         ],
//       );
//     },
//   );
// }
// void _updateVehicle(String id, String updatedType, String updatedNumberPlate, String updatedDriverName, String updatedDriverContact, String updatedNumberOfSeats) async {
//   try {
//     // Create a Dio instance
//     Dio dio = Dio();

//     // Make an HTTP PUT request to update the vehicle data
//     final response = await dio.put(
//       '${ApiUrls.baseUrl}/updateVehicle/$id',
//       data: {
//         'type': updatedType,
//         'numberPlate': updatedNumberPlate,
//         'drivername': updatedDriverName,
//         'driverContact': updatedDriverContact,
//         'numberofseats': updatedNumberOfSeats,
//       },
//     );

//     // Check if the request was successful
//     if (response.statusCode == 200) {
//       // Vehicle updated successfully
//       print('Vehicle updated successfully');
//     } else {
//       // Request failed, show an error message
//       print('Failed to update vehicle data');
//     }
//   } catch (error) {
//     // Request failed, show an error message
//     print('Error updating vehicle data: $error');
//   }
// }
  Future<void> saveVehicleData({Vehicle? vehicle}) async {
    vehicleTypecontroller.text = vehicle?.type ?? '';
    vehicleNumberController.text = vehicle?.numberPlate ?? '';
    driverNameController.text = vehicle?.drivername ?? '';
    numberofseatsController.text = vehicle?.numberofseats ?? '';
    driverContactController.text = vehicle?.driverContact ?? '';
    bool isUpdate = vehicle != null;
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Data'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Vehicle Type'),
                    onChanged: (value) {
                      vehicleTypecontroller.text = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter vehicle type';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Vehicle Number'),
                    onChanged: (value) {
                      vehicleNumberController.text = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter vehicle number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Driver's Name"),
                    onChanged: (value) {
                      driverNameController.text = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter driver's name";
                      }
                      return null;
                    },
                  ),
                 TextFormField(
                decoration: InputDecoration(labelText: "Driver's Contact"),
                onChanged: (value) {
                  driverContactController.text = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter driver's contact";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Number of seats"),
                    onChanged: (value) {
                      numberofseatsController.text = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter Number of seats";
                      }
                      return null;
                    },
                     keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
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
                  if (_formKey.currentState!.validate()) {
                    await addvehicle();
                    _formKey.currentState!.reset();
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Padding(
          //   padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          //   child: Container(
          //     padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
          //     decoration: BoxDecoration(
          //       color: Color(0xffE7E7EE),
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     // child: Row(
          //     //   children: [
          //     //   //   Expanded(
          //     //   //     child: TextField(
          //     //   //       onChanged: (value) {
          //     //   //         setState(() {
          //     //   //           // searchInput = value;
          //     //   //         });
          //     //   //       },
          //     //   //       decoration: InputDecoration(
          //     //   //         hintText: 'Search here',
          //     //   //         hintStyle: TextStyle(
          //     //   //             fontFamily: "Poppins",
          //     //   //             fontWeight: FontWeight.w600,
          //     //   //             color: Color(0xff6B6B6B),
          //     //   //             fontSize: 16),
          //     //   //         border: InputBorder.none,
          //     //   //       ),
          //     //   //       cursorColor: Colors.black,
          //     //   //     ),
          //     //   //   ),
          //     //   //   IconButton(
          //     //   //  onPressed: () {
          //     //   //       // Handle search based on the 'searchInput'
          //     //   //       // You can modify your API call or filter the list locally
          //     //   //       // For simplicity, I'm filtering the list locally here
          //     //   //       setState(() {
          //     //   //         filteredVehiclePlaces =vehicles
          //     //   //             .where((place) =>
          //     //   //                 place.EventType.toLowerCase().contains(
          //     //   //                   searchInput.toLowerCase(),
          //     //   //                 ))
          //     //   //             .toList();
          //     //   //       });
          //     //   //     },
          //     //   //     icon: Icon(
          //     //   //       CupertinoIcons.search,
          //     //   //       color: Color(0xffA3A3A3),
          //     //   //       size: 25,
          //     //   //     ),
          //     //   //   ),
          //     //   ],
          //     // ),
          //   ),
          // ),
          Expanded(
            child: savedvehicle.isEmpty
                ? _buildEmptyChecklist()
                : _buildChecklist(),
          ),
        ],
      ),
    );
  }

Future<void> _deleteVehicle(String id) async {
  try {
    // Make the API call to delete the vehicle
    final response = await dio.delete('${ApiUrls.baseUrl}/deleteadminvehicle/$id');
    
    if (response.statusCode == 200) {
      // Vehicle deleted successfully
      // Update the UI by fetching the updated list of vehicles
      await fetchAllVehicles();
      // Optionally, you can also show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle deleted successfully'),
        ),
      );
    } else {
      // Failed to delete vehicle, handle the error
    }
  } catch (error) {
    // Error occurred, handle it appropriately
  }
}
  Widget _buildChecklist() {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(26, 0, 0, 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //                  Padding(
              //   padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              // ),
              Text(
                "Vehicle You Added",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F4434),
                ),
              ),
              GestureDetector(
                onTap: () {
                  saveVehicleData();
                },
                child: Icon(
                  CupertinoIcons.add_circled,
                  color: Color(0xFF09C7BE),
                  size: 40,
                ),
              ),
              // Icon(
              //   CupertinoIcons.add_circled,
              //   color: Color(0xFF09C7BE),
              //   size: 40,
              // ),
            ],
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
                itemCount: savedvehicle.length,
                itemBuilder: (context, index) {
                  final place = savedvehicle[index];

                  return GestureDetector(
                    // Add GestureDetector here

                    child: Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            height:
                                                5), // Add some spacing between text and icons
                                        Row(
                                          children: [
                                            // Add some spacing between icons
                                            // GestureDetector(
                                            //   onTap: () {
                                            // _editVehicleDialog(place['_id'].toString(), place);
                                            //   },
                                            //   child: Icon(
                                            //     CupertinoIcons.pencil,
                                            //     size: 30,
                                            //     color: Color(0xFF09C7BE),
                                            //   ),
                                            // ),
                                            // Add some spacing between icons
                                         GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this vehicle?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
             
  Navigator.of(context).pop(); // Close the dialog
  _deleteVehicle(place['_id']); // Call delete method with correct property name

print(place['_id']);// Call delete method
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
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
}
