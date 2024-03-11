import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/* Exemple d'utilisation
    ButtonImagePicker(
                onImageSelected: (imagePath) {
                  // Utilisez imagePath ici pour traiter ou afficher l'image sélectionnée.
                  print(imagePath);
                },)
 */

class ButtonImagePicker extends StatelessWidget {
  final Function(String)? onImageSelected;

  const ButtonImagePicker({Key? key, this.onImageSelected}) : super(key: key);

  Future<void> _getImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      onImageSelected?.call(imagePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune image sélectionnée'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _getImageFromGallery(context);
      },
      child: Text('Télécharger une image'),
    );
  }
}
