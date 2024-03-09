import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../Data/DataManager.dart';
import '../../../model/User.dart';

class ListDriverTrips extends StatefulWidget {
  final double departLat;
  final double departLong;
  final double destLat;
  final double destLong;

  ListDriverTrips({
    required this.departLat,
    required this.departLong,
    required this.destLat,
    required this.destLong,
  });

  @override
  _ListDriverTripsState createState() => _ListDriverTripsState();
}

class _ListDriverTripsState extends State<ListDriverTrips> {
  late IO.Socket socket;
  List<dynamic> drivers = [];

  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Initialize the socket and fetch drivers when the screen is initialized
    initializeSocketAndFetchDrivers();
  }

  // Initialize socket and fetch drivers
  void initializeSocketAndFetchDrivers() {
    socket = IO.io('wss://integrationlalabi.azurewebsites.net:443', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    fetchDrivers();

    socket.onConnect((_) {
      fetchDrivers();
      // Start timer to periodically fetch drivers
      timer = Timer.periodic(Duration(seconds: 3), (Timer t) => fetchDrivers());
    });
    socket.on('callDrivers', (data) {
      print('callDrivers callDrivers callDrivers: $data');

      fetchDrivers();

    });
    socket.on('drivers', (data) {
      print('rani dkholt: $data');

      setState(() {
       // drivers.clear();
        drivers = List.from(data);
      });
    });
  }

  // Function to fetch drivers from the server
  void fetchDrivers() {
    print('rani dkholt:AAAAAAAAAAAAAAA ');

    socket.emit('getDrivers', {
      'originLat': widget.departLat,
      'originLong': widget.departLong,
      'destinationLat': widget.destLat,
      'destinationLong': widget.destLong,
    });
  }

  // Function to reset the list of drivers
  void resetDriversList() {
    setState(() {
      drivers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Wrap the scaffold with WillPopScope to intercept back button press
      onWillPop: () async {
        UserModel user = DataManager.instance.getUser();

        print('deletePassenger ');
        socket.emit('deletePassenger', user.uid);

        // Disconnect from the socket when the user presses the back button
        socket.disconnect();
        resetDriversList();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Driver Trips'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text('Drivers:'),
              Expanded(
                child: ListView.builder(
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    final userId = driver['userId'] ?? 'Unknown';
                    final originLat = driver['originLat'] ?? 0.0;
                    final originLong = driver['originLong'] ?? 0.0;
                    final destinationLat = driver['destinationLat'] ?? 0.0;
                    final destinationLong = driver['destinationLong'] ?? 0.0;
                    final time = driver['time'] ?? DateTime.now();
                    final status = driver['status'] ?? '';
                    final type = driver['type'] ?? '';

                    return ListTile(
                      title: Text('Driver ID: $userId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Origin: ($originLat, $originLong)'),
                          Text('Destination: ($destinationLat, $destinationLong)'),
                          Text('Time: $time'),
                          Text('Status: $status'),
                          Text('Type: $type'),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          requestRide(userId);
                        },
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.directions_car),
                            SizedBox(width: 4), // Adjust spacing between icon and text
                            Text('Request Ride'),
                          ],
                        ),
                      ),
                      onTap: () {
                        // Handle onTap if needed
                      },
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void requestRide(int userId) {
    // Implement your ride request logic here
    UserModel user = DataManager.instance.getUser();

    print('Requesting ride from driver ID: $userId');
    socket.emit('requestRide', {
      'driverId': userId,
      'passengerId': user.uid, // Assuming you have access to the passenger's ID
      'originLat': widget.departLat,
      'originLong': widget.departLong,
      'destinationLat': widget.destLat,
      'destinationLong': widget.destLong,
    });
  }
  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when disposing the widget
    socket.dispose(); // Dispose the socket when disposing the widget
    super.dispose();
  }
}
