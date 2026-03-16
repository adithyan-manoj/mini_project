class CommentModel {
  final String id;
  final String postId;
  final String? parentId;         // null = top-level comment
  final String? authorId;
  final String userName;
  final String text;
  final String profilePic;
  final DateTime createdAt;
  List<CommentModel> subComments; // mutable so tree can be assembled

  CommentModel({
    required this.id,
    required this.postId,
    this.parentId,
    this.authorId,
    required this.userName,
    required this.text,
    this.profilePic = "",
    DateTime? createdAt,
    List<CommentModel>? subComments,
  })  : createdAt = createdAt ?? DateTime.now(),
        subComments = subComments ?? [];

  CommentModel copyWith({List<CommentModel>? subComments}) {
    return CommentModel(
      id: id,
      postId: postId,
      parentId: parentId,
      authorId: authorId,
      userName: userName,
      text: text,
      profilePic: profilePic,
      createdAt: createdAt,
      subComments: subComments ?? this.subComments,
    );
  }

  /// Build a tree from a flat list using parent_comment_id.
  static List<CommentModel> buildTree(List<CommentModel> flat) {
    final map = <String, CommentModel>{for (var c in flat) c.id: c};
    final roots = <CommentModel>[];
    for (final comment in flat) {
      if (comment.parentId == null) {
        roots.add(comment);
      } else {
        map[comment.parentId]?.subComments.add(comment);
      }
    }
    return roots;
  }
}
