import 'package:flutter/material.dart';
import 'package:noteapp_hive/model/notes_model.dart';

class Favorite extends StatelessWidget {
  final List<NotesModel> noteList;
  final List<int> favoriteNoteIds;

  const Favorite({
    super.key,
    required this.noteList,
    required this.favoriteNoteIds,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteNotes = noteList.where((note) => favoriteNoteIds.contains(note.key)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Notes'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Color(0xFF00C6FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: SweepGradient(
            colors: [
              Color(0xFF3F3483),
              Colors.white,
              Color(0xFF254BC0),
            ],
          ),
        ),
        child: favoriteNotes.isEmpty
            ? const Center(
          child: Text(
            'No Favorite Notes',
            style: TextStyle(fontSize: 20),
          ),
        )
            : ListView.builder(
          itemCount: favoriteNotes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                favoriteNotes[index].title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                favoriteNotes[index].description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.red,
                onPressed: () {
                  // Logic to remove from favorite
                  Navigator.pop(context, favoriteNotes[index].key);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
