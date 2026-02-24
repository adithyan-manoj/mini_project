import 'dart:async';

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
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  List<EventModel> _allEvents = [];

  Map<String, List<EventModel>> _paginationCache = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchNextPage();
  }

  void _scrollListener() {
    // Logic: If user is 200 pixels from the bottom, fetch more!
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _fetchNextPage();
      }
    }
  }

  void _updateFilters(String newDate, String newSearch) {
    setState(() {
      selectedDateFilter = newDate;
      searchQuery = newSearch;
      _currentPage = 1;
      _allEvents.clear();
    });
    _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_isLoadingMore) return;

    // Create a unique key for this specific request
    String cacheKey = "$selectedDateFilter-$searchQuery-$_currentPage";

    // CHECK CACHE FIRST
    if (_paginationCache.containsKey(cacheKey)) {
      setState(() {
        _allEvents.addAll(_paginationCache[cacheKey]!);
        _currentPage++;
      });
      return; // Stop here, no network call needed!
    }

    setState(() => _isLoadingMore = true);

    try {
      final newEvents = await ApiService.fetchEvents(
        search: searchQuery,
        date: selectedDateFilter,
        page: _currentPage,
        limit: 5,
      );

      setState(() {
        if (newEvents.isNotEmpty) {
          // Save to cache for next time
          _paginationCache[cacheKey] = newEvents;

          for (var event in newEvents) {
            if (!_allEvents.any((e) => e.id == event.id)) {
              _allEvents.add(event);
            }
          }
          _currentPage++;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Map<String, List<EventModel>> _eventCache = {}; // for caching

  Future<List<EventModel>> getCachedEvents() async {
    String cacheKey = "$selectedDateFilter-$searchQuery";

    // If we already have this exact search/date combo, return it immediately!
    if (_eventCache.containsKey(cacheKey)) {
      return _eventCache[cacheKey]!;
    }

    // Otherwise, fetch from network
    List<EventModel> results = await ApiService.fetchEvents(
      search: searchQuery,
      date: selectedDateFilter,
    );

    // Save it to the cache for next time
    _eventCache[cacheKey] = results;
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Kill the timer if the user leaves the page
    super.dispose();
  }

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
              controller: _searchController,
              onChanged: (val) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                // _debounce = Timer(const Duration(milliseconds: 500), () {
                //   setState(() => searchQuery = val);
                // });
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  // This handles the trim and the server request
                  _updateFilters(selectedDateFilter, val.trim());
                });
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Events",
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            searchQuery = "";
                            _eventCache.clear();
                          });
                        },
                      )
                    : null,
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
                  return GestureDetector(
                    onTap: () => _updateFilters("All", searchQuery),
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
                  // CHANGE: Use _updateFilters so it clears the list and resets to Page 1
                  onTap: () => _updateFilters(formattedDate, searchQuery),
                  child: _buildDateTile(
                    DateFormat('MMM').format(date).toUpperCase(),
                    date.day.toString(),
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
          // Expanded(
          //   child: FutureBuilder<List<EventModel>>(
          //     // Every time setState is called above, this future triggers again
          //     // future: ApiService.fetchEvents(
          //     //   search: searchQuery,
          //     //   date: selectedDateFilter, // Formats for Backend
          //     // ),
          //     future: getCachedEvents(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(child: CircularProgressIndicator());
          //       } else if (snapshot.hasError) {
          //         return const Center(
          //           child: Text(
          //             "Error fetching events",
          //             style: TextStyle(color: Colors.white),
          //           ),
          //         );
          //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //         return Center(
          //           child: Column(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               const Icon(
          //                 Icons.event_busy,
          //                 size: 64,
          //                 color: Colors.white24,
          //               ),
          //               const SizedBox(height: 16),
          //               const Text(
          //                 "No events found",
          //                 style: TextStyle(color: Colors.white54),
          //               ),
          //               TextButton(
          //                 onPressed: () {
          //                   setState(() {
          //                     searchQuery = "";
          //                     _searchController.clear();
          //                     selectedDateFilter = "All";
          //                     _eventCache.clear();
          //                   });
          //                 },
          //                 child: const Text(
          //                   "Clear all filters",
          //                   style: TextStyle(color: Colors.blue),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         );
          //       }

          //       // Success! Render the matching event cards
          //       return RefreshIndicator(
          //         onRefresh: () async {
          //           setState(() {
          //             _eventCache.clear();
          //           });

          //           await getCachedEvents();
          //         },
          //         child: ListView.builder(
          //           controller: _scrollController,
          //           physics: const AlwaysScrollableScrollPhysics(),
          //           padding: const EdgeInsets.only(top: 10),
          //           itemCount: _allEvents.length + (_isLoadingMore ? 1 : 0),
          //           itemBuilder: (context, i) {
          //             if (i == _allEvents.length) {
          //               return const Center(
          //                 child: CircularProgressIndicator(),
          //               ); // Loading more indicator
          //             }
          //             return EventCard(event: _allEvents[i]);
          //           },
          //         ),
          //       );
          //     },
          //   ),
          // ),
          Expanded(
            child: _allEvents.isEmpty && _isLoadingMore
                ? ListView.builder(
                    itemCount: 5, // Show 5 ghost cards while loading
                    itemBuilder: (context, index) => _buildShimmerCard(),
                  ) // First-time load
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _paginationCache.clear(); // Wipe the cache
                      });
                      _updateFilters(selectedDateFilter, searchQuery);
                    },
                    child: _allEvents.isEmpty
                        ? _buildEmptyState() // Now defined below
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 10),
                            // Added 1 to itemCount to show the bottom loader
                            itemCount:
                                _allEvents.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i == _allEvents.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return EventCard(event: _allEvents[i]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      // Allows Pull-to-refresh even when empty
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              const Text(
                "No events found",
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _updateFilters("All", "");
                },
                child: const Text(
                  "Clear all filters",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      height: 120, // Match your EventCard height
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Ghost Image
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Ghost Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.white.withOpacity(0.05),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 14,
                  color: Colors.white.withOpacity(0.05),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
