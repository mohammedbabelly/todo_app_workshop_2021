import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_workshop_2021/models/database_helper.dart';
import 'package:todo_app_workshop_2021/models/note.dart';
import 'package:todo_app_workshop_2021/pages/note_detail.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  DatabaseHelper _databaseHelper;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
    _databaseHelper.initializeDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _goToNextPage(),
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  //WIDGETS
  Widget _buildAppBar() => AppBar(
        title: Text('Things Todo today'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      );

  Widget _buildBody() {
    return FutureBuilder(
        future: _getNotesFromDb(),
        builder: (BuildContext context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? Center(
                      child: Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : snapshot.data.isNotEmpty
                      ? RefreshIndicator(
                          key: refreshKey,
                          onRefresh: onRefs,
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildNoteCard(snapshot.data[index]);
                            },
                          ),
                        )
                      : Center(
                          child: Text(
                            'Tap + to add a new note',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
        });
  }

  Widget _buildNoteCard(Note note) => Card(
        color: Colors.white,
        elevation: 2.0,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: getPriorityColor(note.priority),
            child: getPriorityIcon(note.priority),
          ),
          title: Text(
            note.title,
          ),
          subtitle: Text(note.date),
          trailing: InkWell(
              child: Icon(Icons.delete, color: Colors.red),
              onTap: () async => await _deleteNote(context, note.id)),
          onTap: () async => _goToNextPage(note),
        ),
      );

  void _showSnackBar(BuildContext context, String theMessage) {
    final snackBar = SnackBar(
      content: Text(theMessage),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Color getPriorityColor(int pro) {
    //1 means urgent
    //2 means not important
    switch (pro) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.greenAccent;
        break;
      default:
        return Colors.red;
    }
  }

  Icon getPriorityIcon(int pro) {
    //1 means urgent
    //2 means not important
    switch (pro) {
      case 1:
        return Icon(
          Icons.directions_run,
          color: Colors.white,
        );
        break;
      case 2:
        return Icon(
          Icons.directions_walk,
          color: Colors.white,
        );
        break;
      default:
        return Icon(
          Icons.directions_run,
          color: Colors.white,
        );
        break;
    }
  }

  Future<List<Note>> _getNotesFromDb() async =>
      await _databaseHelper.getAllNotes();

  Future<void> _deleteNote(BuildContext context, int id) async {
    int result = await _databaseHelper.deleteNote(id);
    if (result != 0)
      setState(() {
        _showSnackBar(context, "Note deleted successfuly");
      });
    else
      _showSnackBar(context, "Could't delete!");
  }

  Future<void> _goToNextPage([Note note]) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => note == null
                ? NoteDetail(Note('', '', 2), 'Add a new note')
                : NoteDetail(note, 'Edit your note')));
    if (result != null && result)
      setState(() {});
    else
      _showSnackBar(context, "Something went wrong!");
  }

  Future<Null> onRefs() async => setState(() {});
}
