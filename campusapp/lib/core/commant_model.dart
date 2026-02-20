class CommentModel {
  final String userName;
  final String text;
  final String profilePic;
  final List<CommentModel> subComments; // The "Stack" logic

  CommentModel({
    required this.userName,
    required this.text,
    this.profilePic = "",
    this.subComments = const [],
  });
}