import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';

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
    peer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initLocationService();
    print("jes suis dans passangerAccepted peerop =  ${peer.id.toString()}");
    super.initState();
    connect();
    print("jes suis dans passangerAccepted ");
    peer.on("open", null, (ev, context) {
      setState(() {
        print("jes suis dans passangerAccepted open peer.id =  ${peer.id}");
        peerId = peer.id;
      });
    });

    peer.on("connection", null, (ev, context) {
      print("jes suis dans passangerAccepted connection  ev.eventData=  ${ev.eventData}");
      conn = ev.eventData as DataConnection;

      setState(() {
        connected = true;
      });
    });

    peer.on("data", null, (ev, _) {
      print("jes suis dans passangerAccepted data  data=  ${ev.eventData}");
      final data = ev.eventData as String;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
    });
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
  late String meTest;
  void connect() {
    meTest= widget.DriverID.toString();
    String me= widget.DriverID.toString();
    final connection = peer.connect(widget.DriverID.toString());
    print ("jes suis dans passangerAccepted connect()  connection=  $connection with id = ${peerId}");
    conn = connection;

    conn?.on("open", null, (ev, _) {
      setState(() {
        connected = true;
      });

      conn?.on("data", null, (ev, _) {
        print("jes suis dans passangerAccepted data  data=  ${ev.eventData}");
        final dynamic data = ev.eventData;

        if (data is String) {
          // Handle "Hello world!" message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data)));
        } else if (data is Map<String, dynamic>) {
          // Handle location updates
          final double latitude = data["latitude"];
          final double longitude = data["longitude"];

          // Process latitude and longitude received from the peer
          // Example: Update markers on the map
          setState(() {
            _markers.add(
              Marker(
                markerId: MarkerId("peerLocation"),
                position: LatLng(latitude, longitude),
              ),
            );
          });
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 5,
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
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _renderState(),
                     Text(
                      'Connection ID: {$meTest}  ',
                    ),
                    SelectableText("Peer ID = ${peerId}"),
                    ElevatedButton(
                      onPressed: () {
                        sendHelloWorld();
                      },
                      child: const Text("Send Hello World to peer"),
                    ),
                  ],
                ),
              ),
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