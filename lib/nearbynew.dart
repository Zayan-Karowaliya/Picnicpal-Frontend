import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class NearbyRestaurantsScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  NearbyRestaurantsScreen({required this.latitude, required this.longitude});
  @override
  _NearbyRestaurantsScreenState createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  List<dynamic> _restaurants = [];
  List<dynamic> _filteredRestaurants = []; // List to store filtered restaurants
  String _searchQuery = ''; // Variable to store the search query
  String _selectedFilter = 'Rating'; // Variable to store the selected filter

  // Variable to store selected restaurant reviews
  List<dynamic> _selectedRestaurantReviews = [];

  @override
  void initState() {
    super.initState();
    fetchNearbyRestaurants();
  }

  Future<void> fetchNearbyRestaurants() async {
    final apiUrl = 'http://192.168.1.105:3000/nearby'; // Change to your server URL
    try {
      final response = await Dio().post(
        apiUrl,
        data: {
          'latitude': widget.latitude.toString(),
          'longitude': widget.longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Successful API call
        final jsonData = response.data;
        setState(() {
          _restaurants = List<dynamic>.from(jsonData['nearbyRestaurants']);
          _filteredRestaurants = _restaurants; // Initialize filtered restaurants with all restaurants
        });
      } else {
        // Error handling
        print('Failed to load nearby restaurants');
      }
    } catch (error) {
      // Error handling
      print('Error fetching nearby restaurants: $error');
    }
  }

  // Function to handle button click to show comments
  void _showComments(List<dynamic> reviews) {
    setState(() {
      _selectedRestaurantReviews = reviews;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (final review in reviews)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Author: ${review['author_name']}'),
                      Text('Rating: ${review['rating']}'),
                      Text('Comment: ${review['text']}'),
                      Divider(), // Add a divider between comments
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
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to filter restaurants based on selected filter
  void _filterRestaurants(String filter) {
    setState(() {
      _selectedFilter = filter;
      // Sort restaurants based on selected filter
      if (filter == 'Rating') {
        _filteredRestaurants.sort((a, b) => b['rating'].compareTo(a['rating']));
      } else if (filter == 'Name') {
        _filteredRestaurants.sort((a, b) => a['name'].compareTo(b['name']));
      }
    });
  }

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Restaurants'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterRestaurants,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Rating',
                child: Text('Sort by Rating'),
              ),
              PopupMenuItem<String>(
                value: 'Name',
                child: Text('Sort by Name'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _filteredRestaurants[index];
          final name = restaurant['name'];
          final vicinity = restaurant['vicinity'];
          final rating = restaurant['rating']?.toString();
          final isOpen = restaurant['opening_hours'] != null &&
              restaurant['opening_hours']['open_now'] == true;
          final latitude = restaurant['geometry']['location']['lat'];
          final longitude = restaurant['geometry']['location']['lng'];
          final reviews = restaurant['reviews'];
          final imageUrls = restaurant['imageUrls'];
          final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoogleMapScreen(
                     userLatitude: double.parse(widget.latitude),
                    userLongitude: double.parse(widget.longitude),
                    restaurantLatitude: latitude,
                    restaurantLongitude: longitude,
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                name ?? 'Restaurant Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vicinity ?? 'Address not available'),
                  Text('Rating: ${rating ?? "N/A"}'),
                  Text(isOpen ? 'Open Now' : 'Closed'),
                ],
              ),
              leading: GestureDetector(
                onTap: () {
                  if (imageUrl != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Image.network(imageUrl),
                        );
                      },
                    );
                  }
                },
                child: CircleAvatar(
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl == null ? Icon(Icons.restaurant) : null,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.comment),
                onPressed: () {
                  if (reviews != null) {
                    _showComments(reviews);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Comments'),
                          content: Text('No comments available.'),
                          actions: <Widget>[
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
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
class GoogleMapScreen extends StatelessWidget {
final double userLatitude;
  final double userLongitude;
  final double restaurantLatitude;
  final double restaurantLongitude;

  const GoogleMapScreen({
    Key? key,
     required this.userLatitude,
    required this.userLongitude,
    required this.restaurantLatitude,
    required this.restaurantLongitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('Latitude: $latitude');
    // print('Longitude: $longitude');
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(userLatitude, userLongitude),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('SelectedLocation'),
                  position: LatLng(restaurantLatitude, restaurantLongitude),
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _launchDirections(userLatitude, userLongitude, restaurantLatitude, restaurantLongitude);
            },
            child: Text('Get Directions'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchDirections(double userLat, double userLng, double restaurantLat, double restaurantLng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$restaurantLat,$restaurantLng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}