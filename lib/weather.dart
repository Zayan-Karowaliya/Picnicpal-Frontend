import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picnicpalfinal/HomePagefinal.dart';
import 'package:picnicpalfinal/Login.dart';
import 'package:picnicpalfinal/apiclass.dart';
import 'package:picnicpalfinal/drawe.dart';
import 'package:picnicpalfinal/nearbynew.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:io' show Platform;

import 'package:weather_icons/weather_icons.dart';

class weather extends StatefulWidget {
  const weather({super.key});

  @override
  State<weather> createState() => _weatherState();
}

class _weatherState extends State<weather> {
  late String token;
  late String username = '';
  late String email = '';
  List<Map<String, dynamic>> savedEvents = [];
  final Dio dio = Dio();
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  Map<String, int> unreadMessageCounts = {};
  List<Map<String, dynamic>> _restaurants = [];
  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false, // This makes sure to remove all previous routes
    );
  }

  Future<void> _loadToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedToken = prefs.getString('token');

    if (storedToken != null) {
      setState(() {
        token = storedToken;
      });
      getSavedPlaces(); // Call _loadChecklistItems after setting the token
    } else {
      // Token not found, handle accordingly (e.g., navigate to login page)
      print('Token not found');
    }
  }

  Future<void> getSavedPlaces() async {
    try {
      final response = await dio.post(
        '${ApiUrls.baseUrl}/getsaveevent',
        data: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          savedEvents = List<Map<String, dynamic>>.from(
            response.data['savedEvents'],
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
Future<void> _showWeatherDialog(BuildContext context, String lat, String lon, String leavingTime) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Loading...'),
        content: CircularProgressIndicator(),
      );
    },
  );

  try {
    final response = await Dio().get(
      '${ApiUrls.baseUrl}/getweather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
      },
    );
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final forecastData = response.data['list'];

      // Group forecast by date
      final Map<String, List> groupedForecast = {};
      for (var forecast in forecastData) {
        final date = DateTime.parse(forecast['dt_txt']).toLocal();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!groupedForecast.containsKey(dateKey)) {
          groupedForecast[dateKey] = [];
        }
        groupedForecast[dateKey]?.add(forecast);
      }

      // Get the next three days
      final nextThreeDays = groupedForecast.keys.take(3).toList();

      // Parse the leaving time
      final DateTime now = DateTime.now();
      final DateTime leavingDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(leavingTime);
      final DateTime fullLeavingDateTime = DateTime(
        now.year, now.month, now.day, leavingDateTime.hour, leavingDateTime.minute);

      // Generate suggestions based on weather conditions closest to the leaving time
      Map<String, String> dailySuggestions = {};
      Map<String, List<String>> dailyAllSuggestions = {}; // to store all suggestions for each day

      for (final day in nextThreeDays) {
        final dailyForecasts = groupedForecast[day];
        DateTime closestForecastTime = DateTime.parse(dailyForecasts![0]['dt_txt']);
        var closestForecast = dailyForecasts[0];
        var minTimeDifference = (closestForecastTime.hour - fullLeavingDateTime.hour).abs() * 60 +
            (closestForecastTime.minute - fullLeavingDateTime.minute).abs();

        for (final forecast in dailyForecasts) {
          final forecastTime = DateTime.parse(forecast['dt_txt']);
          final timeDifference = (forecastTime.hour - fullLeavingDateTime.hour).abs() * 60 +
              (forecastTime.minute - fullLeavingDateTime.minute).abs();

          if (timeDifference < minTimeDifference) {
            minTimeDifference = timeDifference;
            closestForecast = forecast;
            closestForecastTime = forecastTime;
          }
        }

        // Analyze weather conditions for the closest forecast time
        final temperature = closestForecast['main']['temp'];
        final precipitationProbability = closestForecast['clouds']['all'] / 100;
        final windSpeed = closestForecast['wind']['speed'];
        final seaLevel = closestForecast['main']['sea_level'];
        final realfeel=closestForecast['main']['feels_like'];
        // Generate suggestion for the closest time
        String suggestionForClosestTime = 'For $day: ';

        if (precipitationProbability > 0.5) {
          suggestionForClosestTime += 'It is raining at ${DateFormat('HH:mm').format(closestForecastTime)}. ';
        }
        if (temperature > 30||realfeel>40) {
          suggestionForClosestTime += 'It is too hot at ${DateFormat('HH:mm').format(closestForecastTime)}. ';
        }
        if (windSpeed > 30) {
          suggestionForClosestTime += 'It is stormy at ${DateFormat('HH:mm').format(closestForecastTime)}. ';
        }
        if (seaLevel > 1005) {
          suggestionForClosestTime += 'The sea level is high at ${DateFormat('HH:mm').format(closestForecastTime)}. ';
        }
        if (suggestionForClosestTime == 'For $day: ') {
          suggestionForClosestTime += 'It looks like a normal day at ${DateFormat('HH:mm').format(closestForecastTime)}. You can enjoy the trip!';
        }

        dailySuggestions[day] = suggestionForClosestTime;

        // Store all suggestions for the day excluding the suggestion for the closest time
        dailyAllSuggestions[day] = dailyForecasts.map((forecast) {
          String suggestion = '';

        

          return suggestion;
        }).toList();
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Weather Forecast'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Three Days Weather:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...nextThreeDays.map((dateKey) {
                      final dailyForecasts = groupedForecast[dateKey];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: $dateKey',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),

                          SizedBox(height: 20,),
                       Text('Suggestion for Your Leaving Time: ${dailySuggestions[dateKey] != null && dateKey == DateFormat('yyyy-MM-dd').format(leavingDateTime) ? dailySuggestions[dateKey] : "No suggestion available."}'),
                          SizedBox(height: 20,),
                          Text('Average suggestion for the day: ${_calculateAverageSuggestion(groupedForecast[dateKey]!, leavingDateTime)}'),

                          ...dailyForecasts!.map((forecast) {
                            final dateTime = DateTime.parse(forecast['dt_txt']);
                            final description = forecast['weather'][0]['description'];
                            final temperature = forecast['main']['temp'];
                            final humidity = forecast['main']['humidity'];
                            final feelsLike = forecast['main']['feels_like'];
                            final iconCode = forecast['weather'][0]['icon'];

                            const Color sunnyColor = Colors.yellow;
                            const Color cloudyColor = Colors.grey;
                            const Color rainyColor = Colors.blue;
                            const Color thunderstormColor = Colors.red;
                            const Color snowyColor = Colors.white;
                            const Color foggyColor = Colors.grey;

                            IconData weatherIcon;
                            Color iconColor;

                            switch (iconCode) {
                              case '01d':
                              case '01n':
                                weatherIcon = WeatherIcons.day_sunny;
                                iconColor = sunnyColor;
                                break;
                              case '02d':
                              case '02n':
                                weatherIcon = WeatherIcons.day_cloudy;
                                iconColor = cloudyColor;
                                break;
                              case '03d':
                              case '03n':
                                weatherIcon = WeatherIcons.cloud;
                                iconColor = cloudyColor;
                                break;
                              case '04d':
                              case '04n':
                                weatherIcon = WeatherIcons.cloudy;
                                iconColor = cloudyColor;
                                break;
                              case '09d':
                              case '09n':
                                weatherIcon = WeatherIcons.rain;
                                iconColor = rainyColor;
                                break;
                              case '10d':
                              case '10n':
                                weatherIcon = WeatherIcons.day_rain;
                                iconColor = rainyColor;
                                break;
                              case '11d':
                              case '11n':
                                weatherIcon = WeatherIcons.thunderstorm;
                                iconColor = thunderstormColor;
                                break;
                              case '13d':
                              case '13n':
                                weatherIcon = WeatherIcons.snow;
                                iconColor = snowyColor;
                                break;
                              case '50d':
                              case '50n':
                                weatherIcon = WeatherIcons.fog;
                                iconColor = foggyColor;
                                break;
                              default:
                                weatherIcon = WeatherIcons.day_sunny;
                                iconColor = sunnyColor;
                            }

                            return ListTile(
                              leading: Icon(weatherIcon, size: 40, color: iconColor),
                              title: Text('${DateFormat('kk:mm').format(dateTime)}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Condition: $description'),
                                  Text('Temperature: $temperature°C'),
                                  Text('Humidity: $humidity%'),
                                  Text('Feels Like: $feelsLike°C'),
                                ],
                              ),
                            );
                          }).toList(),
                          Divider(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Failed to fetch forecast data');
      Navigator.of(context).pop(); // Dismiss the loading dialog
    }
  } catch (error) {
    print('Error fetching forecast data: $error');
    Navigator.of(context).pop(); // Dismiss the loading dialog
  }
}
 
String _calculateAverageSuggestion(List forecasts, DateTime leavingDateTime) {
  // Accumulate suggestions for the day
  var totalSuggestions = '';
  var count = 0;

  for (final forecast in forecasts) {
    final forecastTime = DateTime.parse(forecast['dt_txt']);
    if (forecastTime != leavingDateTime) {
      // Analyze weather conditions for this forecast
      var suggestion = '';

      // Weather condition analysis code
      final temperature = forecast['main']['temp'];
      final precipitationProbability = forecast['clouds']['all'] / 100;
      final windSpeed = forecast['wind']['speed'];
      final seaLevel = forecast['main']['sea_level'];

      // Generate suggestion based on weather conditions
      if (precipitationProbability > 0.5) {
        suggestion += 'Raining at ${DateFormat('HH:mm').format(forecastTime)}. ';
      }
      if (temperature > 40) {
        suggestion += 'Too hot at ${DateFormat('HH:mm').format(forecastTime)}. ';
      }
      if (windSpeed > 30) {
        suggestion += 'Stormy at ${DateFormat('HH:mm').format(forecastTime)}. ';
      }
      if (seaLevel > 1005) {
        suggestion += 'High sea level at ${DateFormat('HH:mm').format(forecastTime)}. ';
      }

      // Add suggestion if conditions warrant it
      if (suggestion.isNotEmpty) {
        if (totalSuggestions.isNotEmpty) {
          totalSuggestions += ' ';
        }
        totalSuggestions += suggestion;
        count++;
      }
    }
  }

  // Return the accumulated suggestions or a message if no significant conditions found
  if (count == 0) {
    return 'Looks good for The Day.';
  } else {
    return totalSuggestions;
  }
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          return false; // Returning false will prevent the back operation
        },
        child: Scaffold(
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
                      "Weather condition",
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
              Expanded(
                child: savedEvents.isEmpty
                    ? _buildEmptyChecklist()
                    : _buildChecklist(),
              ),
            ],
          ),
        ));
  }

  Widget _buildChecklist() {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(26, 0, 0, 10),
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
                itemCount: savedEvents.length,
                itemBuilder: (context, index) {
                  final place = savedEvents[index];

                  return GestureDetector(
                    onTap: () {
                      final lat = place['latitude'];
                      final lon = place['longitutde'];
                      String leavingTime = place['LeavingTime'] ?? '';
                      print(lat);
                      print(lon);
                      print(leavingTime);
                      _showWeatherDialog(context, lat, lon, leavingTime);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.fromLTRB(5, 30, 5, 30),
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
                                ' ${place['NameOfPlace']}',
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1F4434),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    ' ${place['location']}',
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  SizedBox(height: 8),
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
