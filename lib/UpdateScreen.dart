import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:picnicpalfinal/apiclass.dart';

class UpdateScreen extends StatefulWidget {
  final String placeId;

  UpdateScreen({required this.placeId });

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Name:'),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter new name',
              ),
            ),
            SizedBox(height: 20),
            Text('Update Description:'),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter new description',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updatePlace();
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void updatePlace() async {
    try {
      String newName = nameController.text.trim();
      String newDescription = descriptionController.text.trim();

      // Add your API endpoint for updating the place
      String apiUrl = '${ApiUrls.baseUrl}/updateplace/${widget.placeId}';

      Response response = await dio.put(apiUrl, data: {
        'NameOfPlace': newName,
        'Description': newDescription,
      });

      if (response.statusCode == 200) {
        // Update successful
        // You can navigate back to the previous screen or show a success message
        Navigator.pop(context, true);
      } else {
        // Update failed
        // Show an error message or handle accordingly
        print('Update failed: ${response.data}');
      }
    } catch (error) {
      // Handle errors
      print('An error occurred: $error');
    }
  }
}