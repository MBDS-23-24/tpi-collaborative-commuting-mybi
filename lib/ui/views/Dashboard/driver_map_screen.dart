import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tpi_mybi/CostumColor.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  Set<Polyline> _polylines = {};

  final CameraPosition _initialLocation = CameraPosition(target: LatLng(37.4220, -122.0841), zoom: 12);

  Future<void> getDirections(String origin, String destination) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> routes = data["routes"];
      if (routes.isNotEmpty) {
        routes.forEach((route) {
          List<dynamic> legs = route["legs"];
          legs.forEach((leg) {
            List<dynamic> steps = leg["steps"];
            steps.forEach((step) {
              Map<String, dynamic> polyline = step["polyline"];
              String points = polyline["points"];
              List<LatLng> decodedPoints = _decodePoly(points);
              _polylines.add(Polyline(
                polylineId: PolylineId('poly'),
                color: Colors.blue,
                points: decodedPoints,
                width: 5,
              ));
            });
          });
        });
      }

      setState(() {});
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latLng = lat / 1E5;
      double lngLng = lng / 1E5;
      LatLng position = LatLng(latLng, lngLng);
      poly.add(position);
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Maps Demo'),
        ),
        body: GoogleMap(
          initialCameraPosition: _initialLocation,
          polylines: _polylines,
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            // Fetch directions when map is created
            getDirections("37.4220,-122.0841", "37.4250,-122.0842");
          },
        ),
      ),
    );
  }
}
