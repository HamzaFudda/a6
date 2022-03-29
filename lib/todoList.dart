import 'package:assignment4/editScreen.dart';
import 'package:assignment4/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

//this class would implement change notifier and will help us in managing our list with the help of state management
class todoList extends ChangeNotifier {
  //this list will contain all the todo tasks
  List<todoTask> tasks = [];
  List<todoTask> tasks1 = [];

  Future<void> getTasks() async {
    tasks.clear();
    await FirebaseFirestore.instance
        .collection('tasksList')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
          todoTask temp=todoTask.fromJson(doc.data() as Map<String, dynamic>);
          temp.docID=doc.id;
          if(temp.done==true)
          temp.completion_dateTime=DateTime.parse(doc.get("Completion Date"));
          tasks.add(temp);
        //  print(tasks[0].title);
      });
    });
    dueDateCheckList();
    sortingList();
    //print(tasks.toString());
  }

  //this method will add tasks to our list
  Future<void> addTasks(
      {required String title_f,
      required String description_f,
      required DateTime dateTime_f,
      required bool done_f}) async {
    //dueDatePassed stores the flag value returned by checkDueDate
    bool dueDatePassed = checkDueDate(dateTime_f);
    createTask(
        title_f: title_f,
        description_f: description_f,
        dateTime_f: dateTime_f,
        done_f: done_f,
        due_f: dueDatePassed);
    await getTasks();
    dueDateCheckList();
    sortingList();
    notifyListeners();
  }
  Future<void>editTask({required todoTask task})async{
    await updateData(task: task);
    await getTasks();
    dueDateCheckList();
    sortingList();
    notifyListeners();
  }

  Future<void> createTask(
      {required String title_f,
      required String description_f,
      required DateTime dateTime_f,
      required bool done_f,
      required bool due_f}) async {
    // Call the user's CollectionReference to add a new user

    CollectionReference taskReference = FirebaseFirestore.instance.collection('tasksList') ;
    final todo = todoTask(
        title: title_f,
        description: description_f,
        dateTime: dateTime_f,
        done: done_f,
        dueDatePass: due_f);
    taskReference
        .add(todo.toJson())
        .then((value) => print("task Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }



  //this method marks as done a task and then notify all listeners about the changes
  void markAsDone({required todoTask task}) async {
    task.done = true;
    task.completion_dateTime = DateTime.now();
    await updateData(task: task);
    sortingList();
    notifyListeners();
  }
  void markAsDone1({required todoTask task,required bool temp}) async {
    task.done = temp;
    task.completion_dateTime = DateTime.now();
    await updateData(task: task);
    sortingList();
    notifyListeners();
  }

  updateData({required todoTask task}) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('tasksList').doc(task.docID);

    final Map<String, dynamic> data = {};
    data['Title'] = task.title;
    data['Description'] = task.description;
    data['Date'] = task.dateTime.toIso8601String();
    data['Done'] = task.done;
    data['Due Date'] = task.dueDatePass;
    data['Completion Date']=task.dateTime.toIso8601String();

    // update data to Firebase
    documentReference.update(data).whenComplete(() => print('updated'));
  }

  //this method checks whether due date has been passed or not
  bool checkDueDate(DateTime dt) {
    if (DateTime.now().isAfter(dt)) {
      return true;
    }
    return false;
  }

  //this method was created for debugging purposes
  void printList() {
    for (int i = 0; i < tasks.length; i++) {
      todoTask temp = tasks[i];
      print(temp.title + " " + temp.description);
    }
  }

  //this method sorts the list first by date then by is it done or not
  void sortingList() {
    tasks.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? -1 : 1);
    tasks.sort((a, b) => !a.done ? -1 : 1);
  }

  void dueDateCheckList() {
    for (int i = 0; i < tasks.length; i++) {
      tasks[i].dueDatePass = checkDueDate(tasks[i].dateTime);
    }
    notifyListeners();
  }

  void removeFromList(todoTask task) async {
    tasks.remove(task);
    await deleteData(task);
    dueDateCheckList();
    sortingList();
    notifyListeners();
  }

  Future<void> deleteData(todoTask task) async {
    await FirebaseFirestore.instance
        .collection('tasksList')
        .doc(task.docID)
        .delete()
        .catchError((e) {
      print(e);
    }).whenComplete(() => print('deleted'));

    // delete data from Firebase
  }
}
