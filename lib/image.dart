import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:picnicpalfinal/apiclass.dart';

class img extends StatefulWidget {
  const img({super.key});

  @override
  State<img> createState() => _imgState();
}

class _imgState extends State<img> {
   File? selectedFile;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) {
      // No file selected
      return;
    }

    final url = '${ApiUrls.baseUrl}/uploadimg'; // Replace with your Node.js API endpoint

    try {
      Dio dio = Dio();
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          selectedFile!.path,
          filename: selectedFile!.path.split('/').last,
        ),
      });

      Response response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: Text('File Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedFile != null
                ? Text('Selected File: ${selectedFile!.path}')
                : Text('No file selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickFile,
              child: Text('Pick File'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload File'),
            ),
          ],
        ),
),
);

  }
}

