import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddressSearch extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  // Vous pouvez personnaliser cette liste avec des suggestions d'adresses réelles
  final List<String> suggestions = [
    '123 Main Street',
    '456 Elm Street',
    '789 Oak Avenue',
    '101 Pine Road',
  ];

  AddressSearch({super.key});

  @override
  Widget build(BuildContext context) {
    const SizedBox.shrink();
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Recherche d\'adresse',
          hintText: 'Entrez une adresse',
        ),
      ),
      suggestionsCallback: (pattern) {
        return suggestions.where((address) =>
            address.toLowerCase().contains(pattern.toLowerCase()));
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      noItemsFoundBuilder: (context) {
        return SizedBox.shrink(); // Masque la liste si aucune suggestion n'est trouvée
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion;
      },
    );
  }
}
