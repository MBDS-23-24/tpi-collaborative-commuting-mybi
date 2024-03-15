import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpi_mybi/model/Passenger.dart';

// Assurez-vous d'avoir les bons chemins d'import pour vos modèles et DataLoader
import '../../../Data/DataLoader.dart';
import '../../../Data/DataManager.dart';
import '../../../model/Trip.dart';
import '../../../model/User.dart';
import '../Dashboard/dashboard.dart';

class TripDetailScreen extends StatefulWidget {
  final VoyageModel trip;

  TripDetailScreen({required this.trip});

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}
class _TripDetailScreenState extends State<TripDetailScreen> {
  UserModel? _user;
  List<Passenger>? passengers;
  UserModel? currentUser;
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  void _loadUserInformation() async {
    _user = await DataLoader.instance.getUser(widget.trip.conducteurId);
    passengers = await DataLoader.instance.getPassengersByIdTrip(widget.trip.voyageId);
    print(passengers);
    print(passengers?[0].email);
    currentUser = DataManager.instance.getUser();
    setState(() {
      _isLoading = false; // Les données sont chargées, on arrête l'indication de chargement
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Affiche un indicateur de chargement pendant le chargement des données
        ),
      );
    }

    // Une fois les données chargées, on affiche le contenu de la page
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedDate = dateFormat.format(widget.trip.timestamp);
    final bool isUpcoming = widget.trip.timestamp.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Trip Information", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailItem(label: "From", value: widget.trip.depart),
                      Divider(),
                      DetailItem(label: "To", value: widget.trip.destination),
                      Divider(),
                      DetailItem(label: "Date", value: formattedDate),
                      Divider(),
                      DetailItem(label: "Available seats", value: "${widget.trip.placeDisponible}"),
                      Divider(),
                      DetailItem(label: "Status", value: isUpcoming ? "Upcoming" : "Past", valueStyle: TextStyle(color: isUpcoming ? Colors.green : Colors.orange)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_user != null)
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Driver Information:", style: Theme.of(context).textTheme.headline6),
                        Divider(),
                        DetailItem(label: "Name", value: "${_user!.firstName} ${_user!.lastName}"),
                        DetailItem(label: "Email", value: _user!.email ?? 'No email'),
                        if (currentUser?.role == "PASSAGER") // Ajouter conditionnellement l'icône de message
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Aligner l'icône à droite
                            children: [
                              IconButton(
                                icon: Icon(Icons.message, color: Colors.blue),
                                onPressed: () {
                                  // Logique pour ouvrir la conversation avec le conducteur ici
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: 20),
              // Passengers information
              if (passengers != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Passengers Information:", style: Theme.of(context).textTheme.headline6),
                      Divider(),
                      ...?passengers?.map((passenger) => Column(
                        children: [
                          ListTile(
                            title: Text("${passenger.firstName} ${passenger.lastName}"),
                            subtitle: Text(passenger.email ?? 'No email'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // Important pour s'assurer que le Row s'adapte au contenu
                              children: [
                                if (currentUser?.role=="CONDUCTEUR") // Supposons que isAccepted détermine si le bouton Accepter doit être affiché
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implémentez la logique pour accepter le passager ici
                                    },
                                    child: Text('Accept'),
                                  ),
                                if (currentUser?.role=="CONDUCTEUR") // Supposons que isAccepted détermine si le bouton Accepter doit être affiché
                                  IconButton(
                                  icon: Icon(Icons.message, color: Colors.blue),
                                  onPressed: () {
                                    // Logique pour ouvrir la conversation avec le passager ici
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              // Logique pour voir le profil du passager
                            },
                          ),
                          Divider(),
                        ],
                      )),

                    ],
                  ),
                ),
              ),
              // Boutons Modifier et Supprimer le voyage
              Padding(
                padding: EdgeInsets.only(top: 7), // Ajoute un espace en haut de 7 pixels
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    currentUser!.role == "CONDUCTEUR"
                        ? ElevatedButton(
                      onPressed: () {
                        // Logique pour supprimer le voyage
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.red[300]),
                      child: Text("Delete Trip"),
                    )
                        : ElevatedButton(
                      onPressed: () {
                        requestTrip(widget.trip.voyageId,currentUser?.userID);
                        },
                      style: ElevatedButton.styleFrom(primary: Theme.of(context).canvasColor),
                      child: Text("Request to Join Trip"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> requestTrip(int? voyageId, int? userID) async {
    String status = await DataLoader.instance.requestTrips(voyageId,userID);

      if(status == "Your Request created successfully" ){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status)),
        );
        // Add a slight delay to allow the user to see the SnackBar message
        await Future.delayed(Duration(seconds: 1));
        // Navigate to the ListTripScreenListTripScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  DashboardScreen(user: DataManager.instance.getUser())),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status)),
        );
      }

  }
}

class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  DetailItem({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: valueStyle ?? TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
