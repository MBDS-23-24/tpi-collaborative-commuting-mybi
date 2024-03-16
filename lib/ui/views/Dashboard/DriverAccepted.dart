import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';
import 'package:peerdart/peerdart.dart';

import '../../../Data/DataManager.dart';
import '../../../model/User.dart';
import '../Chat/IndividualPage.dart';

class DriverAccepted extends StatefulWidget {
    DriverAccepted({  required this.passengerId});

    final int?  passengerId;
  @override
  State<DriverAccepted> createState() => _DriverAcceptedState();
}

class _DriverAcceptedState extends State<DriverAccepted> {
  late int? passengerId = widget.passengerId;
  late Peer peer; // Declare peer variable here
  final TextEditingController _controller = TextEditingController();
  String? peerId;
  PeerConnectOption peerop =PeerConnectOption();
  late DataConnection? conn = new DataConnection('false',null,peerop) ;
  bool connected = false;
  gmaps.GoogleMapController? mapController;
  Set<gmaps.Marker> _markers = {};
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _currentLocation;
  @override
  void dispose() {

    super.dispose();
    if (conn != null) {



      _controller.dispose();
    }

    _locationUpdateTimer?.cancel();

  }

  @override
  void initState() {
    super.initState();
    _initLocationService();
    final UserModel user = DataManager.instance.getUser();
    peer = Peer(id: user.userID.toString()); // Initialize peer here
    if (!mounted) return;
    peer.on("open", null, (ev, context) {
      setState(() {
        print("jes suis dans DriverAccepted open peer =  ${peer.id}");
        peerId = peer.id;
      });
    });

    peer.on("connection", null, (ev, context) {

      print("je suis dans DriverAccepted peer  dans connection ev.eventData =  ${ev.eventData}");
      conn = ev.eventData as DataConnection;
      if (!mounted) return;
      setState(() {
        connected = true;
      });
    });

    peer.on("data", null, (ev, _) {
      final data = ev.eventData as String;
      print("je suis dans DriverAccepted peer  data=  $data");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));


      Map<String, double> latLng = parseLatLng(data);
      if (!mounted) return;
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId("peerLocation"),
            position: LatLng(latLng['latitude']!, latLng['longitude']!),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
          ),
        );
      });

    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/driverIcon.webp')
        .then((d) {
      customIcon = d;
    });
  }
  late BitmapDescriptor customIcon;

  Map<String, double> parseLatLng(String latLngString) {
    // Assurez-vous que la chaîne d'entrée est formatée correctement comme du JSON
    String correctedString = latLngString.replaceAllMapped(
        RegExp(r'([a-zA-Z]+):'), (Match match) => '"${match[1]}":');

    // Décodage de la chaîne JSON
    Map<String, dynamic> json = jsonDecode(correctedString);

    // Extraction et conversion des valeurs en double
    double latitude = double.parse(json['latitude'].toString());
    double longitude = double.parse(json['longitude'].toString());

    return {'latitude': latitude, 'longitude': longitude};
  }

  void _initLocationService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      _currentLocation = currentLocation;
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 14,
            ),
          ),
        );
        if (!mounted) return;
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId("currentLocation"),
              position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            ),
          );
        });
      }
    });
  }
  void connect() {
    final connection = peer.connect(_controller.text);
    conn = connection;

    if (!mounted) return;
    conn?.on("open", null, (ev, _) {
      print("je suis dans DriverAccepted open conn  ev.eventData= sendLocationUpdatesTest ");
      sendLocationUpdatesTest();
      setState(() {
        sendLocationUpdatesTest();
        connected = true;
      });

      conn?.on("data", null, (ev, _) {
        final data = ev.eventData as String;
        print("je suis dans DriverAccepted conn  data=  ${ev.eventData}");
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
        if (!mounted) return;
        Map<String, double> latLng = parseLatLng(data);
        setState(() {

          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(latLng['latitude']!, latLng['longitude']!),
                zoom: 14,
              ),
            ),
          );

          print("je suis dans passangerAccepted data  data=  ${latLng['latitude']}");
          _markers.add(
            Marker(
                markerId: MarkerId("peerLocation"),
                position: LatLng(latLng['latitude']!, latLng['longitude']!),
                icon:customIcon /*BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)*/
            ),
          );
        });
        //---------------------
      });
    });
  }

  void sendHelloWorld() {
    // Assurez-vous que cette fonction est appelée après l'établissement de la connexion
    if (connected) {
      conn?.send("Hello worldworld!");
    } else {
      print("Connection not established.");
    }
  }

  void sendLocationUpdates() {
    // Function to send location updates to peer every 1 second
    Timer.periodic(const Duration(seconds: 3), (Timer t) {
      print("je suis dans DriverAccepted sendLocationUpdates  _currentLocation=  ${_currentLocation?.latitude}  ${_currentLocation?.longitude}");
      if (_currentLocation != null) {
        final Map<String, dynamic> locationData = {
          "latitude": _currentLocation!.latitude,
          "longitude": _currentLocation!.longitude,
        };
        conn?.send(locationData.toString());
      }
    });
  }

  Timer? _locationUpdateTimer;

  void sendLocationUpdatesTest() {
    _locationUpdateTimer?.cancel();
    // Function to send static location updates to peer every 3 seconds
    _locationUpdateTimer =  Timer.periodic(const Duration(seconds: 10), (Timer t) {
      // Localisation statique de Cannes, France pour le test
      const double staticLatitude = 43.552847; // Latitude statique de Cannes
      const double staticLongitude = 7.017369; // Longitude statique de Cannes

      print("Envoi de la localisation statique de Cannes: latitude=$staticLatitude longitude=$staticLongitude");

      // Création du paquet de données de localisation avec les coordonnées statiques
      final Map<String, dynamic> locationData = {
        "latitude": staticLatitude,
        "longitude": staticLongitude,
      };

      // Envoi des données de localisation statique au pair
      conn?.send(locationData.toString());
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Accepted"), // Titre optionnel pour l'AppBar
        actions: [/*
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.blue,
            ),
            onPressed: () {
              conn?.close();
              peer.socket.close();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IndividualPage(
                    chatModel: DataManager.instance.getUserById(passengerId),
                    sourchat: DataManager.instance.getUser(),
                  ),
                ),
              );
            },
          ),
        */],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8), // Ajoute un peu d'espace autour
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _renderState(), // Affiche l'état de connexion
                  IconButton(
                    icon: Icon(
                      Icons.chat,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      conn?.close();
                      peer.socket.close();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualPage(
                            chatModel: DataManager.instance.getUserById(passengerId),
                            sourchat: DataManager.instance.getUser(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 7, // Donne plus d'espace à la carte
            child: gmaps.GoogleMap(
              mapType: gmaps.MapType.normal,
              initialCameraPosition: gmaps.CameraPosition(
                target: gmaps.LatLng(0, 0),
                zoom: 14,
              ),
              onMapCreated: (gmaps.GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderState() {
    Color bgColor = connected ? Colors.green : Colors.grey;
    Color txtColor = Colors.white;
    String txt = connected ? "Connected" : "Standby";
    return Container(
      decoration: BoxDecoration(color: bgColor),
      child: Text(
        txt,
        style:
        Theme.of(context).textTheme.titleLarge?.copyWith(color: txtColor),
      ),
    );
  }
}
