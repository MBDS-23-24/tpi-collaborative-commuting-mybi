import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';
import 'package:peerdart/peerdart.dart';

import '../../../Data/DataLoader.dart';
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
  //late Peer peer= Peer( id:"myid" ); // Declare peer variable here
  late Peer peer;
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


   final double LatitudeAntibes = 43.580418;
  final double  longitudeAntibes = 7.125102;

  final double LatitudeCagnes = 43.6645;
  final double  LongitudeCagnes = 7.1482;

  // Coordonnées de départ : cannes (pour la première itération seulement)
  final double LatitudeCannes  = 43.552847;
  final double LongitudeCannes = 7.017369;




  late gmaps.BitmapDescriptor driverIcon, destinationIcon, passengerIcon;

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

    loadDriverIcon();
    // connect();
   // _initLocationService();
    final UserModel user = DataManager.instance.getUser();
    peer = Peer(id: user.userID.toString()); // Initialize peer here

    peer.on("open", null, (ev, context) {
      if (!mounted) return;
      setState(() {
        print("je suis dans DriverAccepted open peer =  ${peer.id}");
        peerId = peer.id;
        sendFakeLocationUpdates();
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

    peer.on("data", null, (ev, _)  {
      final data = ev.eventData as String;
      print("je suis dans DriverAccepted peer  data=  $data");

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
      Map<String, double> latLng = parseLatLng(data);

      print("je suis dans DriverAccepted peer  distance =   ${calculateDistance(latLng['latitude']!, latLng['longitude']!, locationData["latitude"], locationData["longitude"])}");

      // antibes
     // final double destinationLatitude = 43.580418;
     // final double destinationLongitude = 7.125102;


   if ( calculateDistance(latLng['latitude']!, latLng['longitude']!, locationData["latitude"], locationData["longitude"]) <= 1.6) {
          sendFakeLocationDestinationTest();
   }
   else {
     if (!mounted) return;
     setState(() {
       _markers.add(
         Marker(
           markerId: MarkerId("currentLocation"),
           //  position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
           position: LatLng(locationData["latitude"], locationData["longitude"]),
           icon: driverIcon,

         ),
       );
     });

   }

      if (!mounted) return;
      setState(()  {

        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locationData["latitude"]!,  locationData["longitude"]!),
              zoom: 11,
            ),
          ),
        );

        /*
        final driverIcon = await gmaps.BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)),
            'assets/driverIconNew.png');

         */

        _markers.add(
          gmaps.Marker(
            markerId: MarkerId("peerLocation"),
            position: LatLng(latLng['latitude']!, latLng['longitude']!),
              icon: passengerIcon  /*BitmapDescriptor.defaultMarker*/,
          ),
        );

        _markers.add(
          gmaps.Marker(
            markerId: MarkerId("destination"),
            position: LatLng(LatitudeCagnes, LongitudeCagnes),
            icon: destinationIcon
          ),
        );



        /*
        _markers.add(
          Marker(
              markerId: MarkerId("destination"),
              position: LatLng(43.70036, 7.26095),
              icon: destinationIcon
          ),
        );
         */

      });

    });



    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/driverIcon.webp')
        .then((d) {
      customIcon = d;
    });
  }

  late Map<String, dynamic> locationDataDest = {
    "latitude": LatitudeAntibes,
    "longitude": longitudeAntibes,
  };
 late Map<String, dynamic> locationData = {
    "latitude": LatitudeCannes,
    "longitude": LongitudeCannes,
  };

  void sendFakeLocationUpdates() {
    _locationUpdateTimer?.cancel();

    int iterationCount = 0; // Compteur pour suivre le nombre d'itérations
    const int maxIterations = 5; // Le nombre maximum d'itérations

    void updateLocation() {
      if (iterationCount >= maxIterations) {
        _locationUpdateTimer?.cancel(); // Si on a atteint le nombre d'itérations désiré, arrêtons le timer
        return; // Et sortons de la fonction
      }

      // Coordonnées de départ : cannes (pour la première itération seulement)
      double currentLatitude = 43.552847;
      double currentLongitude = 7.017369;

      // Coordonnées d'arrivée : antibes
      final double destinationLatitude = 43.580418;
      final double destinationLongitude = 7.125102;

      // Calculons les différences de coordonnées et divisons par 5 pour 5 itérations
      final double latitudeIncrement = (destinationLatitude - currentLatitude) / 5;
      final double longitudeIncrement = (destinationLongitude - currentLongitude) / 5;

      _locationUpdateTimer = Timer.periodic(Duration(seconds: 8), (Timer t) {
        if (iterationCount < maxIterations) {
          // Incrémentons la position actuelle
          currentLatitude += latitudeIncrement;
          currentLongitude += longitudeIncrement;

          // Vérifions si nous avons atteint ou dépassé notre destination
          if (currentLatitude >= destinationLatitude && currentLongitude >= destinationLongitude) {
            currentLatitude = destinationLatitude;
            currentLongitude = destinationLongitude;
          }

          print("Envoi de la localisation fictive : latitude=$currentLatitude, longitude=$currentLongitude");

          // Création du paquet de données de localisation avec les coordonnées fictives
          /*final Map<String, dynamic>*/ locationData = {
            "latitude": currentLatitude,
            "longitude": currentLongitude,
          };

          // Envoi des données de localisation fictive au pair
          conn?.send(locationData.toString());

          iterationCount++; // Incrémentons le compteur d'itérations

          if (iterationCount == maxIterations) {
            _locationUpdateTimer?.cancel(); // Arrêtons le timer après la dernière itération
          }
        }
      });
    }

    updateLocation(); // Appelons la fonction pour démarrer le processus
  }

  void sendFakeLocationDestinationTest(){
    _locationUpdateTimer?.cancel();

    int iterationCount = 0; // Compteur pour suivre le nombre d'itérations
    const int maxIterations = 7; // Le nombre maximum d'itérations

    void updateLocationDest() {
      if (iterationCount >= maxIterations) {
        _locationUpdateTimer?.cancel(); // Si on a atteint le nombre d'itérations désiré, arrêtons le timer
        return; // Et sortons de la fonction
      }

      // Coordonnées de départ : antibes (pour la première itération seulement)
      double currentLatitude = 43.580418;
      double currentLongitude = 7.125102;

      // Coordonnées d'arrivée : cagnesSurMer

      final double destinationLatitude = LatitudeCagnes;
      final double destinationLongitude = LongitudeCagnes;

      // Calculons les différences de coordonnées et divisons par 5 pour 5 itérations
      final double latitudeIncrement = (destinationLatitude - currentLatitude) / 7;
      final double longitudeIncrement = (destinationLongitude - currentLongitude) / 7;

      _locationUpdateTimer = Timer.periodic(Duration(seconds: 8), (Timer t) {
        if (iterationCount < maxIterations) {
          // Incrémentons la position actuelle
          currentLatitude += latitudeIncrement;
          currentLongitude += longitudeIncrement;

          // Vérifions si nous avons atteint ou dépassé notre destination
          if (currentLatitude >= destinationLatitude && currentLongitude >= destinationLongitude) {
            currentLatitude = destinationLatitude;
            currentLongitude = destinationLongitude;
          }

          print("Envoi de la localisation fictive : latitude=$currentLatitude, longitude=$currentLongitude");

          // Création du paquet de données de localisation avec les coordonnées fictives
          /*final Map<String, dynamic>*/ locationData = {
            "latitude": currentLatitude,
            "longitude": currentLongitude,
          };

          // Envoi des données de localisation fictive au pair
          conn?.send(locationData.toString());

          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId("currentLocation"),
                //  position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                position: LatLng(locationData["latitude"], locationData["longitude"]),
                icon: driverIcon,

              ),
            );
          });

          iterationCount++; // Incrémentons le compteur d'itérations

          if (iterationCount == maxIterations) {
            _locationUpdateTimer?.cancel(); // Arrêtons le timer après la dernière itération
          }
        }
      });
    }

    updateLocationDest();
  }



  late BitmapDescriptor customIcon;

  void loadDriverIcon() async {
    driverIcon = await gmaps.BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'assets/driverIconNew.png');

    destinationIcon = await gmaps.BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'assets/destinationIconNew.png');

    passengerIcon = await gmaps.BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)),
        'assets/passengerIconNew.png');
  }



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
              zoom: 11,
            ),
          ),
        );
        if (!mounted) return;
        setState(() {
          // Coordonnées de départ : Antibes (pour la première itération seulement)
          double currentLatitude = 43.580418;
          double currentLongitude = 7.125102;

          _markers.add(
            Marker(
              markerId: MarkerId("currentLocation"),
            //  position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              position: LatLng(currentLatitude, currentLongitude),
              icon: passengerIcon,

            ),
          );
        });
      }
    });
  }
  void connect() {
    print("je suis dans DriverAccepted connect  passengerId=  $passengerId");
    final connection = peer.connect(passengerId.toString());
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
        if (!mounted) return;
        setState(() {

          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(latLng['latitude']!, latLng['longitude']!),
                zoom: 11,
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
    _locationUpdateTimer =  Timer.periodic(const Duration(seconds: 1), (Timer t) {
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
              // Ajoute un peu d'espace autour
              color: Colors.white,
              child:
              Card(
              elevation: 4, // Ajoute une petite ombre pour un effet de profondeur
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Arrondit les angles de la carte
              ),
              margin: EdgeInsets.all(12), // Ajoute de l'espace autour de la carte
              child: Padding(
                padding: EdgeInsets.all(12), // Espacement à l'intérieur de la carte
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Information sur le passager",
                      style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.blueAccent),
                    ),
                    SizedBox(height: 7), // Espacement vertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Nom: ${DataManager.instance.getUserById(widget.passengerId!).firstName} ${DataManager.instance.getUserById(widget.passengerId!).lastName}",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        _renderState(),
                        IconButton(
                          icon: Icon(Icons.chat, color: Colors.blueAccent),
                          onPressed: _handleChatIconPressed,
                          tooltip: 'Ouvrir le chat',
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Biographie: ${DataManager.instance.getUserById(widget.passengerId!).biography}",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            ),
          ),

          Expanded(
            flex: 7, // Donne plus d'espace à la carte
            child: gmaps.GoogleMap(
              mapType: gmaps.MapType.normal,
              initialCameraPosition: gmaps.CameraPosition(
                target: gmaps.LatLng(0, 0),
                zoom: 11,
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

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;    // Pi / 180
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }


  void _handleChatIconPressed() {
    conn?.close();
    peer.socket.close();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IndividualPage(
          chatModel: DataManager.instance.getUserById(widget.passengerId!),
          sourchat: DataManager.instance.getUser(),
        ),
      ),
    );
  }

}
