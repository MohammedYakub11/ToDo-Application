import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/main.dart';
class EditTodoPage extends StatefulWidget {
  final Model todo;

  const EditTodoPage({Key? key, required this.todo}) : super(key: key);

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    descController = TextEditingController(text: widget.todo.description);

  }

  Future<void> updateData() async {
    final String baseUri = "http://172.16.1.126:3000/todos/${widget.todo.id}";

    try {
      final response = await http.patch(
        Uri.parse(baseUri),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({'description': descController.text}),
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., navigate back
        Navigator.pop(context, true); // Optionally pass true to indicate success
      } else {
        // Handle other status codes
        print('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      print('Error updating todo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Todo"),
        backgroundColor: Color(0xffFF671F),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: descController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: updateData,
            child: Text("Submit"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff046A38)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
  }
}
