import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/secrets.dart';
import 'secrets.dart';
import 'additional_info_item.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  // Fetch weather data dynamically
  Future<Map<String, dynamic>> getCurrentWeather() async {
    String cityName = 'Ghaziabad';
    final res = await http.get(
      Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIkey'),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Weather App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              setState(() {}); // Refresh data
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];

          // Convert temperature from Kelvin to Celsius
          final currentTemp =
              (currentWeatherData['main']['temp'] - 273.15).toStringAsFixed(1);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp°C', // Updated to Celsius
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                (currentSky == 'Rain' || currentSky == 'Clouds')
                                    ? Icons.cloud
                                    : Icons.wb_sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < 38; i++)
                        HourlyForecastItem(
                          time: data['list'][i + 1]['dt_txt'].toString(),
                          icon: (data['list'][i + 1]['weather'][0]['main'] ==
                                      'Rain' ||
                                  data['list'][i + 1]['weather'][0]['main'] ==
                                      'Clouds')
                              ? Icons.cloud
                              : Icons.wb_sunny,
                          temperature:
                              '${(data['list'][i + 1]['main']['temp'] - 273.15).toStringAsFixed(1)}°C',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    additional_info_item(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$currentHumidity%', // Added '%' for clarity
                    ),
                    additional_info_item(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value:
                          '$currentWindSpeed m/s', // Added 'm/s' for wind speed
                    ),
                    additional_info_item(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: '$currentPressure hPa', // Added 'hPa' for pressure
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
