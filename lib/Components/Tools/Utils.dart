class Utils {
  static String convertirFormatDate(String dateString) {
    // Convertir la chaîne en objet DateTime (avec seulement la date)
    DateTime? dateTime = DateTime.tryParse(dateString);

    if (dateTime != null) {
      // Formater la date en 'yyyy-MM-dd' (sans l'heure)
      String date = /*'${dateTime.year}-${_ajouterZero(dateTime.month)}-${_ajouterZero(dateTime.day)} /'*/ '${_ajouterZero(dateTime.hour)}:${_ajouterZero(dateTime.minute)} ';

      // Retourner la date formatée
      return date;
    } else {
      // Gérer le cas où la chaîne de date est invalide
      return 'Date invalide';
    }
  }

  static String _ajouterZero(int number) {
    // Ajouter un zéro devant les nombres inférieurs à 10
    return number.toString().padLeft(2, '0');
  }
}
