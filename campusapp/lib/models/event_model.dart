class EventModel {
  final String id;
  final String title;
  final String description;
  final String image_url;
  final DateTime event_date;
  final String venue;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image_url,
    required this.event_date,
    required this.venue,
  });
}