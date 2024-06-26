import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpi_mybi/model/Passenger.dart';

// Assurez-vous d'avoir les bons chemins d'import pour vos modèles et DataLoader
import '../../../Data/DataLoader.dart';
import '../../../Data/DataManager.dart';
import '../../../model/Trip.dart';
import '../../../model/User.dart';
import '../Chat/IndividualPage.dart';
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
    currentUser = DataManager.instance.getUser();
    if (mounted) {
      setState(() {
        _isLoading = false; // Les données sont chargées, on arrête l'indication de chargement
      });
    }
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
                                  onPressed: () async {
                                    UserModel? passengerInstaceUcer = await DataLoader.instance.getUser(_user?.userID);
                                    if(passengerInstaceUcer != null)
                                      Navigator.push( context, MaterialPageRoute( builder: (contex) => IndividualPage( chatModel:passengerInstaceUcer   , sourchat:DataManager.instance.getUser() )));
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
              if (passengers != null)              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Passengers Information:", style: Theme.of(context).textTheme.headline6),
                      Divider(),
                      // Filter out passengers with "REFUSE" status before mapping
                      ...?passengers?.where((passenger) => passenger.status != "REFUSE").map((passenger) => Column(
                        children: [
                          ListTile(
                            title: Text("${passenger.firstName} ${passenger.lastName}"),
                            subtitle: Text(passenger.email ?? 'No email'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min, // Important pour s'assurer que le Row s'adapte au contenu
                              children: [
                                if (currentUser?.role == "CONDUCTEUR" && passenger.status == "EN-ATTENTE")
                                  ElevatedButton(
                                    onPressed: () {
                                      onchangeEtat("ACCETPTE", widget.trip.voyageId, passenger.userID);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green, // Définit la couleur de fond du bouton à vert
                                    ),
                                    child: Text('Accept'),
                                  ),
                                if (currentUser?.role == "CONDUCTEUR" && passenger.status == "EN-ATTENTE")
                                  ElevatedButton(
                                    onPressed: () {
                                      onchangeEtat("REFUSE", widget.trip.voyageId, passenger.userID);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red, // Définit la couleur de fond du bouton à rouge
                                    ),
                                    child: Text('Refuse'),
                                  ),
                                if (currentUser?.role == "CONDUCTEUR")
                                  IconButton(
                                    icon: Icon(Icons.message, color: Colors.blue),
                                    onPressed: () async {
                                      UserModel? passengerInstaceUcer = await DataLoader.instance.getUser(passenger.userID);
                                      if(passengerInstaceUcer != null)
                                      Navigator.push( context, MaterialPageRoute( builder: (contex) => IndividualPage( chatModel:passengerInstaceUcer   , sourchat:DataManager.instance.getUser() )));
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {
                              // badis ici ajoute la redrection de profil
                            },
                          ),
                          Divider(),
                        ],
                      )).toList(), // Convert the filtered and mapped iterable to a list
                    ],
                  ),
                ),
              ),
              // Boutons Modifier et Supprimer le voyage
              Padding(
                    padding: EdgeInsets.only(top: 7), // Adds space at the top of 7 pixels
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    if (currentUser!.role == "PASSAGER" && widget.trip.placeDisponible > 0)
                        ElevatedButton(
                        onPressed: () {
                        requestTrip(widget.trip.voyageId, currentUser?.userID);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).canvasColor),
                        child: Text("Request to Join Trip"),
                        )
                        else if (currentUser!.role == "PASSAGER" && widget.trip.placeDisponible <= 0)
                       Text("No more seats available", style: TextStyle(color: Colors.red)),
    // Optionally, add other conditions as needed
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

  Future<void> onchangeEtat(String status, int? voyageId, int? userID) async {

   bool result = await DataLoader.instance.changeEtatPassenger(status,voyageId,userID);

   if(result){
     String s= status == "ACCETPTE" ? "Passenger Accepted  successfully" : "Passenger Refused  successfully";
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(s)),
     );
     // Add a slight delay to allow the user to see the SnackBar message
     await Future.delayed(Duration(seconds: 1));
     // Navigate to the ListTripScreenListTripScreen
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) =>  DashboardScreen(user: DataManager.instance.getUser())),
     );

   }
   else{
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text("Problem with server")),
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
