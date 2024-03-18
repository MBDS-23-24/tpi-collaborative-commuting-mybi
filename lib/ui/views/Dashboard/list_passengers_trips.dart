import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tpi_mybi/ui/views/Dashboard/DriverAccepted.dart';

import '../../../Data/DataManager.dart';
import '../../../model/User.dart';
import 'dart:math';

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

   socket = IO.io('wss://lalabi.azurewebsites.net:443', <String, dynamic>{
 //  socket = IO.io('http://localhost:3000', <String, dynamic>{



    'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print ('connect webSocket passengers');
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
    print('Fetching passengers...');
    UserModel user = DataManager.instance.getUser();
    socket.emit('getDriverRequests', {
      'driverId': user.userID,
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
  Widget build(BuildContext context) {
    return WillPopScope(
      // Wrap the scaffold with WillPopScope to intercept back button press
      onWillPop: () async {
        UserModel user = DataManager.instance.getUser();
        print('user.role.toString(): ${user.role.toString()} ');
        print('deleteDriver ');
        socket.emit('deleteDriver', user.userID);
        socket.emit('deleteAllrequested', user.userID);
        socket.emit('deleteDriverRequested',  user.userID );

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
                    final userId = passenger['passengerId'] ?? 'Unknown';
                    final timeString = passenger['time'] as String;
                    final requestTime = DateTime.parse(timeString);
                    final currentTime = DateTime.now();
                    final timeDifference = currentTime.difference(requestTime);

                    // Calculate the distance between passenger and driver's origin
                    final distance = calculateDistance(
                      widget.departLat,
                      widget.departLong,
                      passenger['originLat'] ?? 0.0,
                      passenger['originLong'] ?? 0.0,
                    );

                    return ListTile(
                      title: Text('Passenger ID: $userId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time: $timeDifference'),
                          Text('Distance to Driver: $distance'), // Display distance here
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () async {
                              UserModel user = DataManager.instance.getUser();
                              final passengerId = passengers[index]['passengerId'];
                              final driverId = user.userID;

                              // Emit event to update the ride request status as Rejected
                              socket.emit('acceptRequest', {
                                'passengerId': passengerId,
                                'driverId': driverId,
                              });
                              socket.disconnect();
                              resetPassengersList();
                              socket.dispose();

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriverAccepted(passengerId: passengerId),
                                ),
                              );

                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              UserModel user = DataManager.instance.getUser();
                              final passengerId = passengers[index]['passengerId'];
                              final driverId = user.userID;

                              // Emit event to update the ride request status as Rejected
                              socket.emit('rejectRequest', {
                                'passengerId': passengerId,
                                'driverId': driverId,
                              });

                            },
                          ),
                        ],
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
    /*
    if (socket.connected) {
      socket.disconnect();
    }

     */
  }
}
