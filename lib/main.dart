import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wear/wear.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evaluation',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.compact,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Dance(),
        ),
      ),
    );
  }
}

class Dance extends StatelessWidget {
  const Dance({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return DanceTwo(mode);
          },
        );
      },
    );
  }
}

class DanceTwo extends StatefulWidget {
  final WearMode mode;

  const DanceTwo(this.mode, {super.key});

  @override
  _DanceTwoState createState() => _DanceTwoState();
}

class WeatherAPI {
  static const apiKey = '975ecea8733bd0c74f486c5ec049fe78';
  static const baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> fetchWeatherData(String cityName) async {
    final url = Uri.parse('$baseUrl/weather?q=$cityName&appid=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Fallo al conseguir datos del clima');
    }
  }
}

class _DanceTwoState extends State<DanceTwo> {
  late DateTime _currentTime;
  String cityName =
      'Mexico City'; // Nombre de la ciudad para obtener el pronóstico del clima
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final data = await WeatherAPI.fetchWeatherData(cityName);
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      print(e);
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().toUtc().subtract(const Duration(hours: 6));
    });

    Timer(
      const Duration(seconds: 1) -
          Duration(milliseconds: _currentTime.millisecond),
      _updateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fTime = DateFormat('hh:mm:ss a');
    final finalDate = DateFormat('MMM dd, yyyy').format(_currentTime);
    final finalTime = fTime.format(_currentTime);

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              widget.mode == WearMode.active
                  ? 'assets/dance01.gif'
                  : 'assets/dance02.gif',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 10),
            Text(
              finalTime,
              style: TextStyle(
                color: widget.mode == WearMode.active
                    ? Colors.black
                    : Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dosis',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              finalDate,
              style: TextStyle(
                color: widget.mode == WearMode.active
                    ? Colors.black
                    : Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Dosis',
              ),
            ),
            Text('Ciudad: ${weatherData['name']}',
                style: TextStyle(
                  color: widget.mode == WearMode.active
                      ? Colors.black
                      : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dosis',
                )),
            Text('Temperatura: ${weatherData['main']['temp']}',
                style: TextStyle(
                  color: widget.mode == WearMode.active
                      ? Colors.black
                      : Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dosis',
                )),
          ],
        ),
      ),
    );
  }
}
