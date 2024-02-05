import 'package:flutter/material.dart';
import 'package:tpi_mybi/model/User.dart' as model;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/home.dart';
import 'firebase_options.dart';
import 'ui/views/Dashboard/dashboard.dart';
import 'ui/views/Login/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<auth.User?>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is logged in
            auth.User? user = snapshot.data;
            if (user == null) {
              // User not logged in, show SignInScreen
              return HomeView();
            }
            // User is logged in, convert User to UserModel and show DashboardScreen
            UserModel userModel = UserModel.fromFirebaseUser(user);
            return DashboardScreen(user: userModel);
          }
          // Waiting for authentication state to be available
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
