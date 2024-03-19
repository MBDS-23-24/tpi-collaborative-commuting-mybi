import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';
import 'package:tpi_mybi/model/User.dart';

import '../../../Data/DataLoader.dart';
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
  late Peer peer = Peer( id:"myid2" );
  final TextEditingController _controller = TextEditingController();
  String? peerId;
  bool me = false;
  late gmaps.BitmapDescriptor driverIcon, destinationIcon, passengerIcon;

  PeerConnectOption peerop =PeerConnectOption();
  late DataConnection? conn = DataConnection('false',null,peerop) ;
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
  //  _initLocationService();

    loadIcons();

    //print("jes suis dans passangerAccepted peerop =  ${peer.id.toString()}");
    super.initState();
    connect();

    // peer = Peer(id: DataManager.instance.getUserById(widget.DriverID).toString());
    // UserModel user = DataManager.instance.getUser();
    //peer = Peer(id: user.userID.toString());
   // print("je suis dans passangerAccepted userId = ${user.userID.toString()}");
    peer.on("open", null, (ev, context) {
      setState(() {
        print("jes suis dans passangerAccepted open peer.id =  ${peer.id}");
        peerId = peer.id;
      });
    });

    peer.on("connection", null, (ev, context) {
      print("jes suis dans passangerAccepted peer connection  ev.eventData=  ${ev.eventData}");
      conn = ev.eventData as DataConnection;
      setState(() {
        connected = true;
      });
    });


    peer.on("data", null, (ev, _) {
      print("je suis dans passangerAccepted peer data dans initState data=  ${ev.eventData}");
      final data = ev.eventData as String;

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
      Map<String, double> latLng = parseLatLng(data);
      if (!mounted) return;
      setState(() {
        print("je suis dans passangerAccepted data dans initState data=  ${latLng['latitude']}");



        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latLng['latitude']!, latLng['longitude']!),
              zoom: 11,
            ),
          ),
        );

        _markers.add(
          Marker(
              markerId: MarkerId("peerLocation"),
              position: LatLng(latLng['latitude']!, latLng['longitude']!),
              icon: driverIcon
          ),
        );

        _markers.add(
          Marker(
              markerId: MarkerId("currentLocation"),
              position: LatLng(43.580418, 7.125102),
              icon: passengerIcon
          ),
        );



  print("distance ======== ${calculateDistance(latLng['latitude']!, latLng['longitude']!, 43.5749038, 7.125102)}");
   if (calculateDistance(latLng['latitude']!, latLng['longitude']!, 43.5749038, 7.125102) <= 0.9) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // Variable pour stocker le commentaire saisi par l'utilisateur
              String userComment = '';

              // Variable pour stocker la note
              double rating = 3.0;


              return AlertDialog(
                title: const Text('Noter le conducteur'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Donnez une note et un commentaire à ce conducteur.'),
                      // Widget de notation
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (newRating) {
                          print(newRating);
                          rating = newRating; // Met à jour la note
                        },
                      ),
                      SizedBox(height: 20), // Ajoute un espace entre les éléments
                      // Champ de saisie pour le commentaire
                      TextField(
                        onChanged: (value) {
                          userComment = value; // Met à jour le commentaire à chaque saisie
                        },
                        decoration: InputDecoration(
                          hintText: "Entrez votre commentaire ici",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Ferme la popup
                    },
                  ),
                  TextButton(
                    child: const Text('Soumettre'),
                    onPressed: () {
                      // Ici, vous pouvez gérer la soumission de la note et du commentaire
                      // Par exemple, en les envoyant à un serveur ou en les stockant localement
                      DataLoader.instance.rateUser(widget.DriverID, rating, userComment);
                      Navigator.of(context).pop();

                      // Ferme la popup après la soumission
                    },
                  ),
                ],
              );



            }

        );
        peer.clear();
        conn?.close();
      }


      });



      setState(() {
        _markers.add(
          Marker(
              markerId: MarkerId("destination"),
              position: LatLng(43.6645, 7.1482),
              icon: destinationIcon
          ),
        );
      });

    });




    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/driverIconNew.webp')
        .then((d) {
      customIcon = d;
    });
  }



  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;    // Pi / 180
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }






  late BitmapDescriptor customIcon;

  void loadIcons() async {
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
                zoom: 11,
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
    print("je suis dans passangerAccepted connect()  peer.id =  ${widget.DriverID.toString()}");
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
                zoom: 11,
              ),
            ),
          );

          print("je suis dans passangerAccepted data  data=  ${latLng['latitude']}");
          _markers.add(
            Marker(
                markerId: MarkerId("peerLocation"),
                position: LatLng(latLng['latitude']!, latLng['longitude']!),
                icon:driverIcon /*BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)*/

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

  late Map<String, dynamic> locationData;

  void sendLocationUpdatesTest() {
    _locationUpdateTimer?.cancel();
    // Function to send static location updates to peer every 150 seconds
    _locationUpdateTimer =  Timer.periodic(const Duration(seconds: 1), (Timer t) {
      // Localisation statique d'Antibes, France pour le test
      const double staticLatitude = 43.580418; // Latitude statique d'Antibes
      const double staticLongitude = 7.125102; // Longitude statique d'Antibes

      print("Envoi de la localisation statique d'Antibes: latitude=$staticLatitude longitude=$staticLongitude");

      // Création du paquet de données de localisation avec les coordonnées statiques
      locationData = {
        "latitude": staticLatitude,
        "longitude": staticLongitude,
      };

      // Envoi des données de localisation statique au pair
      conn?.send(locationData.toString());
    });
  }

  void sendFakeLocationUpdates() {
    _locationUpdateTimer?.cancel();

    int iterationCount = 0; // Compteur pour suivre le nombre d'itérations
    const int maxIterations = 10; // Le nombre maximum d'itérations

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
      final double latitudeIncrement = (destinationLatitude - currentLatitude) / 10;
      final double longitudeIncrement = (destinationLongitude - currentLongitude) / 10;

      _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
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
          final Map<String, dynamic> locationData = {
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
            child:Card(
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
                      "Information sur le conducteur",
                      style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.blueAccent),
                    ),
                    SizedBox(height: 7), // Espacement vertical
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Nom: ${DataManager.instance.getUserById(widget.DriverID!).firstName} ${DataManager.instance.getUserById(widget.DriverID!).lastName}",
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
                      "Biographie: ${DataManager.instance.getUserById(widget.DriverID!).biography}",
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
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

  void _handleChatIconPressed() {
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
        Theme.of(context).textTheme.titleSmall?.copyWith(color: txtColor),
      ),
    );
  }
}