import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tpi_mybi/ui/views/Dashboard/PassangerAccepted.dart';

import '../../../Data/DataManager.dart';
import '../../../model/User.dart';

class ListDriverTrips extends StatefulWidget {
  final double departLat;
  final double departLong;
  final double destLat;
  final double destLong;
  final double requiredSeats;

  ListDriverTrips({
    required this.departLat,
    required this.departLong,
    required this.destLat,
    required this.destLong,
    required this.requiredSeats,
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

    socket = IO.io('wss://lalabi.azurewebsites.net:443', <String, dynamic>{



      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.on('rideAccepted', (data) {
      final status = data['status'];
      final driverId = data['driverId'];
      // Show modal or any other UI response based on the status
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green), // Accepted icon
                SizedBox(width: 8), // Add some space between icon and text
                Text('Request ACCEPTED', style: TextStyle(color: Colors.green)), // Title text
              ],
            ),
            content: Text('Your ride request has been $status.'),
            actions: [
              Container(
                width: double.infinity, // Take the full width
                child: TextButton(
                  onPressed: () async {
                    socket.disconnect();
                    socket.dispose();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PassangerAccepted(DriverID: driverId /*DataManager.instance.getUser().userID*/,)),
                    );
                  },
                  child: Text('Track Trips', style: TextStyle(color: Colors.blue)), // Button text
                ),
              ),
            ],
          );
        },
      );

    });
    socket.on('rideRejected', (data) {
      final status = data['status'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel, color: Colors.red), // Rejected icon
                SizedBox(width: 8), // Add some space between icon and text
                Text('Request REJECTED', style: TextStyle(color: Colors.red)), // Title text
              ],
            ),
            content: Text('Your ride request has been $status.'),
            actions: [
              Container(
                width: double.infinity, // Take the full width
                child: TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: Text('Track Trips', style: TextStyle(color: Colors.blue)), // Button text
                ),
              ),
            ],
          );
        },
      );


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
      'requiredSeats': widget.requiredSeats,
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
        socket.emit('deletePassenger', user.userID);
        socket.emit('deleteMyrequest', user.userID);
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
                    final time = driver['time'] ?? DateTime.now();
                    final requestTime = DateTime.parse(time);
                    final status = driver['status'] ?? '';
                    final type = driver['type'] ?? '';
                    final currentTime = DateTime.now();
                    final timeDifference = currentTime.difference(requestTime);
                    final distance = calculateDistance(
                      widget.departLat,
                      widget.departLong,
                      driver['originLat'] ?? 0.0,
                      driver['originLong'] ?? 0.0,
                    );

                    // Define colors based on status
                    Color tileColor;
                    switch (status) {
                      case 'Accepted':
                        tileColor = Colors.green;
                        break;
                      case 'Rejected':
                        tileColor = Colors.red;
                        break;
                      case 'In Progress':
                        tileColor = Colors.yellow;
                        break;
                      default:
                        tileColor = Colors.white;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        color: tileColor,
                        child: ListTile(
                          title: Text('Driver ID: $userId'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time: $timeDifference'),
                              Text('Distance to Driver: $distance'),
                              Text('Seats available: ${driver['seats'] ?? 'Unknown'}'),
                              Text('Status: $status'),
                            ],
                          ),
                          trailing: isRequestAllowed(status)
                              ? IconButton(
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
                          )
                              : null, // If request is not allowed, disable the button
                          onTap: () {
                            // Handle onTap if needed
                          },
                        ),
                      ),
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
  bool isRequestAllowed(String status) {
    return status != 'In Progress' && status != 'Rejected';
  }
  void requestRide(int userId) {
    // Implement your ride request logic here
    UserModel user = DataManager.instance.getUser();

    print('Requesting ride from driver ID: $userId');
    socket.emit('requestRide', {
      'driverId': userId,
      'passengerId': user.userID, // Assuming you have access to the passenger's ID
      'originLat': widget.departLat,
      'originLong': widget.departLong,
      'destinationLat': widget.destLat,
      'destinationLong': widget.destLong,
      'requiredSeats': widget.requiredSeats,
    });
  }

  double calculateDistance(double originLat, double originLong, double destinationLat, double destinationLong) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers

    // Convert latitude and longitude from degrees to radians
    double lat1 = originLat * pi / 180;
    double lon1 = originLong * pi / 180;
    double lat2 = destinationLat * pi / 180;
    double lon2 = destinationLong * pi / 180;

    // Calculate the differences between coordinates
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    // Haversine formula
    double a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance; // Distance in kilometers
  }
  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when disposing the widget
    socket.dispose(); // Dispose the socket when disposing the widget
    super.dispose();
  }
}