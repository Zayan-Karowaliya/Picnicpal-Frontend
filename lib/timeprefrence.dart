import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/adminhome.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/checklist.dart';
import 'package:picnicpalfinal/vehicles.dart';

class timeprefrence extends StatefulWidget {
 final String Placeid;
 final String token;

 timeprefrence({required this.Placeid, required this.token,super.key});
  @override
  State<timeprefrence> createState() => _timeprefrenceState();
}

class _timeprefrenceState extends State<timeprefrence> {
   final Dio dio = Dio();
  DateTime? selectedGoingTime;
  DateTime? selectedLeavingTime;


  
  Future<void> _selectGoingTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedGoingTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedGoingTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectLeavingTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLeavingTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          selectedLeavingTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }




  Future<void> setEventPreferences() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/time/${widget.Placeid}',
        data: {
          'token': widget.token,
           'goingTime': selectedGoingTime?.toString(), // Convert DateTime to string
        'leavingTime': selectedLeavingTime?.toString(),
        },
      );  

      if (response.statusCode == 200) {
        // Successfully set event preferences
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event preferences set successfully.'),
          ),
        );
 Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Homescreen(),
              ),
            );
        // Navigate back to the home screen or any other screen as needed
        Navigator.pop(context);
      } else {
        // Handle error cases
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set event preferences. Please try again.'),
          ),
        );
      }
    } on DioError catch (e) {
      // Handle Dio errors or exceptions
      // ... handle Dio errors ...
    } catch (e) {
      // Handle other errors
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  body: Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Select Your Time',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                 await  _selectGoingTime();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434), minimumSize: Size(150, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Going Time",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  await _selectLeavingTime();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434), minimumSize: Size(150, 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "leaving Time",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await setEventPreferences();
               Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Vehiclelist(),
              ),
            );
            },  
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Color(0xFF1F4434), minimumSize: Size(200, 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Set Preference",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}