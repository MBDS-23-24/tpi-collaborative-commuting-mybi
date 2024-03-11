import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../model/request.dart';

class DriverRequestsPage extends StatefulWidget {
  @override
  _DriverRequestsPageState createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  final List<dynamic> _driverRequests = [];
  late IO.Socket _socket;
  late IO.Socket socket;

  /*@override
  void initState() {
    super.initState();
    // Connect to WebSocket server
    _socket = IO.io('https://integrationlalabi.azurewebsites.net', <String, dynamic>{
      'transports': ['websocket'],
    });

    // Listen for incoming messages
    _socket.on('message', (data) {
      // Handle incoming messages (fake driver requests)
      setState(() {
        // Add the received data to the list of driver requests
        _driverRequests.add(data);
      });
    });
  }*/

  @override
  void initstate(){
    initstate();
    super.initState();
  }
  initSocket(){
    socket = IO.io("https://integrationlalabi.azurewebsites.net",<String,dynamic>{
    'transports':['websocket'],
    });
    socket.connect();
    socket.onConnect((_){
      print("Connection established");
    });
    socket.on('getMessageEvent',(data){
      print(data);
      _driverRequests.add(Request.fromJson(data));
    });
    socket.onDisconnect((_)=>print("connection Disconnection"));
    socket.onConnectError((err)=>print(err));
    socket.onError((err)=>print(err));


  }


  @override
  void dispose() {
    // Disconnect from WebSocket when the widget is disposed
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Requests'),
      ),
      body: ListView.builder(
        itemCount: _driverRequests.length,
        itemBuilder: (context, index) {
          final request = _driverRequests[index];
          return ListTile(
            title: Text('Request: $request'),
          );
        },
      ),
    );
  }
}
