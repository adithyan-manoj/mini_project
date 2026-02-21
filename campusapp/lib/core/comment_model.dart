class CommentModel {
  final String id;          // Unique ID from Database
  final String? parentId;
  final String userName;
  final String text;
  final String profilePic;
  final List<CommentModel> subComments; // The "Stack" logic

  CommentModel({
    required this.id,
    this.parentId,
    required this.userName,
    required this.text,
    this.profilePic = "",
    this.subComments = const [],
  });

  CommentModel copyWith({List<CommentModel>? subComments}) {
    return CommentModel(
      id: id,
      parentId: parentId,
      userName: userName,
      text: text,
      profilePic: profilePic,
      subComments: subComments ?? this.subComments,
    );
  }
}

