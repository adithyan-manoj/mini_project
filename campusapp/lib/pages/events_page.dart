import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/event_model.dart';
import 'package:campusapp/services/api_service.dart';
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
  String searchQuery = "";
  String selectedDateFilter = "All";

  final List<DateTime> dates = List.generate(
    10,
    (index) => DateTime.now().add(Duration(days: index)),
  );
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
              onChanged: (val) => setState(() => searchQuery = val),

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
              itemCount: dates.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" Tile Logic
                  return GestureDetector(
                    onTap: () => setState(() => selectedDateFilter = "All"),
                    child: _buildDateTile(
                      "ALL",
                      "",
                      selectedDateFilter == "All",
                    ),
                  );
                }
                final date = dates[index - 1];
                final String formattedDate = DateFormat(
                  'yyyy-MM-dd',
                ).format(date);
                final bool isSelected = selectedDateFilter == formattedDate;
                // final formattedDate =
                //     DateFormat('yMd').format(date) ==
                //     DateFormat('yMd').format(selectedDate);
                //final bool datecheck = true;
                // final formattedDate;
                // if(DateFormat('yMd').format(date) ==
                //     DateFormat('yMd').format(selectedDate)) {
                //   formattedDate = DateFormat('yMd').format(date);
                // }

                return GestureDetector(
                  onTap: () =>
                      setState(() => selectedDateFilter = formattedDate),
                  child: _buildDateTile(
                    DateFormat('MMM').format(date).toUpperCase(),
                    date.day.toString(),
                    // selectedDateFilter == formattedDate,
                    isSelected,
                  ),
                );
              },
            ),
          ),

          // Expanded(
          //   child: ListView.builder(
          //     padding: const EdgeInsets.only(top: 10),
          //     itemCount: 9, // Dummy count
          //     itemBuilder: (context, index) {
          //       return EventCard(
          //         event: EventModel(
          //           id: "evt_$index",
          //           title: "CodereCET Hcakathon",
          //           description: "A decentralized platform leveraging blockchain to track carbon credits in real-time dkjadj ajsdkashd kajsdkad ahdauh",
          //           imageUrl: "https://via.placeholder.com/150",
          //           date: DateTime.now(),
          //           venue: "CET Trivandrum",
          //         ),
          //       );
          //     },
          //   ),
          // ),
          Expanded(
            child: FutureBuilder<List<EventModel>>(
              // Every time setState is called above, this future triggers again
              future: ApiService.fetchEvents(
                search: searchQuery,
                date: selectedDateFilter, // Formats for Backend
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error fetching events",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No events found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // Success! Render the matching event cards
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return EventCard(event: snapshot.data![i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String topText, String bottomText, bool isSelected) {
    return Container(
      width: 65,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[800] : AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.white24 : AppColors.accentBorder,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topText,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (bottomText.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(color: AppColors.accentBorder, height: 10),
            ),
            Text(
              bottomText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
