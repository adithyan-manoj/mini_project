import 'package:flutter/material.dart';


// for study purpose!!!
class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List list = [
      ["AAA", "Student"],
      ["BBB", "Student"],
      ["CCC", "student"],
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Study page')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),

        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.label_important_outline),
              title: Text(list[index][1]),
              subtitle: Text(list[index][0]),
              trailing: Text('data'),
            );
          },
        ),
      ),
    );
  }
}
