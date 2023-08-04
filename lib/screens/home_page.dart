import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:light_modal_bottom_sheet/light_modal_bottom_sheet.dart';
import 'package:weather/constants.dart';

import '../components/weather_item.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();
  static String apiKey = "8a9063050049490aa4352233230308";

  String location = "Turkey"; //varsayılan konum
  String weatherIcon = "heavycould.png";
  int temperature = 0;
  int windspeed = 0;
  int humidity = 0;
  int cloud = 0;
  String currentDate = '';

  List hourlyWeatherForcast = [];
  List dailyWeatherForcast = [];

  String currentWeatherStatus = '';

  //API call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      apiKey +
      "&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult =
          await http.get(Uri.parse(searchWeatherAPI + searchText));

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');
      var locationData = weatherData["location"];

      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);

        var parsedDate =
            DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('EEEE, MMM d').format(parsedDate);
        currentDate = newDate;

        //updateweather
        currentWeatherStatus = currentWeather["condition"]["text"];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', ' ').toLowerCase() + ".png";
        temperature = currentWeather["temp_c"].toInt();
        windspeed = currentWeather["wind_kph"].toInt();
        humidity = currentWeather["humidity"].toInt();
        cloud = currentWeather["cloud"].toInt();

        //forecast data
        dailyWeatherForcast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForcast = dailyWeatherForcast[0]["hour"];
        print(dailyWeatherForcast);
      });
    } catch (e) {}
  }

  //fonksiyon konumunun ilk iki adını döndürme işlevi
  static String getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(location);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(
          top: 70,
          left: 20 ,
          right:20 ,
        ),
        color: _constants.primaryColor.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 9, right: 9, bottom: 50),
              height: size.height - 320,
              decoration: BoxDecoration(
                  gradient: _constants.linearGradiantBlue,
                  boxShadow: [
                    BoxShadow(
                        color: _constants.primaryColor.withOpacity(.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3)),
                  ],
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/images/menu.png",
                          width: 40,
                          height: 40,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "lib/images/pin.png",
                              width: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              location,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            IconButton(
                                onPressed: () {
                                  _cityController.clear();
                                  showMaterialModalBottomSheet(
                                      context: context,
                                      builder: (context) =>
                                          SingleChildScrollView(
                                            //controller: ModalScrollController.of(context),
                                            child: Container(
                                              height: size.height * .1,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    child: Divider(
                                                      thickness: 3.5,
                                                      color: _constants
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  /*const SizedBox(
                                                    height: 5,
                                                  ),*/
                                                  TextField(
                                                    onChanged: (searchText) {
                                                      fetchWeatherData(
                                                          searchText);
                                                    },
                                                    controller: _cityController,
                                                    autofocus: true,
                                                    decoration: InputDecoration(
                                                        prefixIcon: Icon(
                                                          Icons.search,
                                                          color: _constants
                                                              .primaryColor,
                                                        ),
                                                        suffixIcon:
                                                            GestureDetector(
                                                          onTap: () =>
                                                              _cityController
                                                                  .clear(),
                                                          child: Icon(
                                                            Icons.close,
                                                            color: _constants
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                        hintText:
                                                            'Search city e.g. Turkey',
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: _constants
                                                                  .primaryColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ));
                                },
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "lib/images/profile.png",
                            width: 40,
                            height: 40,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 145,
                    child: Image.asset("lib/images/" + weatherIcon),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0,left: 25),
                        child: Text(
                          temperature.toString(),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = _constants.shader,
                          ),
                        ),
                      ),
                      Text(
                        "°",
                        style: TextStyle(
                          fontSize: 75,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currentWeatherStatus,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 2,),
                  Text(
                    currentDate,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 10, ),
                      child: const Divider(
                        thickness: 1,
                        color: Colors.white70,
                      )),
                  Container(
                    height: size.height * .12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WeatherItem(
                          value: windspeed.toInt(),
                          unit: 'km/h',
                          imageUrl: "lib/images/windspeed.png",
                        ),
                        WeatherItem(
                          value: humidity.toInt(),
                          unit: "%",
                          imageUrl: "lib/images/humidity.png",
                        ),
                        WeatherItem(
                          value: cloud.toInt(),
                          unit: '%',
                          imageUrl: "lib/images/cloud.png",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailPage(
                                      dailyForecastWeather: dailyWeatherForcast,
                                    ))),
                        child: Text(
                          'Forecasts',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: _constants.primaryColor),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: hourlyWeatherForcast.length,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        String currentTime =
                            DateFormat('HH:mm:ss').format(DateTime.now());
                        String currentHour = currentTime.substring(0, 2);

                        String forecastTime = hourlyWeatherForcast[index]
                                ["time"]
                            .substring(11, 16);
                        String forecastHour = hourlyWeatherForcast[index]
                                ["time"]
                            .substring(11, 13);

                        String forecastWeatherName =
                            hourlyWeatherForcast[index]["condition"]["text"];
                        String forecastWeatherIcon = forecastWeatherName
                                .replaceAll(" ", " ")
                                .toLowerCase() +
                            ".png";

                        String forecastTemperature = hourlyWeatherForcast[index]
                                ["temp_c"]
                            .round()
                            .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          margin: const EdgeInsets.only(right: 20),
                          width: 65,
                          decoration: BoxDecoration(
                              color: currentHour == forecastHour
                                  ? Colors.white
                                  : _constants.primaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              boxShadow: [
                                BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 5,
                                    color: _constants.primaryColor
                                        .withOpacity(.2)),
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                forecastTime,
                                style: TextStyle(
                                    color: _constants.greyColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500),
                              ),
                              Image.asset(
                                'lib/images/' + forecastWeatherIcon,
                                width: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    forecastTemperature,
                                    style: TextStyle(
                                        color: _constants.greyColor,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "°",
                                    style: TextStyle(
                                        color: _constants.greyColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                        fontFeatures: const [
                                          FontFeature.enable(('sups')),
                                        ]),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
