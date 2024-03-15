import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/Trip.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:tpi_mybi/model/request.dart';
import 'package:tpi_mybi/ui/views/Dashboard/dashboard.dart';
import 'package:tpi_mybi/ui/views/Dashboard/direction_info.dart';
import 'package:tpi_mybi/ui/views/ListTrip/ListTripForPassenger.dart';
import 'package:tpi_mybi/ui/views/Profile/profile.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../CostumColor.dart';
import '../ListTrip/ListTripScreen.dart';
import 'list_driver_trips.dart';
import 'list_passengers_trips.dart';
import 'package:intl/intl.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {

  late gmaps.GoogleMapController mapController;
  final gmaps.LatLng _center = const gmaps.LatLng(48.8566, 2.3522);
  final Set<gmaps.Marker> _markers = {};
  bool _isFindRideSelected = true;
  String _pickupLocationText = 'Depart location';
  String _destinationLocationText = 'Destination location';
  Set<gmaps.Polyline> _polylines = {};
  List<gmaps.LatLng> polylineCoordinates = [];
  String _selectedDateText = 'Date & time';
  int _selectedSeats = 1; // Default value is 1 seat
  String _numberOfSeats = 'No. of seat';


  late IO.Socket socket;
  List<dynamic> listDrivers = [];
  late Timer timer;

  // Track input status of departure and destination locations
  bool _isDepartureLocationSelected = false;
  bool _isDestinationLocationSelected = false;
  _TripsScreenState() {
    // Initialize the socket in the constructor
  socket = IO.io('wss://lalabi.azurewebsites.net:443', <String, dynamic>{


    'transports': ['websocket'],
      'autoConnect': false,
    });

    // Add listeners and perform other initialization tasks here if needed
  }

  @override
  void initState() {
    super.initState();
    // Replace 'http://localhost:3001' with your server address
//https://lalabi.azurewebsites.net/
    socket = IO.io('wss://lalabi.azurewebsites.net:443', <String, dynamic>{


    'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('connected');
      // Automatically fetch the list of drivers after connection
      fetchDrivers();
      // Start the timer to fetch drivers periodically
      timer = Timer.periodic(Duration(seconds: 10), (Timer t) => fetchDrivers());
    });

    socket.on('allDrivers', (data) {
      print('drivers: $data');

      setState(() {
        listDrivers = List.from(data);
      });
    });

    socket.connect();
  }

  // Function to fetch drivers from the server
  void fetchDrivers() {
    // Emitting 'getAllDrivers' event to get all drivers from the server
    socket.emit('getAllDrivers');
  }
  @override
  void dispose() {
    timer.cancel();
    socket.dispose();
    super.dispose();
  }
  void findRide() async {
    // Get current user details
    UserModel user = DataManager.instance.getUser();

    // Get departure and destination locations
    gmaps.LatLng departLocation = _markers.firstWhere((marker) => marker.markerId.value == 'departLocation').position;
    gmaps.LatLng destinationLocation = _markers.firstWhere((marker) => marker.markerId.value == 'destinationLocation').position;

    DateTime selectedDate = DateTime.parse(_selectedDateText);
    int numberOfSeats = _selectedSeats;
    // Create Request object
    Request userRequest = Request(
      userId: user.userID,
      type: user.role.toString(),
      originLat: departLocation.latitude,
      originLong: departLocation.longitude,
      destinationLat: destinationLocation.latitude,
      destinationLong: destinationLocation.longitude,
      time: DateTime.now(),
      status: 'pending',
    );

    // Send user request via socket
    socket.emit('addRequest', userRequest.toJson());

    // Clean up the markers and reset UI elements
    _resetUI();

    // Navigate to the corresponding page based on user role
    _navigateBasedOnUserRole(user, departLocation, destinationLocation);

    // Now properly disconnect and dispose off the socket
    socket.disconnect();
    socket.dispose();
  }

  void _resetUI() {
    setState(() {
      // Clean up markers for departLocation and destinationLocation
      _markers.removeWhere((marker) => marker.markerId.value == 'departLocation' || marker.markerId.value == 'destinationLocation');
      _pickupLocationText = 'Depart location';
      _destinationLocationText = 'Destination location';
      _isDepartureLocationSelected = false;
      _isDestinationLocationSelected = false;
    });
  }

  Future<void> _navigateBasedOnUserRole(UserModel user, gmaps.LatLng departLocation, gmaps.LatLng destinationLocation) async {
    if (user.role.toString() == 'PASSAGER') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListDriverTrips(
          departLat: departLocation.latitude,
          departLong: departLocation.longitude,
          destLat: destinationLocation.latitude,
          destLong: destinationLocation.longitude,
        )),
      );
    } else if (user.role.toString() == 'CONDUCTEUR') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListPassengersTrips(
          departLat: departLocation.latitude,
          departLong: departLocation.longitude,
          destLat: destinationLocation.latitude,
          destLong: destinationLocation.longitude,
        )),
      );
    }
  }




  void _onMapCreated(gmaps.GoogleMapController controller) async {
    mapController = controller;
    var currentLocation = await _getCurrentLocation();

    setState(() {
      mapController.animateCamera(
        gmaps.CameraUpdate.newCameraPosition(
          gmaps.CameraPosition(target: currentLocation, zoom: 14.0),
        ),
      );

      _markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId('currentLocation'),
          position: currentLocation,
          icon: gmaps.BitmapDescriptor.defaultMarker,
        ),
      );

      // Add markers for all drivers
      for (var driver in listDrivers) {
        _markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(driver['userId'].toString()), // Unique marker ID for each driver
            position: gmaps.LatLng(driver['originLat'], driver['originLong']), // Origin location
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen), // Custom icon
          ),
        );

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Trips'),
            SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(user: DataManager.instance.getUser())),
                );
              },
              child: Text('Profile'),
            ),
          ],
        ),
        backgroundColor: myPrimaryColor,

      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: gmaps.GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: gmaps.CameraPosition(
                target: _center,
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRideButtons(),
                  Divider(),
                  _buildLocationTile(Icons.location_on, _pickupLocationText, () {
                    _showLocationSearch(context, isPickupLocation: true);
                  }),
                  Divider(),
                  _buildLocationTile(Icons.flag, _destinationLocationText, () {
                    if (_pickupLocationText != _destinationLocationText) {
                      _showLocationSearch(context, isPickupLocation: false);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Pick-up and destination locations cannot be the same.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Expanded(child: _buildLocationTile(Icons.calendar_today, _selectedDateText, _selectDate)),
                      Expanded(child: _buildLocationTile(Icons.person, _numberOfSeats, () {
                        // Handle number of seats
                      })),
                    ],
                  ),
                  SizedBox(height: 10),
                    _buildFindRideButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _isFindRideSelected ? myPrimaryColor : Colors.white,
              onPrimary: _isFindRideSelected ? Colors.white : myPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2,
            ),
            onPressed: () {
              setState(() {
                _isFindRideSelected = true;
              });
            },
            child: Text('Find ride'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: !_isFindRideSelected ? myPrimaryColor : Colors.white,
              onPrimary: !_isFindRideSelected ? Colors.white : myPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 2,
            ),
            onPressed: () {
              setState(() {
                _isFindRideSelected = false;
              });
            },
            child: Text('Offer ride'),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTile(IconData icon, String title, VoidCallback onTap) {
    UserModel user = DataManager.instance.getUser(); // Récupérez les informations de l'utilisateur
    if(user.role=="PASSAGER")
    _numberOfSeats="";


    return ListTile(
      leading: Icon(icon, color: myPrimaryColor),
      title: Text(title),
      onTap: onTap,
      trailing: (title == _numberOfSeats && user.role != "PASSAGER")
          ? DropdownButton<int>(
        value: _selectedSeats,
        items: [1, 2, 3, 4, 5] // Ajoutez plus de valeurs si nécessaire
            .map((int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: Text(value.toString()),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _selectedSeats = newValue!;
          });
        },
      )
          : null,
    );
  }



  Widget _buildFindRideButton() {
    UserModel user = DataManager.instance.getUser();
    // Disable the button if either departure or destination location is not selected
    bool isButtonDisabled = !_isDepartureLocationSelected || !_isDestinationLocationSelected;

    String buttonText = "Find ride"; // Texte par défaut

    // Vérifiez le rôle de l'utilisateur et ajustez le texte du bouton en conséquence
    if (user.role.toString() == 'PASSAGER') {
      buttonText = _selectedDateText != 'Date & time' ? 'Find Ride in the Future' : 'Find Ride';
    } else if (user.role.toString() == 'CONDUCTEUR') {
      buttonText = _selectedDateText != 'Date & time' ? 'Planify a Trip' : 'Find Passengers';
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: myPrimaryColor,
        onPrimary: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
      ),
      onPressed: isButtonDisabled ? null : () => _findRideButtonPressed(buttonText), // Pass buttonText to the method
      child: Center(
        child: Text(buttonText), // Utilisez buttonText ici
      ),
    );
  }


  // Method to handle the onPressed event of the Find ride button
  void _findRideButtonPressed(String buttonText) {
    if (buttonText == 'Planify a Trip') {
      // Call the method for planning a trip
      planATrip();
    } else if (buttonText == 'Find Ride in the Future') {
      // Call the method for finding a ride in the future
      findFutureRide();
    } else {
      // Default action
      findRide();
    }
  }

  void _showLocationSearch(BuildContext context, {required bool isPickupLocation}) async {
    LocationData? locationData = await LocationSearch.show(
      context: context,
      lightAdress: true,
    );

    if (locationData != null) {
      if (!isPickupLocation && locationData.address == _pickupLocationText) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Pick-up and destination locations cannot be the same.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          if (isPickupLocation) {
            _isDepartureLocationSelected = true; // Update departure location input status
            _markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
            _markers.add(
              gmaps.Marker(
                markerId: gmaps.MarkerId('departLocation'),
                position: gmaps.LatLng(locationData.latitude, locationData.longitude),
                icon: gmaps.BitmapDescriptor.defaultMarker,
              ),
            );

            _pickupLocationText = locationData.address;
          } else {
            _isDestinationLocationSelected = true; // Update destination location input status
            _markers.add(
              gmaps.Marker(
                markerId: gmaps.MarkerId('destinationLocation'),
                position: gmaps.LatLng(locationData.latitude, locationData.longitude),
                icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
              ),
            );

            _destinationLocationText = locationData.address;

            gmaps.LatLng pickupLocation = _markers.firstWhere((marker) => marker.markerId.value == 'departLocation').position;
            gmaps.LatLng destinationLocation = gmaps.LatLng(locationData.latitude, locationData.longitude);
            if (pickupLocation != null && destinationLocation != null) {
              getDirections(pickupLocation, destinationLocation).then((directionInfo) {
                setState(() async {
                  Navigator.pop(context);
                  PolylinePoints polylinePoints = PolylinePoints();
                  var thisDetails =
                  await getDirections(pickupLocation, destinationLocation);
                  List<PointLatLng> results =
                  polylinePoints.decodePolyline(thisDetails.encodedPoints);
                  polylineCoordinates.clear();
                  if (results.isNotEmpty) {
                    results.forEach((PointLatLng point) {
                      polylineCoordinates.add(gmaps.LatLng(point.latitude, point.longitude));
                    });
                  }
                  _polylines.clear();
                  setState(() {
                    gmaps.Polyline polyline = gmaps.Polyline(
                        polylineId: gmaps.PolylineId('polyid'),
                        color: Color.fromARGB(255, 95, 109, 237),
                        points: polylineCoordinates,
                        jointType: gmaps.JointType.round,
                        width: 4,
                        startCap: gmaps.Cap.roundCap,
                        endCap: gmaps.Cap.roundCap,
                        geodesic: true);
                    _polylines.add(polyline);
                  });
                });
              });
            }
          }
        });
      }
    }
  }

  Future<gmaps.LatLng> _getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return gmaps.LatLng(position.latitude, position.longitude);
  }

  Future<DirectionInfo> getDirections(gmaps.LatLng start, gmaps.LatLng end) async {
    final urlOriginToDest = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=YOUR_API_KEY");
    var response = await http.get(urlOriginToDest);
    var jsonData = jsonDecode(response.body);

    DirectionInfo directionInfo = DirectionInfo(encodedPoints: '');
    directionInfo.e_points = jsonData['routes'][0]['overview_polyline']['points'];

    directionInfo.distance_text = jsonData['routes'][0]["legs"][0]['distance']['text'];
    directionInfo.distance_value = jsonData['routes'][0]["legs"][0]['distance']['value'];

    directionInfo.duration_text = jsonData['routes'][0]["legs"][0]['duration']['text'];
    directionInfo.duration_value = jsonData['routes'][0]["legs"][0]['duration']['value'];
    directionInfo.encodedPoints = jsonData['routes'][0]['overview_polyline']['points'];
    return directionInfo;
  }
  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (selectedTime != null) {
        setState(() {
          // Combine selected date and time
          DateTime combinedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
          // Format the combined date time to remove seconds and milliseconds
          String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(combinedDateTime); // Format neutre
          _selectedDateText = formattedDateTime;
        });
      }
      }
    print(_selectedDateText);
    print(DateTime.parse(_selectedDateText));
    }

  void planATrip() async {
    UserModel user = DataManager.instance.getUser();

    // Create a new trip object with the required details
    VoyageModel trip = VoyageModel(
      conducteurId: user.userID,
      depart: _pickupLocationText,
      destination: _destinationLocationText,
      timestamp: DateTime.parse(_selectedDateText), // Ensure this is a valid DateTime string
      placeDisponible: _selectedSeats,
    );
    bool isSuccess = await DataLoader.instance.createVoyage(trip);

    if (isSuccess) {
     // remiseaZeroFormulaire();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip created successfully')),
      );
      // Add a slight delay to allow the user to see the SnackBar message
      await Future.delayed(Duration(seconds: 1));
      // Navigate to the ListTripScreenListTripScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  DashboardScreen(user: user)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create Trip')),
      );
    }
  }


  void findFutureRide() async {
      UserModel user = DataManager.instance.getUser();


      // Create a new trip object with the required details
      VoyageModel trip = VoyageModel(
        conducteurId: user.userID,
        depart: _pickupLocationText,
        destination: _destinationLocationText,
        timestamp: DateTime.parse(_selectedDateText), // Ensure this is a valid DateTime string
        placeDisponible: _selectedSeats,
      );
      List<VoyageModel>? trips = await DataLoader.instance.getTripsForPassenger(trip);
      print(trips);
      if (trips != null ) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  ListTripForPassenger(trips: trips)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get Trips')),
        );
      }



    }

  void remiseaZeroFormulaire() {
     gmaps.GoogleMapController mapController;
     gmaps.LatLng _center = const gmaps.LatLng(48.8566, 2.3522);
     Set<gmaps.Marker> _markers = {};
     _isFindRideSelected = true;
     _pickupLocationText = 'Depart location';
     _destinationLocationText = 'Destination location';
    Set<gmaps.Polyline> _polylines = {};
    List<gmaps.LatLng> polylineCoordinates = [];
    _selectedDateText = 'Date & time';
    _selectedSeats = 1; // Default value is 1 seat
     _numberOfSeats = 'No. of seat';
     IO.Socket socket;
     List<dynamic> listDrivers = [];
    Timer timer;
  }
}
