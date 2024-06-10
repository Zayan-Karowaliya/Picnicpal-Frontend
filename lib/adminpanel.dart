import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';

class adminpanel extends StatefulWidget {
  const adminpanel({super.key});

  @override
  State<adminpanel> createState() => _adminpanelState();
}

class _adminpanelState extends State<adminpanel> {
    TextEditingController newNameController = TextEditingController();
    TextEditingController DescriptionController = TextEditingController();
    TextEditingController BriefController = TextEditingController();
    TextEditingController locationController = TextEditingController();
    TextEditingController Eventtypecontroller = TextEditingController();

    Future<void> _createChecklistItem() async {
      try {
        // Send data to the server using Dio
        final response = await Dio().post(
          '${ApiUrls.baseUrl}/addplace',
          data: {
            'Eventtype': Eventtypecontroller.text,
            'NameOfPlace': newNameController.text,
            'Brief': BriefController.text,
            'Description': DescriptionController.text,  
            'location': locationController.text,
            
          },
        );
  print(response);
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
    Future<void> _showAddDataDialog() async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Data'),
            content: SingleChildScrollView(
              child: Column(
                children: [
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
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(labelText: 'Location'),
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
              TextButton(
                onPressed: () {
                  // Call the function to create a checklist item
                  _createChecklistItem();
                  // Close the dialog
                  Navigator.of(context).pop();
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
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              _showAddDataDialog();
            },
            child: Icon(
              CupertinoIcons.pencil,
              size: 30,
              color: Color(0xFF09C7BE),
            ),
          ),
        ],
      ),
    );
  }
}