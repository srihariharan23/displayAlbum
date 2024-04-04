import 'package:flutter/material.dart';
import '../model/photo_model.dart';

class PhotosScreen extends StatelessWidget {
  final List<Photo> photos;

  const PhotosScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: const Text('Photos',
          style: TextStyle(
              color: Colors.white
          ),),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(photos.length, (index) {
          return
            Column(
          children: [
            Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              color: Colors.blueGrey,
              height: 50,
              child: Image.network(
                        photos[index].url,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
            ),
          ),
            Padding(padding: const EdgeInsets.all(20),
            child:
            Text(photos[index].title))
          ]);
        }),
      ),
    );
  }
}
