import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({Key? key, required this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

void handleMenuSelection(String value, BuildContext context) {
  switch (value) {
    case 'logout':
      FirebaseAuth.instance.signOut().then((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInScreen()));
      });
      break;
  }
}
