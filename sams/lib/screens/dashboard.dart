import 'dart:async';
import 'package:flutter/material.dart';
import 'package:e_clearance/api_service.dart'; // Adjust import path as per your project
import 'dart:math';
import 'package:e_clearance/widgets/zoomable.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    Key? key,
  }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/4.jpg', // Replace with your image path
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 120),
                        Text(
                          'Dashboard',
                          style:
                              Theme.of(context).textTheme.headline5?.copyWith(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is dashboard',
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white, // White color for the rest of the screen
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40 - 80,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 150,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: const Color(0xFF4B49AC),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title of the Card',
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Some content goes here. You can add more widgets inside the card as needed.',
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(),
          // ZoomableCard()
        ],
      ),
    );
  }
}
