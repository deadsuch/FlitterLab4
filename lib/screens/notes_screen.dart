import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  // Список для хранения заметок. Каждая заметка будет хранить oglavlenie и temat
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();  // Загружаем заметки при старте экрана
  }

  // Метод для загрузки заметок из SharedPreferences
  _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesData = prefs.getString('notes');
    if (notesData != null) {
      setState(() {
        notes = List<Map<String, String>>.from(
            json.decode(notesData).map((note) => Map<String, String>.from(note))
        );
      });
    }
  }

  // Метод для сохранения заметок в SharedPreferences
  _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', json.encode(notes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title']!),
            subtitle: Text(note['content']!),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  notes.removeAt(index);
                  _saveNotes();  // Сохраняем изменения
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addNoteDialog() {
    String title = '';
    String content = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Оглавление
              TextFormField(
                decoration: InputDecoration(labelText: 'Note Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              SizedBox(height: 10),
              // Тема заметки
              TextFormField(
                decoration: InputDecoration(labelText: 'Note Content'),
                onChanged: (value) {
                  content = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                if (title.isNotEmpty && content.isNotEmpty) {
                  setState(() {
                    // Добавляем новую заметку с заголовком и содержимым
                    notes.add({'title': title, 'content': content});
                    _saveNotes();  // Сохраняем заметки
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
