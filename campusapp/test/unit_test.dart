import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/models/post_model.dart';
import 'package:campusapp/models/backup_lost_found_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel Unit Tests', () {
    test('Should parse EventModel from valid JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Event',
        'description': 'Test Description',
        'image_url': 'https://example.com/image.png',
        'event_date': '2023-10-27T10:00:00Z',
        'venue': 'Test Venue',
      };
      final event = EventModel.fromJson(json);
      expect(event.id, '1');
      expect(event.title, 'Test Event');
      expect(event.event_date.year, 2023);
    });

    test('Should handle null fields in EventModel JSON', () {
      final json = {
        'id': 'evt_99',
      };
      final event = EventModel.fromJson(json);
      expect(event.title, '');
      expect(event.venue, '');
      expect(event.event_date, isA<DateTime>());
    });
  });

  group('PostModel Unit Tests', () {
    test('Should parse PostModel from valid JSON', () {
      final json = {
        'id': 'post_1',
        'userName': 'John Doe',
        'postedTime': '2023-10-27T12:00:00Z',
        'title': 'Hello Campus',
        'content': 'This is a test post.',
        'tags': ['test', 'campus'],
        'likes': 10,
        'commentCount': 5,
        'isLikedByMe': true,
      };
      final post = PostModel.fromJson(json);
      expect(post.userName, 'John Doe');
      expect(post.tags.length, 2);
      expect(post.isLikedByMe, true);
    });
  });

  group('BackupLostFoundItem Unit Tests', () {
    test('Should parse BackupLostFoundItem from valid JSON', () {
      final json = {
        'id': 'item_123',
        'item_name': 'Blue Umbrella',
        'type': 'lost',
        'location': 'Main Canteen',
        'phone_number': '1234567890',
        'status': 'open',
        'created_at': '2023-10-27T08:00:00Z',
        'user_id': 'user_456',
        'users': {'full_name': 'Tester'},
      };
      final item = BackupLostFoundItem.fromJson(json);
      expect(item.itemName, 'Blue Umbrella');
      expect(item.reporterName, 'Tester');
      expect(item.type, 'lost');
    });
  });
}
