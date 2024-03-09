import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../Data/DataManager.dart';
import '../../../model/User.dart';

class ListPassengersTrips extends StatefulWidget {
  final double departLat;
  final double departLong;
  final double destLat;
  final double destLong;

  ListPassengersTrips({
    required this.departLat,
    required this.departLong,
    required this.destLat,
    required this.destLong,
  });

  @override
  _ListPassengersTripsState createState() => _ListPassengersTripsState();
}

class _ListPassengersTripsState extends State<ListPassengersTrips> {
  late IO.Socket socket;
  List<dynamic> passengers = [];

  late Timer timer;

  @override
  void initState() {
    super.initState();
    initializeSocketAndFetchPassengers();
  }

  // Initialize socket and fetch passengers
  void initializeSocketAndFetchPassengers() {
    socket = IO.io('wss://integrationlalabi.azurewebsites.net:443', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      fetchPassengers();
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchPassengers());
    });
    socket.on('driverRequests', (data) {
      //print('Ride requests received: $data');
    //  socket.emit('callme', data);

      updatePassengersList(data);
    });
  }

  void updatePassengersList(List<dynamic> requests) {
    setState(() {
      passengers = List.from(requests);
    });
  }

  // Function to fetch passengers from the server
  void fetchPassengers() {
    UserModel user = DataManager.instance.getUser();
    socket.emit('getDriverRequests', {
      'driverId': user.uid,
    });
  }

  // Function to reset the list of passengers
  void resetPassengersList() {
    setState(() {
      passengers.clear();
    });
  }

  // Function to show an alert dialog for ride request
  void showRideRequestDialog(data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ride Request Received'),
          content: Text('You have a new ride request from '),
          actions: [
            TextButton(
              onPressed: () {
                // Handle accept
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                // Handle decline
              },
              child: Text('Decline'),
            ),
          ],
        );
      },
    );
  }

  // Function to calculate the distance between two points
  double calculateDistance(double originLat, double originLong, double destinationLat, double destinationLong) {
    // Use your distance calculation method here
    // For example, you can use the Haversine formula
    // Replace the return value with your actual distance calculation
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Wrap the scaffold with WillPopScope to intercept back button press
      onWillPop: () async {
        UserModel user = DataManager.instance.getUser();
        print('user.role.toString(): ${user.role.toString()} ');
        print('deleteDriver ');
        socket.emit('deleteDriver', user.uid);
        // Disconnect from the socket when the user presses the back button
        socket.disconnect();
        resetPassengersList();
        socket.dispose();
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Passenger Trips'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text('Passengers:'),
              Expanded(
                child: ListView.builder(
                  itemCount: passengers.length,
                  itemBuilder: (context, index) {
                    final passenger = passengers[index];
                    final userId = passenger['userId'] ?? 'Unknown';
                    final originLat = passenger['originLat'] ?? 0.0;
                    final originLong = passenger['originLong'] ?? 0.0;
                    final destinationLat = passenger['destinationLat'] ?? 0.0;
                    final destinationLong = passenger['destinationLong'] ?? 0.0;
                    final timeString = passenger['time'] as String;
                    final requestTime = DateTime.parse(timeString);
                    final currentTime = DateTime.now();
                    final timeDifference = currentTime.difference(requestTime);
                    final status = passenger['status'] ?? '';
                    final type = passenger['type'] ?? '';

                    // Calculate the distance between passenger and driver's origin
                    final distance = calculateDistance(
                      widget.departLat,
                      widget.departLong,
                      originLat,
                      originLong,
                    );

                    return ListTile(
                      title: Text('Passenger ID: $userId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Origin: ($originLat, $originLong)'),
                          Text('Destination: ($destinationLat, $destinationLong)'),
                          Text('Time: $timeDifference'),
                          Text('Status: $status'),
                          Text('Type: $type'),
                          Text('Distance to Driver: $distance'), // Display distance here
                        ],
                      ),
                      trailing: Icon(Icons.directions_car),
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

  @override
  void dispose() {
    timer.cancel();
    socket.dispose();
    super.dispose();
  }
}
