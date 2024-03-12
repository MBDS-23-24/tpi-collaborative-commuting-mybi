import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_maps_widget/google_maps_widget.dart' as gmaps;
import 'package:google_maps_widget/google_maps_widget.dart';
import 'package:location/location.dart';
import 'package:peerdart/peerdart.dart';
import 'package:tpi_mybi/ui/views/Dashboard/webRTC/webRtcManager.dart';



class PassangerAcceptedWebRtc extends StatefulWidget {
  PassangerAcceptedWebRtc({Key? key}) : super(key: key);

  @override
  State<PassangerAcceptedWebRtc> createState() => _PassangerAcceptedState();
}

class _PassangerAcceptedState extends State<PassangerAcceptedWebRtc> {

  late webRtcManager manager;
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _currentLocation;
  late RTCDataChannel locationChannel;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    manager = webRtcManager();
    manager.initWebRTC();
    locationChannel = createDataChannel() as RTCDataChannel;
    _initLocationService();


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
      /*
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

       */
    });
  }


  Future<RTCDataChannel> createDataChannel() async {

    return await manager.createDataChannel();
  }

  void shareLocation() {
    var currentLocation = _currentLocation; // Implémentez cette fonction selon votre logique d'application
    var locationData = jsonEncode({
      'latitude': _currentLocation?.latitude,
      'longitude': _currentLocation?.longitude,
    });

    locationChannel.send(RTCDataChannelMessage(locationData));
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

              },

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
                    const Text(
                      'Connection ID:',
                    ),
                    SelectableText("Peer ID"),
                    ElevatedButton(
                      onPressed: () {

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
    //Color bgColor = connected ? Colors.green : Colors.grey;
    Color txtColor = Colors.white;
    //String txt = connected ? "Connected" : "Standby";
    return Container(
      //decoration: BoxDecoration(color: bgColor),
      child: Text(
        "Connected",
      ),
    );
  }
}
