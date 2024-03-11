import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_webrtc/flutter_webrtc.dart';
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late gmaps.GoogleMapController mapController;
  double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
  double _destLatitude = 6.849660, _destLongitude = 3.648190;
  // double _originLatitude = 26.48424, _originLongitude = 50.04551;
  // double _destLatitude = 26.46423, _destLongitude = 50.06358;
  Map<gmaps.MarkerId, gmaps.Marker> markers = {};
  Map<gmaps.PolylineId, gmaps.Polyline> polylines = {};
  List<gmaps.LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyChol6fOuzd8OZNrd0tNC7YNN6c0ckRde4";

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(gmaps.LatLng(_originLatitude, _originLongitude), "origin",
        gmaps.BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(gmaps.LatLng(_destLatitude, _destLongitude), "destination",
        gmaps.BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: gmaps.GoogleMap(
            initialCameraPosition: gmaps.CameraPosition(
                target: gmaps.LatLng(_originLatitude, _originLongitude), zoom: 15),
            myLocationEnabled: true,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set<gmaps.Marker>.of(markers.values),
            polylines: Set<gmaps.Polyline>.of(polylines.values),
          )),
    );
  }

  void _onMapCreated(gmaps.GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(gmaps.LatLng position, String id, gmaps.BitmapDescriptor descriptor) {
    gmaps.MarkerId markerId = gmaps.MarkerId(id);
    gmaps.Marker marker =
    gmaps.Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  _addPolyLine() {
    gmaps.PolylineId id = gmaps.PolylineId("poly");
    gmaps.Polyline polyline = gmaps.Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(gmaps.LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}