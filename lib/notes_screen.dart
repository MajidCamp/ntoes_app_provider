import 'package:first_class/provider/NotesProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesScreen extends StatefulWidget {
  NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final leftEditIcon = Container(
      color: Colors.green,
      child: Icon(Icons.edit),
      alignment: Alignment.centerLeft,
    );
    final rightDeleteIcon = Container(
      color: Colors.red,
      child: Icon(Icons.delete),
      alignment: Alignment.centerRight,
    );
    NotesProvider watcher = context.watch<NotesProvider>();
    NotesProvider provider = context.read<NotesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: watcher.notes == null
          ? const Center(
              child: Text(
              "No Notes",
              style: TextStyle(fontSize: 32, color: Colors.black),
            ))
          : ListView.separated(
              itemBuilder: (context, index) => Dismissible(
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Left to right
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateNote(id:watcher.notes?[index]['id'] ,
                          note: watcher.notes?[index]['content'],),
                      ),
                    );
                   return false;
                  } else if (direction == DismissDirection.endToStart) {

                    int id = watcher.notes?[index]['id'];
                    provider.deleteNote(id);
                 return true;
                  }
                },
                    // left side
                    background: leftEditIcon,
                    // right side
                    secondaryBackground: rightDeleteIcon,
                    key: Key(watcher.notes![index]['id'].toString()),

                    child: Container(width: double.infinity,
                      child: Card(
                        shape: const RoundedRectangleBorder(),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          leading: FlutterLogo(size: 56.0),
                          title: Text(watcher.notes?[index]['content'],
                            style: const TextStyle(fontSize: 32,),
                            ),
                          trailing: Icon(Icons.more_vert),
                          subtitle: Text("ID: ${watcher.notes![index]['id'].toString()}"),


                        ),

                      ),
                    ),
                  ),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 16,
                  ),
              itemCount: watcher.notes!.length),
    );
  }
}

class AddNoteScreen extends StatefulWidget {
  AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  var noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    NotesProvider provider = context.read<NotesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a note"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(

                decoration: const InputDecoration(
                  label: Text("Note"),
                  icon: Icon(Icons.note),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                controller: noteController,
                style:  TextStyle(fontSize: 24, ),
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.insertToDatabase(noteController.text);
          Navigator.pop(context);
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}

class UpdateNote extends StatefulWidget {
   UpdateNote({Key? key, required this.id, required this.note}) : super(key: key);

  int id;
  String note;

  @override
  State<UpdateNote> createState() => _UpdateNoteState();
}

class _UpdateNoteState extends State<UpdateNote> {
  @override
  var noteController = TextEditingController();

  _UpdateNoteState();

  @override
  Widget build(BuildContext context) {

    NotesProvider provider = context.read<NotesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update a note"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  label: Text("Note"),
                  icon: Icon(Icons.note),
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                controller: TextEditingController(text: widget.note),
                onChanged: (value) {
                  // Update the note's content
                  widget.note = value;
                },
                style: const TextStyle(fontSize: 24),
                // initialValue: note,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          provider.updateDatabase(widget.id,widget.note);
          Navigator.pop(context);
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
