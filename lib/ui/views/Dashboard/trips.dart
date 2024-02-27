import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:geolocator/geolocator.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:flutter_location_search/flutter_location_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;


import 'package:http/http.dart' as http;
import 'dart:convert';


class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

Future<gmaps.LatLng> _getCurrentLocation() async {
  var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  return gmaps.LatLng(position.latitude, position.longitude);
}

class _TripsScreenState extends State<TripsScreen> {
  late gmaps.GoogleMapController mapController;
  final gmaps.LatLng _center = const gmaps.LatLng(48.8566, 2.3522);
  final Set<gmaps.Marker> _markers = {};
  bool _isFindRideSelected = true;
  String _pickupLocationText = 'Depart  location';
  String _destinationLocationText = 'Destination location';
  Set<gmaps.Polyline> _polylines = {};
  Future<void> _getDirections(gmaps.LatLng start, gmaps.LatLng end) async {
    final apiUrl = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey");
    final response = await http.get(apiUrl);
    print(response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<gmaps.LatLng> points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
      setState(() {
        _polylines.clear();
        _polylines.add(
          gmaps.Polyline(
            polylineId: gmaps.PolylineId('route'),
            color: Colors.blue, // Define the color of the polyline
            width: 7, // Define the width of the polyline
            points: points, // Use the decoded points from the Directions API
          ),
        );
      });
    }
  }

  List<gmaps.LatLng> _decodePolyline(String encoded) {
    List<gmaps.LatLng> poly = [];
    int index = 0;
    int len = encoded.length;
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

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;
      gmaps.LatLng position = gmaps.LatLng(latitude, longitude);
      poly.add(position);
    }
    return poly;
  }

  void _onMapCreated(gmaps.GoogleMapController controller) async {
    mapController = controller;
    var currentLocation = await _getCurrentLocation();

    String mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_style.json');
    mapController.setMapStyle(mapStyle);

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
    });
  }
  /*
  void _updatePolyline(gmaps.LatLng start, gmaps.LatLng end) {
    setState(() {
      _polylines.clear();
      _polylines.add(
        gmaps.Polyline(
          polylineId: gmaps.PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: [start, end], // Define the points of the polyline
        ),
      );
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trips',
          style: TextStyle(color: Colors.white), // Ajoutez cette ligne pour changer la couleur en blanc
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
              polylines: _polylines, // Add the polylines to the map

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
                      Expanded(child: _buildLocationTile(Icons.calendar_today, 'Date & time', () {/* handle date & time */})),
                      Expanded(child: _buildLocationTile(Icons.person, 'No. of seat', () {/* handle number of seats */})),
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
    return ListTile(
      leading: Icon(icon, color: myPrimaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildFindRideButton() {
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
      onPressed: () {
        // Handle find ride
      },
      child: Center(
        child: Text('Find ride'),
      ),
    );
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
            _markers.add(
              gmaps.Marker(
                markerId: gmaps.MarkerId('destinationLocation'),
                position: gmaps.LatLng(locationData.latitude, locationData.longitude),
                icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue), // Set a different marker color for destination
              ),
            );

            _destinationLocationText = locationData.address;

            _getDirections(
              gmaps.LatLng(_markers.firstWhere((marker) => marker.markerId.value == 'departLocation').position.latitude,
                  _markers.firstWhere((marker) => marker.markerId.value == 'departLocation').position.longitude),
              gmaps.LatLng(locationData.latitude, locationData.longitude),
            );

          }
        });
      }
    }
  }
}
