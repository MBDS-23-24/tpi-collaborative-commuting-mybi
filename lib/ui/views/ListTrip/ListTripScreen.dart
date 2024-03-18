
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/Trip.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Chat/LatestMessageModel.dart';

import '../../../Components/CustomCard.dart';
import '../../../Data/DataLoader.dart';
import 'TripDetail.dart';

class ListTripScreen extends StatefulWidget {
  ListTripScreen(/*{ required this.chatmodels, required this.sourchat}*/) ;

  @override
  _ListTripScreenState createState() => _ListTripScreenState();
}



class _ListTripScreenState extends State<ListTripScreen> {

  List<VoyageModel> _trips = [];
  UserModel? _user = null;
  late DataManager dataManager;
  String titlepage='';
  @override
  void initState() {
    super.initState();
    dataManager = DataManager.instance;
    _loadVoyages();
  }

  void _loadVoyages() async {
    DataLoader dataLoader = DataLoader.instance;
    _user = dataManager.getUser();
    titlepage = _user?.role == "CONDUCTEUR" ? "List of My Proposed Trips" : "List of Trips I've Joined";
    List<VoyageModel> voyages = await dataLoader.getVoyages(); // Adaptez les paramètres selon vos besoins
    setState(() {
      _trips = voyages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titlepage,
          style: TextStyle(color: Color(0xFF3FCC69)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement your action here
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
        body: Center(
          child: ListView.builder(
            itemCount: _trips.length,
            itemBuilder: (context, index) {
              final VoyageModel voyage = _trips[index];
              final bool isUpcoming = voyage.timestamp.isAfter(DateTime.now());
              final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(voyage.timestamp);
              final String statusText = isUpcoming ? "Upcoming" : "Past";
              final IconData statusIcon = isUpcoming ? Icons.event_available : Icons.event_busy;
              final Color cardColor = isUpcoming ? Colors.green : Colors.orange;

              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TripDetailScreen(trip: voyage),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.directions_car, color: Colors.white, size: 40),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${voyage.depart} -> ${voyage.destination}",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Available seats: ${voyage.placeDisponible}",
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Text(
                              "$statusText on $formattedDate",
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Icon(statusIcon, color: Colors.white, size: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
    );
  }
}
