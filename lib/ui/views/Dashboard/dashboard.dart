import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/navigation/CustomAppBar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tpi_mybi/ui/views/home.dart';

import '../Chat/chat.dart';
import 'trips.dart'; // Import your TripsScreen

class DashboardScreen extends StatefulWidget {
  final UserModel user;

  const DashboardScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // Initialize with the default index
   List<UserModel> models = [];

  // Create a list of pages to make it easier to manage
  final List<Widget> _pages = [
    TripsScreen(), // Replace with your actual home screen
    TripsScreen(), // Your trips screen
    ChatScreen(/*chatmodels: DataManager.instance.getUsers(), sourchat: DataManager.instance.userModel*/), // Replace with your messages screen
   // TripsScreen(), // Replace with your messages screen
    TripsScreen(), // Replace with your more options screen
  ];

  initState() {
    super.initState();
    DataLoader dataLoader = DataLoader.instance;
    DataManager dataManager = DataManager.instance;
    dataLoader.getUsers(dataManager.getToken());
    dataManager.addListener(_onResponse);
  }

  void _onResponse(DataManagerUpdateType type) {
    if (type == DataManagerUpdateType.getUsersSuccess) {
     // chatmodels = DataManager.instance.getUsers();
    }
  }



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
