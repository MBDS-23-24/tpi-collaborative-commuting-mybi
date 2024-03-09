import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../../CostumColor.dart';
import '../../../main.dart';
import 'ExamplePage.dart';

class FullMapPage extends ExamplePage {
  FullMapPage() : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: MapWidget(),
        ),
        Expanded(
          flex: 1,
          child: TextWidget(),
        ),
      ],
    );
  }
}

class MapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FullMap();
  }
}

class TextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your Text Here',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMapController? mapController;
  var isLight = true;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Style loaded :)"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      styleString: isLight ? MapboxStyles.LIGHT : MapboxStyles.DARK,
      accessToken: accessToken,
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(target: LatLng(48.8566, 2.3522)),
      onStyleLoadedCallback: _onStyleLoadedCallback,
    );
  }
}
