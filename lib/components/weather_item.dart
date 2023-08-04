import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeatherItem extends StatelessWidget {
  final int value;
  final String unit;
  final String imageUrl;

  const WeatherItem({
    super.key, required this.value, required this.unit, required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                height: 55,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Image.asset(imageUrl,/*height: 40*/),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Text(value.toString() + unit ,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 17),)
            ],
          ),
        ),
      ],
    );
  }
}
