import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart'; // Assurez-vous que cette classe existe
import 'package:tpi_mybi/ui/views/Registration/registrationNew.dart'; // Assurez-vous que cette classe existe
import 'package:tpi_mybi/ui/widget/custom_theme.dart';
import 'package:tpi_mybi/ui/widget/home_btn.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de MediaQuery pour responsive design
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return CustomTheme(
      child: SingleChildScrollView( // Ajouté pour la gestion du défilement
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: IntrinsicHeight( // Assure que Column prend la hauteur minimale
            child: Column(
              children: [
                Flexible(
                  flex: screenWidth < 600 ? 2 : 1,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: screenWidth * 0.1, // Ajustement dynamique
                    ),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome !\n',
                              style: TextStyle(
                                color: myPrimaryColor,
                                fontSize: screenWidth < 600 ? 24.0 : 45.0, // Ajustement dynamique
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(), // Utilisé pour pousser le contenu vers le haut/bas
                Flexible(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: [
                        Expanded(
                          child: HomeBtn(
                            buttonText: 'Sign in',
                            onClick: SignInScreen(), // Exemple de navigation
                            color: Colors.transparent,
                            textColor: myPrimaryColor,
                          ),
                        ),
                        Expanded(
                          child: HomeBtn(
                            buttonText: 'Sign up',
                            onClick: SignUpScreen(), // Exemple de navigation
                            color: Colors.transparent,
                            textColor: myPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(), // Ajouté pour l'équilibre visuel
              ],
            ),
          ),
        ),
      ),
    );
  }
}
