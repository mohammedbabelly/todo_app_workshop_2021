import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app_workshop_2021/models/database_helper.dart';
import 'package:todo_app_workshop_2021/models/note.dart';
import 'package:todo_app_workshop_2021/pages/note_detail.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  DatabaseHelper _databaseHelper;
  List<Note> noteList;
  int cnt = 0;

  @override
  void initState() {
    super.initState();
    _databaseHelper = new DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (NotesPage == null) {
      noteList = [];
    } else
      updateListView();
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('stuff TODO today'),
        backgroundColor: Colors.redAccent,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NoteDetail(Note('', '', 2), "add a new note")));
          if (result == true && result != null) updateListView();
        },
        backgroundColor: Colors.redAccent,
        child: new Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    // print('cnt= $cnt');
    if (cnt == 0)
      return ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int pos) {
          var height =
              MediaQuery.of(context).size.height; //get the screen height
          return new Center(
              child: Padding(
            padding: new EdgeInsets.only(
                top: height / 2), //padding the half of the screen
            child: Text(
              'Tap + to add a new note',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ));
        },
      );
    else
      return ListView.builder(
        itemCount: cnt,
        itemBuilder: (BuildContext context, int pos) {
          return new Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[pos].priority),
                child: getPriorityIcon(this.noteList[pos].priority),
              ),
              title: Text(
                this.noteList[pos].title,
                style: titleStyle,
              ),
              subtitle: Text(this.noteList[pos].date),
              trailing: InkWell(
                  child: Icon(Icons.delete, color: Colors.red),
                  onTap: () {
                    deleteNote(context, noteList[pos].id);
                  }),
              onTap: () async {
                //tap to edit the note
                var result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NoteDetail(this.noteList[pos], 'edit your note')));
                if (result == true && result != null) updateListView();
              },
            ),
          );
        },
      );
  }

  deleteNote(BuildContext context, int id) async {
    int result = await _databaseHelper.deleteNote(id);
    if (result != 0) {
      //deleted
      _showSnackBar(context, "Note deleted successfuly");
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String theMessage) {
    final snackBar = SnackBar(
      content: Text(theMessage),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    // Scaffold.of(context).showBottomSheet(builder);
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

  void updateListView() {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = _databaseHelper.getNoteList();
      noteListFuture.then((noteList1) {
        setState(() {
          this.noteList = noteList1;
          this.cnt = noteList1.length;
        });
      });
    });
  }
}
