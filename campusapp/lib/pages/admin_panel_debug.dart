import 'package:flutter/material.dart';
import 'package:campusapp/services/api_service.dart';


class AdminPanelDebug extends StatefulWidget {
  const AdminPanelDebug({super.key});

  @override
  State<AdminPanelDebug> createState() => _AdminPanelDebugState();
}

class _AdminPanelDebugState extends State<AdminPanelDebug> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Login Logs")),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchLogs(), // Call the backend
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Your loading circle!
          }
          
          final logs = snapshot.data ?? [];
          
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: Icon(Icons.history),
                title: Text("Student: ${log['student_id']}"),
                subtitle: Text("Time: ${log['login_time']}"),
                trailing: Text(log['status'], style: TextStyle(color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}