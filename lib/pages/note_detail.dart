import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_workshop_2021/models/database_helper.dart';
import 'package:todo_app_workshop_2021/models/note.dart';

class NoteDetail extends StatefulWidget {
  final String appParTitle;
  final Note curNote;
  NoteDetail(this.curNote, this.appParTitle);
  @override
  _NoteDetailState createState() => _NoteDetailState(this.curNote, appParTitle);
}

class _NoteDetailState extends State<NoteDetail> {
  Note curNote = new Note('', '', 1);
  String appParTitle;
  static var _priorities = ['Urgent', 'K'];
  _NoteDetailState(this.curNote, this.appParTitle);

  TextEditingController titleCon = new TextEditingController();
  TextEditingController desCon = new TextEditingController();

  DatabaseHelper helper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    titleCon.text = curNote.title;
    desCon.text = curNote.description;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('$appParTitle'),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                print('delete the note');
                deleteNote();
              }),
          new IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              print('save the note');
              saveNote();
            },
          )
        ],
      ),

      // body: new CustomScrollView(
      //   slivers: <Widget>[
      //     new SliverAppBar(
      //       actions: <Widget>[new Icon(Icons.add)],
      //     )
      //   ],
      // ),
      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: new ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: new Text(
                'How important is it?',
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                    wordSpacing: 1.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(curNote.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      curNote.priority = getPriorityAsInt(valueSelectedByUser);
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                style: textStyle,
                controller: titleCon,
                onChanged: (the_title) {
                  print('the title: $the_title');
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelStyle: textStyle,
                    labelText: 'Title it',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                style: textStyle,
                controller: desCon,
                onChanged: (the_description) {
                  print('the title: $the_description');
                  updateDes();
                },
                decoration: InputDecoration(
                    labelStyle: textStyle,
                    labelText: 'Descripe it',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            )
          ],
        ),
      ),
    );
  }

  int getPriorityAsInt(String value) {
    switch (value) {
      case 'Urgent':
        return 1;
        break;
      case 'K':
        return 2;
        break;
      default:
        return 1;
        break;
    }
  }

  String getPriorityAsString(int value) {
    switch (value) {
      case 1:
        return 'Urgent';
        break;
      case 2:
        return 'K';
        break;
      default:
        return 'Urgent';
        break;
    }
  }

  void updateTitle() => curNote.title = titleCon.text;
  void updateDes() => curNote.description = desCon.text;

  void saveNote() async {
    Navigator.pop(context, true);
    curNote.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (curNote.id != null) {
      //that's a new note we will insert
      result = await helper.updateNote(curNote);
    } else {
      //that's an update
      //Note n=new Note('titile',1,'myDate','des');
      result = await helper.insertNote(curNote);
    }

    print(curNote.id);
    if (result == 1) {
      showAlertDialog('Status', 'Note saved succussfuly');
    } else if (result == 0) {
      showAlertDialog('Status', 'Problem saving Note');
    }
  }

  void deleteNote() async {
    int result;
    if (curNote.id == null) {
      //that's a new note we will insert
      showAlertDialog('Status', 'WTH');
    } else {
      //that's an update
      result = await helper.deleteNote(curNote.id);
    }

    if (result == 1) {
      showAlertDialog('Status', 'Note deleted succussfuly');
      Navigator.pop(context, true);
      print('$result');
    } else {
      showAlertDialog('Status', 'Problem deleting Note');
      print('not done');
    }
    Navigator.pop(context, true);
  }

  showAlertDialog(String titile, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(titile),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  void _showSnackBar(BuildContext context, String theMessage) {
    final snackBar = SnackBar(
      content: Text(theMessage),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    // Scaffold.of(context).showBottomSheet(builder);
  }
}
