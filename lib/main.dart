// Import MaterialApp and other widgets which we can use to quickly create a material app
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Code written in Dart starts exectuting from the main function. runApp is part of
// Flutter, and requires the component which will be our app's container. In Flutter,
// every component is known as a "widget".
void main() => runApp(new TodoApp());

// Every component in Flutter is a widget, even the whole app itself
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Todo List', home: new TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _listString = [];

  // เดี๋ยวค่อยไปลบตัวแปรใน SharedPref ทิ้งละกันนะ ตอนนี้เท่ากับ 4 อยู่
  //int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadListString();
    // ทำมาเพื่อ Clear ข้อมูลใน ArrayList ทิ้ง
    //_removeListString();
  }

  _removeListString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('todolist');
    print('Remove todolist done');
  }

  //Loading todolist value on start
  _loadListString() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _listString = (prefs.getStringList('todolist') ?? ['']);
    });
    print(_listString);
  }

  //Incrementing todolist value after click
//  _addListString() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    _listString = (prefs.getStringList('todolist') ?? []);
//    _listString.add('Test1234');
//    setState(() {
//      _listString;
//    });
//    prefs.setStringList('todolist', _listString);
//  }

  _addTodoItem(String task) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Only add the task if the user actually entered something
    if (task.length > 0) {
      // Putting our code inside "setState" tells the app that our state has changed, and
      // it will automatically re-render the list
      _listString = (prefs.getStringList('todolist') ?? []);
      _listString.add(task);
      setState(() {
        _listString;
      });
      prefs.setStringList('todolist', _listString);
    }
  }

  _removeTodoItem(int index) async {
    // ใช่การ remove เป็นการลบ Array ที่ตำแหน่งที่ State มีอยู่ แต่อย่าลืมว่า ข้อมูลใน SharedPreferences ยังไม่หายเพราะฉะนั้นจึงต้องลบข้อมูลในนั้นด้วย
    // และเนื่องจาการเรียกใช้ SharedPreferences เป็น Async จึงต้องแก้ Methode ด้วยเด้อ

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => _listString.removeAt(index));
    prefs.setStringList('todolist', _listString);
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_listString[index]}" as done?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    // The alert is actually part of the navigation stack, so to close it, we
                    // need to pop it.
                    onPressed: () => Navigator.of(context).pop()),
                new FlatButton(
                    child: new Text('MARK AS DONE'),
                    onPressed: () {
                      _removeTodoItem(index);
                      Navigator.of(context).pop();
                    })
              ]);
        });
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of todo items we have. So, we need to check the index is OK.
        if (index < _listString.length) {
          return _buildTodoItem(_listString[index], index);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
        title: new Text(todoText), onTap: () => _promptRemoveTodoItem(index));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Todo List [SharedPreferences]')),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
          onPressed: _pushAddTodoScreen,
          tooltip: 'Add task',
          child: new Icon(Icons.add)),
    );
  }

  void _pushAddTodoScreen() {
    // ทดสอบลองการ Add ข้อมูลตอนแรก !!!
    // _addListString();
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well as adding
        // a back button to close it
        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(title: new Text('Add a new task')),
          body: new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _addTodoItem(val);
              Navigator.pop(context); // Close the add todo screen
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }
}
