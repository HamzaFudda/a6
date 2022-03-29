import 'package:assignment4/editScreen.dart';
import 'package:assignment4/main.dart';
import 'package:assignment4/todo.dart';
import 'package:assignment4/todoList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

//this class helps us to mark our task as done and display correct status according to if conditions
class taskTitle extends StatefulWidget {
  todoTask task;

  taskTitle({Key? key, required this.task}) : super(key: key);

  @override
  _taskTitleState createState() => _taskTitleState();
}

class _taskTitleState extends State<taskTitle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Title"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 200),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 32),
              child: Text(
                widget.task.title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 32),
              child: Text(
                widget.task.description,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 32),
              child: Text(
                "Due date: " +
                    DateFormat('dd-MMM-yyyy').format(widget.task.dateTime),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 10),
            if (widget.task.done && widget.task.dueDatePass) ...[
              Center(
                child: Text(
                  "You marked this task as done on " +
                      DateFormat('dd-MMM-yyyy')
                          .format(widget.task.completion_dateTime) +
                      " after the due date",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )
            ] else if (widget.task.done) ...[
              Center(
                child: Text(
                  "You marked this task as done on " +
                      DateFormat('dd-MMM-yyyy')
                          .format(widget.task.completion_dateTime),
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )
            ] else if (widget.task.dueDatePass) ...[
              Center(
                child: Text(
                  "Due date has been passed",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
            SizedBox(
              height: 150,
            ),
            if (!widget.task.done) ...[
              Center(
                child: RaisedButton(
                  onPressed: () {
                    context.read<todoList>().markAsDone1(task: widget.task, temp: true);
                    setState(() {});
                  },
                  child: const Text('Mark As Done',
                      style: TextStyle(fontSize: 20)),
                  color: Colors.green,
                  textColor: Colors.white,
                  elevation: 5,
                ),
              ),
            ],
            Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => edit(task: widget.task),
                    ),
                  );

                  //setState(() {});
                },
                child: const Text('        Edit        ',
                    style: TextStyle(fontSize: 20)),
                color: Colors.blue,
                textColor: Colors.white,
                elevation: 5,
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () async{
                  bool isRemove = false;
                  isRemove =await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Do you want to delete this task?'),
                            content: Text('This will remove it from the list.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    context
                                        .read<todoList>()
                                        .removeFromList(widget.task);
                                    Navigator.of(context).pop(true);

                                  },
                                  child: Text('Yes')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('No')),
                            ],
                          ));
                 if(isRemove){
                   Navigator.pushAndRemoveUntil<dynamic>(
                     context,
                     MaterialPageRoute<dynamic>(
                       builder: (BuildContext context) => MyHomePage(),
                     ),
                         (route) => false,//if you want to disable back feature set to false
                   );}
                  setState(() {});
                  //Navigator.pop(context);
                },
                child: const Text('     Delete     ',
                    style: TextStyle(fontSize: 20)),
                color: Colors.red,
                textColor: Colors.white,
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
