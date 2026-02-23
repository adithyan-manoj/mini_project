import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime selectedDate = DateTime.now();

  final List<DateTime> dates = List.generate(10, (index) => DateTime.now().add(Duration(days: index)));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        ),
        leading: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Events",
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.cardGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accentBorder),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = DateFormat('yMd').format(date) == DateFormat('yMd').format(selectedDate);

                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.grey[800] : AppColors.cardGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('MMM').format(date).toUpperCase(), 
                             style: const TextStyle(color: Colors.white70, fontSize: 18)),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(color: AppColors.accentBorder,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(date.day.toString(), 
                             style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: 9, // Dummy count
              itemBuilder: (context, index) {
                return EventCard(
                  event: EventModel(
                    id: "evt_$index",
                    title: "CodereCET Hcakathon",
                    description: "A decentralized platform leveraging blockchain to track carbon credits in real-time dkjadj ajsdkashd kajsdkad ahdauh",
                    imageUrl: "https://via.placeholder.com/150",
                    date: DateTime.now(),
                    venue: "CET Trivandrum",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
