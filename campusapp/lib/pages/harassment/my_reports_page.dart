import 'package:flutter/material.dart';
import 'package:campusapp/models/harassment_report.dart';
import 'package:campusapp/services/harassment_service.dart';
import 'package:campusapp/pages/harassment/report_detail_page.dart';
import 'package:campusapp/pages/harassment/report_form_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  late Future<List<HarassmentReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    setState(() {
      _reportsFuture = HarassmentService.fetchReports();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Reports', style: GoogleFonts.oswald(textStyle: TextStyle(fontSize: 28)),),
        centerTitle: true,
      ),
      body: FutureBuilder<List<HarassmentReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reports.'));
          }
          
          final reports = snapshot.data ?? [];
          
          if (reports.isEmpty) {
            return const Center(
               child: Text(
                 'No active reports!', 
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 16, color: Colors.grey),
               )
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    report.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.description, 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${_formatDate(report.createdAt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () async {
                    final shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailPage(report: report),
                      ),
                    );
                    if (shouldRefresh == true) {
                      _loadReports();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportFormPage()),
          );
          if (shouldRefresh == true) {
            _loadReports();
          }
        },
        heroTag: "harasment_page_tag",
        icon: const Icon(Icons.add,color: Colors.black,),
        label: const Text('New Report', style: TextStyle(
          color: Colors.black
        ),),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
