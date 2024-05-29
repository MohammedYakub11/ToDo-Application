import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo/Pages/addPage.dart';
import 'package:todo/Pages/editPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Model> data = [];
  final String baseUri = "http://172.16.1.126:3000/todos";

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      List<Model> newData = await getModelData();
      setState(() {
        data = newData;
      });
    } catch (e) {
      // Handle error appropriately
      print('Error fetching data: $e');
    }
  }

  Future<List<Model>> getModelData() async {
    List<Model> newData = [];
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
          return Model.fromJson(json);
        }).toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
    return newData;
  }

  Future<void> deleteTodo(int id) async {
    final uri = Uri.parse('$baseUri/$id');
    try {
      final response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          data.removeWhere((todo) => todo.id == id);
        });
      }
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  Future<void> updateTodoStatus(int id, bool? isCompleted) async {
    final String baseUri = "http://172.16.1.126:3000/todos";

    final uri = Uri.parse('$baseUri/$id');
    try {
      final response = await http.patch(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({'isCompleted': isCompleted}),
      );
      if (response.statusCode == 200) {
        setState(() {
          var todo = data.firstWhere((item) => item.id == id);
          todo.isCompleted = isCompleted ?? false;
        });
      }
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> updateTodoItem(int id) async {
    print('Update Todo: $id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
        backgroundColor: Color(0xffFF671F),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color(0xff046A38),
        onPressed: () {
          final route = MaterialPageRoute(builder: (context) => AddTodoPage());
          Navigator.push(context, route).then(
            (_) => getData(), // Refresh the list after adding a new todo
          );
        },
        label: const Text("Add Todo"),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          var item = data[index];
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: Checkbox(
                value: item.isCompleted,
                onChanged: (bool? value) {
                  updateTodoStatus(item.id, value);
                },
                checkColor: Color(0xff06038D),
                activeColor: Colors.white,
                focusColor: Colors.white,
              ),
              title: Text(
                item.description,
                style: TextStyle(
                  color: Color(0xff06038D),
                  decoration:
                  item.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              //
              trailing: SizedBox(
                width: 96,
                child: Row(
                  children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Color(0xff06038D),
                  onPressed: () {
                    final route = MaterialPageRoute(builder: (context) => EditTodoPage(todo: item));
                    Navigator.push(context, route).then(
                          (_) => getData(), // Refresh the list after adding a new todo
                    );
                  },
                ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Color(0xff06038D),
                      onPressed: () {
                        deleteTodo(item.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Model {
  final int id;
  final String description;
  bool isCompleted;

  Model({
    required this.description,
    required this.id,
    this.isCompleted = false,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

