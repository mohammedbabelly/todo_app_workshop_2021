import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app_workshop_2021/models/database_helper.dart';
import 'package:todo_app_workshop_2021/models/note.dart';

const _priorities = ['High Priority', 'Low Priority'];

class NoteDetail extends StatefulWidget {
  final String appParTitle;
  final Note note;
  final DatabaseHelper databaseHelper;
  NoteDetail(this.note, this.appParTitle, this.databaseHelper);
  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  Note curNote;
  TextEditingController titleController;
  TextEditingController desController;
  @override
  void initState() {
    super.initState();
    curNote = widget.note;
    titleController = TextEditingController(text: curNote.title);
    desController = TextEditingController(text: curNote.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  //WIDGETS
  Widget _buildAppBar() => AppBar(
        title: Text(widget.appParTitle),
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async => await _saveNote(),
        ),
        actions: [
          DropdownButton(
              items: _priorities
                  .map((String dropDownStringItem) => DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      ))
                  .toList(),
              value: getPriorityAsString(curNote.priority),
              onChanged: (valueSelectedByUser) {
                setState(() {
                  curNote.priority = getPriorityAsInt(valueSelectedByUser);
                });
              }),
        ],
      );

  Widget _buildBody() => Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                controller: titleController,
                decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                controller: desController,
                decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            )
          ],
        ),
      );

  int getPriorityAsInt(String value) {
    switch (value) {
      case 'High Priority':
        return 1;
        break;
      case 'Low Priority':
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
        return 'High Priority';
        break;
      case 2:
        return 'Low Priority';
        break;
      default:
        return 'High Priority';
        break;
    }
  }

  Future<void> _saveNote() async {
    curNote.title = titleController.text;
    curNote.description = desController.text;
    if ((curNote.title.isEmpty && curNote.description.isEmpty)) {
      Navigator.pop(context);
      return;
    }
    curNote.date = DateFormat.yMMMd().format(DateTime.now());

    int result = curNote.id != null
        ? await widget.databaseHelper.updateNote(curNote)
        : await widget.databaseHelper.insertNote(curNote);

    if (result >= 0) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
      showAlertDialog('Status', 'Error saving note!');
    }
  }

  showAlertDialog(String titile, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(titile),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
