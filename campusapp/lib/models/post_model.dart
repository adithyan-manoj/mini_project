class PostModel {
  final String id;
  final String userName;
  final String userProfilePic;
  final DateTime postedTime; 
  final String title;
  final String content;
  final List<String> tags;    
  int likes;
  int commentCount;
  bool isLikedByMe;

  PostModel({
    required this.id,
    required this.userName,
    required this.userProfilePic,
    required this.postedTime,
    required this.title,
    required this.content,
    this.tags = const [],
    this.likes = 0,
    this.commentCount = 0,
    this.isLikedByMe = false,
  });
}