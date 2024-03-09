import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/navigation/CustomAppBar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tpi_mybi/ui/views/Dashboard/full_map.dart';

import 'package:tpi_mybi/ui/views/home.dart';

import 'DriverRequestsPage.dart';
import 'driver_map_screen.dart';
import 'mapbox.dart';
import 'trips.dart'; // Import your TripsScreen

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Initialize with the default index

  // Create a list of pages to make it easier to manage
  final List<Widget> _pages = [
    TripsScreen(),
    DriverRequestsPage(),
    // Replace with your actual home screen
    FullMapPage(), // Your trips screen
  //  FakeDataSender(), // Replace with your messages screen
  //  FakeDataReceiver(), // Replace with your more options screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.location_pin, size: 30),
          Icon(Icons.message, size: 30),
          Icon(Icons.more_vert, size: 30),
        ],
        color: myPrimaryColor,
        buttonBackgroundColor: myPrimaryColor,
        backgroundColor: Colors.transparent,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
