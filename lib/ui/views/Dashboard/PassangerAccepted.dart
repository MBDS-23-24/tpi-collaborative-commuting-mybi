import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';

import '../../../Data/DataManager.dart';
import '../Chat/IndividualPage.dart';

class PassangerAccepted extends StatefulWidget {

  final int?  DriverID;
  PassangerAccepted({
    required this.DriverID,

  });
  @override
  State<PassangerAccepted> createState() => _PassangerAcceptedState();
}

class _PassangerAcceptedState extends State<PassangerAccepted> {
  PeerOptions options = PeerOptions();
  final Peer peer = Peer( id:"myid" );
  final TextEditingController _controller = TextEditingController();
  String? peerId;
  bool me = false;

  PeerConnectOption peerop =PeerConnectOption();
  late DataConnection? conn = DataConnection(peer.id.toString(),null,peerop) ;
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
    /*
    if (conn != null) {
      conn!.clear();
      conn!.close();
    }

     */

    peer.dispose();

    // Ferme la connexion Peer si elle est établie

    // Assurez-vous de nettoyer le reste, comme les controllers
    _controller.dispose();

    _locationUpdateTimer?.cancel();
  }

  @override
  void initState() {
    _initLocationService();
    print("jes suis dans passangerAccepted peerop =  ${peer.id.toString()}");
    super.initState();
    connect();
    print("jes suis dans passangerAccepted ");
    peer.on("open", null, (ev, context) {
      if (!mounted) return;
      setState(() {
        print("jes suis dans passangerAccepted open peer.id =  ${peer.id}");
        peerId = peer.id;
      });
    });

    peer.on("connection", null, (ev, context) {
      print("jes suis dans passangerAccepted connection  ev.eventData=  ${ev.eventData}");
      conn = ev.eventData as DataConnection;
      if (!mounted) return;
      setState(() {
        connected = true;
      });
    });

    peer.on("data", null, (ev, _) {
      print("je suis dans passangerAccepted data dans initState data=  ${ev.eventData}");
      final data = ev.eventData as String;

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
      Map<String, double> latLng = parseLatLng(data);
      if (!mounted) return;
      setState(() {
        print("je suis dans passangerAccepted data dans initState data=  ${latLng['latitude']}");
        _markers.add(
          Marker(
            markerId: MarkerId("peerLocation"),
            position: LatLng(latLng['latitude']!, latLng['longitude']!),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)
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



// Fonction pour parser la chaîne de caractères et retourner un Map avec latitude et longitude en double
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

        if (!mounted) return;
        setState(() {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 14,
              ),
            ),
          );

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
  late String meTest;
  void connect() {
    meTest= widget.DriverID.toString();
    String me= widget.DriverID.toString();
    final connection = peer.connect(widget.DriverID.toString());
    print ("jes suis dans passangerAccepted connect()  connection=  $connection with id = ${peerId}");
    conn = connection;
    if (!mounted) return;
    conn?.on("open", null, (ev, _) {
      sendLocationUpdatesTest();
      setState(() {
        connected = true;
      });
    });

      conn?.on("data", null, (ev, _) {
        print("jes suis dans passangerAccepted conn  data=  ${ev.eventData}");
        final dynamic data = ev.eventData;

        Map<String, double> latLng = parseLatLng(data);
        if (!mounted) return;
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

  Timer? _locationUpdateTimer;

  void sendLocationUpdates() {
    // Function to send location updates to peer every 1 second
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer =  Timer.periodic(const Duration(seconds: 150), (Timer t) {
      if (_currentLocation != null) {
        final Map<String, dynamic> locationData = {
          "latitude": _currentLocation!.latitude,
          "longitude": _currentLocation!.longitude,
        };
        conn?.send(locationData.toString());
      }
    });
  }

  void sendLocationUpdatesTest() {
    _locationUpdateTimer?.cancel();
    // Function to send static location updates to peer every 150 seconds
    _locationUpdateTimer =  Timer.periodic(const Duration(seconds: 10), (Timer t) {
      // Localisation statique d'Antibes, France pour le test
      const double staticLatitude = 43.580418; // Latitude statique d'Antibes
      const double staticLongitude = 7.125102; // Longitude statique d'Antibes

      print("Envoi de la localisation statique d'Antibes: latitude=$staticLatitude longitude=$staticLongitude");

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
        title: Text("Passenger Accepted"), // Titre optionnel pour l'AppBar
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
                            chatModel: DataManager.instance.getUserById(widget.DriverID!),
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