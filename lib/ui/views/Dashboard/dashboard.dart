import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/main.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:tpi_mybi/ui/views/Profile/profile.dart';
import 'package:tpi_mybi/ui/views/home.dart';
import '../../../Data/SaveDataManager.dart';
import '../Chat/chat.dart';
import '../Login/login.dart';
import 'trips.dart'; // Import your TripsScreen
import 'package:tpi_mybi/ui/views/Dashboard/DriverAccepted.dart';
import 'PassangerAccepted.dart';
import 'driver_map_screen.dart';
import 'trips.dart';

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
    ProfilePage(user: DataManager.instance.getUser()), // Replace with your more options screen
    //TripsScreen(),
   // testing(),
  //  PassangerAccepted(DriverID:20),
   // DriverAccepted(),
    // Replace with your actual home screen
   // Your trips screen
    //webrtc(), // Replace with your messages screen
  //  FakeDataReceiver(), // Replace with your more options screen
  ];

  initState() {
    super.initState();
    SaveDataManager().getToken();
    DataLoader dataLoader = DataLoader.instance;
    DataManager dataManager = DataManager.instance;
  //  dataLoader.getUsers(DataManager.instance.getToken());
    dataLoader.getLatestMessages(DataManager.instance.getUser().userID);
    dataManager.addListener(_onResponse);
  }

  void _onResponse(DataManagerUpdateType type) {
    if (type == DataManagerUpdateType.getUsersSuccess) {
     // chatmodels = DataManager.instance.getUsers();
    }
    else if (type == DataManagerUpdateType.getLatestMessagesError || type == DataManagerUpdateType.getUsersError) {
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      );
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
          Icon(Icons.account_circle, size: 30),
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
