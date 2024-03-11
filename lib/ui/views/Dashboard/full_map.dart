import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class FullMapPage extends StatefulWidget {
  @override
  _FullMapPageState createState() => _FullMapPageState();
}

class _FullMapPageState extends State<FullMapPage> {
  GoogleMapController? mapController;
  List<LatLng> routeCoordinates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Map Page'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.4220, -122.0841),
          zoom: 15.0,
        ),
        polylines: {
          Polyline(
            polylineId: PolylineId('route'),
            points: routeCoordinates,
            color: Colors.blue,
            width: 3,
          ),
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });

    fetchData();
  }

  Future<void> fetchData() async {
    final String apiKey = 'YOUR_API_KEY_HERE';
    final String origin = '37.4220,-122.0841';
    final String destination = '37.4250,-122.0842';

    final String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';
    final Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final routes = decodedData['routes'] as List<dynamic>;
      final route = routes.isNotEmpty ? routes[0] : null;

      if (route != null) {
        final encodedPolyline = route['overview_polyline']['points'] as String;
        final List<PointLatLng> decodedPolyline = PolylinePoints().decodePolyline(encodedPolyline);
        routeCoordinates.clear();
        decodedPolyline.forEach((PointLatLng point) {
          routeCoordinates.add(LatLng(point.latitude, point.longitude));
        });

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: routeCoordinates.first,
                northeast: routeCoordinates.last,
              ),
              100.0,
            ),
          );
        }
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

}

