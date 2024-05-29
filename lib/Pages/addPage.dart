import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/main.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  late List<Model> data = [];

  Future<void> getData() async {
    try {
      List<Model> newData = await getModelData();
      setState(() {
        data = newData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<List<Model>> getModelData() async {
    List<Model> newData = [];
    final String baseUri = "http://172.16.1.126:3000/todos";

    final uri = Uri.parse(baseUri);
    try {
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        newData = jsonData.map((json) {
          final int id = jsonData.indexOf(json);
          return Model.fromJson({...json, 'id': id});
        }).toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
    return newData;
  }

  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Todo"),
        backgroundColor: Color(0xffFF671F),
foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                hintText: 'Description',
              ),
              maxLines: 3,
            ),
          ),
          ElevatedButton(
            onPressed: addData,
            child: Text("Add"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff046A38)),            ),
          )
        ],
      ),
    );
  }



  Future<void> addData() async {
    final desc = descController.text;

    // Get the current length of the data list
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final body = {"id": id, "description": desc};

    final url = "http://172.16.1.126:3000/todos";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        descController.text = '';
      });
    }
  }
}
