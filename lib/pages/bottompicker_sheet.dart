import 'package:flutter/material.dart';

void bottomPickerSheet(BuildContext context, Function imageFromCamera,
    Function imageFromGallery) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                imageFromCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                imageFromGallery();
                Navigator.pop(context);
              },
            )
          ],
        ));
      });
}
