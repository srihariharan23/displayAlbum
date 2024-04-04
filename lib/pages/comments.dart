import 'package:flutter/material.dart';
import '../../model/comments_model.dart';

class CommentsScreen extends StatelessWidget {
  final CommentsScreenModel model;

  const CommentsScreen({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title:  const Text("Comments",
          style: TextStyle(
              color: Colors.white
          ),),
      ),
      body: ListView.builder(
        itemCount: model.comments.length,
        itemBuilder: (context, index) {
          final comment = model.comments[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  comment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  comment.body,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
