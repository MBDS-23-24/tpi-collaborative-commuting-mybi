import 'package:flutter/material.dart';


/* Exemple d'utilisation
 CustomButton(
          enabled: true,
          text: 'Bouton',
          buttonType: ButtonType.filled, // Bouton sans style
          onPressed: () {
            // Fonction à exécuter lorsque le bouton est pressé
            print("button cliqué");
          },
          filledButtonColor: Colors.purple,
          textColor: Colors.white,
        )
 */

enum ButtonType {
  filled,
  outlined,
  none,
}

class CustomButton extends StatelessWidget {
  final bool enabled;
  final String text;
  final ButtonType buttonType;
  final VoidCallback? onPressed;
  final Color? filledButtonColor;
  final Color? outlinedButtonColor;
  final Color? textColor;

  CustomButton({
    super.key,
    required this.enabled,
    required this.text,
    this.buttonType = ButtonType.none,
    this.onPressed,
    this.filledButtonColor,
    this.outlinedButtonColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (buttonType) {
      case ButtonType.filled:
        return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            primary: filledButtonColor ?? Colors.blue,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.white,
            ),
          ),
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: outlinedButtonColor ?? Colors.blue,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.blue,
            ),
          ),
        );
      default:
      // Par défaut, créez un bouton texte sans style particulier
        return TextButton(
          onPressed: enabled ? onPressed : null,
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? Colors.black, // Couleur de texte par défaut
            ),
          ),
        );
    }
  }
}


