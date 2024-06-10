import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';

class PlacesListScreen extends StatefulWidget {
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  late List<Place> placesWithImages;
  late Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    placesWithImages = [];
    _fetchPlacesWithImages();
  }

  Future<void> _fetchPlacesWithImages() async {
    try {
      var response = await dio.get('${ApiUrls.baseUrl}/getall'); // Update with your actual endpoint

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<Place> places = data.map((item) {
          String image = item['image'] ?? ''; // Update with your actual field name
          return Place.fromJson(item, image: image);
        }).toList();

        setState(() {
          placesWithImages = places;
        });
      } else {
        // Handle error case
        print('Failed to fetch places. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places List'),
      ),
      body: ListView.builder(
        itemCount: placesWithImages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(placesWithImages[index].name),
            subtitle: Text(placesWithImages[index].description),
            leading: Image.network(
             placesWithImages[index].image,
              width: 50,
              height: 50,
            ),
          );
        },
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
        image: '${ApiUrls.baseUrl}/uploads/$image',

    );
  }
}





