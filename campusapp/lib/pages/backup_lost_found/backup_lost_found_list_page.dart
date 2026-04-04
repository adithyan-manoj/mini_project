import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/models/backup_lost_found_item.dart';
import 'package:campusapp/services/backup_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'backup_item_detail_page.dart';
import 'backup_post_item_page.dart';

class BackupLostFoundListPage extends StatefulWidget {
  const BackupLostFoundListPage({super.key});

  @override
  State<BackupLostFoundListPage> createState() =>
      BackupLostFoundListPageState();
}

class BackupLostFoundListPageState extends State<BackupLostFoundListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BackupLostFoundItem> _items = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  
  String _currentSortBy = 'date'; // 'date', 'name'
  String _currentType = 'lost'; // 'all', 'lost', 'found'
  String _currentStatus = 'open'; // 'open', 'closed'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await BackupApiService.getBackupItems(
        type: _currentType,
        status: _currentStatus,
        sortBy: _currentSortBy,
        q: _searchController.text.trim(),
      );
      setState(() {
        _items = rawData.map((e) => BackupLostFoundItem.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  void _onCategoryChanged(int index) {
    if (index == 0) {
      _currentType = 'lost';
      _currentStatus = 'open';
    } else if (index == 1) {
      _currentType = 'found';
      _currentStatus = 'open';
    } else if (index == 2) {
      _currentType = 'all';
      _currentStatus = 'closed';
    }
    loadItems();
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sort By:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          DropdownButton<String>(
            value: _currentSortBy,
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            underline: Container(height: 1, color: Colors.white54),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _currentSortBy = newValue);
                loadItems();
              }
            },
            items: const [
              DropdownMenuItem(value: 'date', child: Text('Date (Newest)')),
              DropdownMenuItem(value: 'name', child: Text('Item Name (A-Z)')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Lost & Found',
          style: GoogleFonts.oswald(
            textStyle: TextStyle(fontSize: 28, color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          onTap: _onCategoryChanged,
          tabs: const [
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search items by name...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => loadItems(),
            ),
          ),
          _buildFilterRow(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No items found.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _items.length,
                        itemBuilder: (ctx, i) {
                          return _BackupItemCard(
                            item: _items[i],
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BackupItemDetailPage(
                                    item: _items[i],
                                  ),
                                ),
                              );
                              loadItems(); // refresh after popping
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _BackupItemCard extends StatelessWidget {
  final BackupLostFoundItem item;
  final VoidCallback onTap;

  const _BackupItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == 'lost';
    final isResolved = item.status == 'closed';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 30, 30, 30),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color.fromARGB(255, 110, 110, 110),
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLost ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLost ? 'LOST' : 'FOUND',
                      style: TextStyle(
                        color: isLost ? Colors.red[800] : Colors.green[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (isResolved)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Closed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (item.imageUrl != null)
                Container(
                  height: 140,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                item.itemName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.location,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${item.createdAt.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
