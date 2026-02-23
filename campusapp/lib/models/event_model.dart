class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String venue;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.venue,
  });
}