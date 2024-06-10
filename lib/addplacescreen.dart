import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/placelistscreem.dart';

class AddPlaceScreen extends StatefulWidget {
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  late TextEditingController eventTypeController = TextEditingController();
  late TextEditingController nameController = TextEditingController();
  late TextEditingController briefController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late TextEditingController numberOfPeopleController = TextEditingController();
  late TextEditingController locationController = TextEditingController();
  late Dio dio;

  File? file;

  @override
  void initState() {
    super.initState();
    dio = Dio();
  }

  Future<void> _uploadPlace() async {
    if (file == null) {
      // Show an error message, file is required
      return;
    }

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file!.path,
          filename: 'place_file.${file!.path.split('.').last}',
        ),
        'EventType': eventTypeController.text,
        'NameOfPlace': nameController.text,
        'Brief': briefController.text,
        'Description': descriptionController.text,
        'NumberOfPeople': numberOfPeopleController.text,
        'location': locationController.text,
      });

      var response = await dio.post(
        '${ApiUrls.baseUrl}/addplace',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Place added successfully
        print('Place added successfully');
        // You can handle the response if needed
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlacesListScreen()),
      );
      } else {
        // Handle error case
        print('Failed to add place. Status code: ${response.statusCode}');
      }

      // After uploading, fetch places with images
      
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
  }

  // Future<void> _fetchPlacesWithImages() async {
  //   try {
  //     var response =
  //         await dio.get('http://192.168.1.106:3000/getall'); // Update with your actual endpoint

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data;
  //       List<Place> placesWithImages = data.map((item) {
  //         // Assuming 'imageUrl' is the field where the image URL is stored in your response
  //         String image = item['image'] ?? ''; // Update with your actual field name
  //         return Place.fromJson(item, image: image);
  //       }).toList();

  //       // Now you have 'placesWithImages' list containing Place objects with image URLs
  //       print('Places with images: $placesWithImages');
  //     } else {
  //       // Handle error case
  //       print('Failed to fetch places. Status code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     // Handle exceptions
  //     print('Error: $error');
  //   }
  // }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: eventTypeController,
              decoration: InputDecoration(labelText: 'Event Type'),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: briefController,
              decoration: InputDecoration(labelText: 'Brief'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            // File picker
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
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadPlace,
              child: Text('Upload Place'),
            ),
          ],
        ),
      ),
    );
  }
}

class Place {
  final String id;
  String eventType;
  String name;
  String description;
  String brief;
  int ?numberOfPeople;
  String location;
  String image; // Added imageUrl field

  Place({
    required this.id,
    required this.eventType,
    required this.name,
    required this.description,
    required this.brief,
    required this.numberOfPeople,
    required this.location,
    required this.image,
  });

  factory Place.fromJson(Map<String, dynamic> json, {String image = ''}) {
    return Place(
      id: json['_id'],
      eventType: json['EventType'],
      name: json['NameOfPlace'],
      description: json['Description'],
      brief: json['Brief'],
      numberOfPeople: json['NumberOfPeople'] as int?,
      location: json['location'],
      image: image,
    );
  }
}
