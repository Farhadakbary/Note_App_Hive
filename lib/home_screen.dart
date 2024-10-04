import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'boxes/boxes.dart';
import 'favorite.dart';
import 'loginpage.dart';
import 'model/notes_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();

  List<NotesModel> filteredNotes = [];
  List<NotesModel> noteList = [];
  List<int> favoriteNoteIds = [];

  @override
  void initState() {
    super.initState();
    filteredNotes = Boxes.getData().values.toList().cast<NotesModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Database'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Color(0xFF00C6FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                Navigator.pushNamed(context, '/settings');
              });
            },
            icon: const Icon(Icons.settings),
            color: Colors.black,
            highlightColor: Colors.white24,
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Favorite(
                                noteList: Boxes.getData()
                                    .values
                                    .toList()
                                    .cast<NotesModel>(),
                                favoriteNoteIds: favoriteNoteIds,
                              )));
                });
              },
              icon: const Icon(Icons.favorite),
              color: Colors.black,
              highlightColor: Colors.white24),
          IconButton(
              onPressed: () {
                setState(() {
                  _deleteall(
                      context,
                      NotesModel(
                          title: '$titleController',
                          description: '$descriptionController'));
                });
              },
              icon: const Icon(Icons.delete_forever),
              color: Colors.black,
              highlightColor: Colors.white24),
          IconButton(
              onPressed: () {
                setState(() {
                  _logout(context);
                });
              },
              icon: const Icon(Icons.logout),
              color: Colors.black,
              highlightColor: Colors.white24),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Icon(Icons.search)),
              onChanged: (value) {
                _filterNotes(value);
              },
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
              Color(0xFF6A5ACD),
              Colors.white,
              Color(0xFF4169E1),
            ],
          ),
        ),
        child: ValueListenableBuilder<Box<NotesModel>>(
          valueListenable: Boxes.getData().listenable(),
          builder: (context, box, _) {
            var data = searchController.text.isEmpty
                ? box.values.toList().cast<NotesModel>()
                : filteredNotes;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                  itemCount: data.length,
                  reverse: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    bool isFavorite = favoriteNoteIds.contains(data[index].key);
                    return ListTile(
                      title: Text(data[index].title.toString()),
                      subtitle: Text(data[index].description.toString()),
                      trailing: IconButton(
                          onPressed: () {
                            _confirmDelete(context, data[index]);
                          },
                          icon: const Icon(Icons.delete_forever),
                          highlightColor: Colors.black87,
                          color: Colors.black),
                      leading: IconButton(
                        onPressed: () {
                          setState(() {
                            if (isFavorite) {
                              favoriteNoteIds.remove(data[index].key);
                            } else {
                              favoriteNoteIds.add(data[index].key);
                            }
                          });
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        highlightColor: Colors.black87,
                      ),
                      onTap: () {
                        setState(() {
                          _editDialog(
                            data[index],
                            data[index].title.toString(),
                            data[index].description.toString(),
                          );
                        });
                      },
                      tileColor: Colors.white10,
                      horizontalTitleGap: 7,
                    );
                  }),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          shape: const StadiumBorder(
              side: BorderSide(
            width: 1,
          )),
          elevation: 40,
          onPressed: () async {
            _showMyDialog();
          },
          child: const Icon(Icons.add)),
    );
  }

  void _confirmDelete(BuildContext context, NotesModel notesModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple.shade100,
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                delete(notesModel);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Yes',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }

  Future<void> _editDialog(
      NotesModel notesModel, String title, String description) async {
    titleController.text = title;
    descriptionController.text = description;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit NOTES'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        hintText: 'Enter title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        hintText: 'Enter description',
                        border: OutlineInputBorder()),
                    maxLines: null,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    notesModel.title = titleController.text.toString();
                    notesModel.description =
                        descriptionController.text.toString();

                    notesModel.save();
                    descriptionController.clear();
                    titleController.clear();

                    Navigator.pop(context);
                  },
                  child: const Text('Edit')),
            ],
          );
        });
  }

  Future<void> _showMyDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add NOTES'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      hintText: 'Enter title', border: OutlineInputBorder()),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      hintText: 'Enter description',
                      border: OutlineInputBorder()),
                  maxLines: null,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Title and Description cannot be empty!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  final data = NotesModel(
                    title: titleController.text,
                    description: descriptionController.text,
                  );

                  final box = Boxes.getData();
                  box.add(data);

                  titleController.clear();
                  descriptionController.clear();

                  Navigator.pop(context);
                },
                child: const Text('Add')),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _deleteAll(BuildContext context) async {
    var box = Boxes.getData();
    if (box.isNotEmpty) {
      await box.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'All notes deleted',
          style: TextStyle(color: Colors.white),
        ),
      ));
      updateListView();
    }
  }

  void updateListView() {
    var box = Hive.box<NotesModel>('notesBox');
    setState(() {
      filteredNotes = box.values.toList().cast<NotesModel>();
    });
  }

  void _deleteall(BuildContext context, NotesModel notesModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          elevation: 10,
          backgroundColor: Colors.deepPurple.shade100,
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteAll(context);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.green, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filterNotes(String query) {
    var allNotes = Boxes.getData().values.toList().cast<NotesModel>();
    setState(() {
      filteredNotes = allNotes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
