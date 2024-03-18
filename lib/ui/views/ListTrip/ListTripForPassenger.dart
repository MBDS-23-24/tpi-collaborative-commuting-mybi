import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpi_mybi/model/Trip.dart'; // Assurez-vous que le chemin d'importation est correct
import 'TripDetail.dart'; // Assurez-vous que le chemin d'importation est correct

// Assurez-vous d'avoir les bons imports pour DataManager, VoyageModel, UserModel

class ListTripForPassenger extends StatefulWidget {
  final List<VoyageModel> trips;

  ListTripForPassenger({required this.trips});

  @override
  _ListTripForPassengerState createState() => _ListTripForPassengerState();
}

class _ListTripForPassengerState extends State<ListTripForPassenger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trips", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: widget.trips.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No trips available. Try changing the dates :)",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      )
          : ListView.builder(
        itemCount: widget.trips.length,
        itemBuilder: (context, index) {
          final voyage = widget.trips[index];
          final bool isUpcoming = voyage.timestamp.isAfter(DateTime.now());
          final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(voyage.timestamp);
          final statusText = isUpcoming ? "Upcoming" : "Past";
          final statusIcon = isUpcoming ? Icons.event_available : Icons.event_busy;
          final cardColor = isUpcoming ? Colors.green[400] : Colors.red[400];

          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TripDetailScreen(trip: voyage)),
            ),
            child: Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: cardColor,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 40),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${voyage.depart} -> ${voyage.destination}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 5),
                          Text("Seats: ${voyage.placeDisponible}", style: TextStyle(color: Colors.white70)),
                          Text("$statusText on $formattedDate", style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
