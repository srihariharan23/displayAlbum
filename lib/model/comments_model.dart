// comments_model.dart

class CommentsScreenModel {
  final String title;
  final List<Comment> comments;

  CommentsScreenModel({
    required this.title,
    required this.comments,
  });
}

class Comment {
  final String name;
  final String body;

  Comment({
    required this.name,
    required this.body,
  });
}
