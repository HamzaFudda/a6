import 'package:assignment4/newTask.dart';
import 'package:assignment4/taskTittle.dart';
import 'package:assignment4/todoList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => todoList(),
      ),
      // ChangeNotifierProvider(
      //   create: (_) => dateProvider(),
      // ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const newTask(),
      home:  MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
   MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    getTasks();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Tasks"),
        ),
        //this line checks if list is empty it displays a different widget else different widget
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (!context.watch<todoList>().tasks.isEmpty)
                ? tasks()
                : notask(),
        //floating action button also appears when the list is not empty
        floatingActionButton: (!context.watch<todoList>().tasks.isEmpty)
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {});
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => newTask()));
                },
                tooltip: 'new task',
                child: const Icon(Icons.add),
              )
            : null);
  }

  getTasks() async {
    
    isLoading = true;
    setState(() {});
    await context.read<todoList>().getTasks();
    isLoading = false;
    setState(() {});
  }
}

class notask extends StatelessWidget {
  const notask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have no pending tasks',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => newTask()));
                },
                child: Text("Add a new task", style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}

class tasks extends StatefulWidget {
  const tasks({Key? key}) : super(key: key);

  @override
  _tasksState createState() => _tasksState();
}

class _tasksState extends State<tasks> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          //use of expanded to avoid errors
          Expanded(child: listOfTask()),
          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }
}

class listOfTask extends StatefulWidget {
  const listOfTask({Key? key}) : super(key: key);

  @override
  _listOfTaskState createState() => _listOfTaskState();
}

class _listOfTaskState extends State<listOfTask> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      //watch dynamically watches count and changes item count
      itemCount: context.watch<todoList>().tasks.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: ListTile(
            title: Text(
              context.watch<todoList>().tasks[index].title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text("Due: " +
                DateFormat('dd-MMM-yyyy')
                    .format(context.watch<todoList>().tasks[index].dateTime)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                (context.watch<todoList>().tasks[index].done)
                    //this way we can mark done task as undone and when it is again marked as done then the new date of completion will be updated
                    ? IconButton(
                        color: Colors.green,
                        icon: Icon(Icons.check_circle_rounded),
                        onPressed: () {
                          context.read<todoList>().tasks[index].done = false;
                          bool temp = false;
                          context.read<todoList>().markAsDone1(
                              task: context.read<todoList>().tasks[index],
                              temp: temp);
                          // context.read<todoList>().dueDateCheckList();
                          // context.read<todoList>().sortingList();
                          setState(() {});
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.circle_outlined),
                        color: Colors.black,
                        onPressed: () {
                          context.read<todoList>().tasks[index].done = true;
                          bool temp = true;
                          context.read<todoList>().markAsDone1(
                              task: context.read<todoList>().tasks[index],
                              temp: temp);
                          // context
                          //     .read<todoList>()
                          //     .tasks[index]
                          //     .completion_dateTime = DateTime.now();
                          // context.read<todoList>().dueDateCheckList();
                          // context.read<todoList>().sortingList();
                          setState(() {});
                        },
                      ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () async {
                    await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Do you want to delete this task?'),
                              content:
                                  Text('This will remove it from the list.'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      context.read<todoList>().removeFromList(
                                          context
                                              .read<todoList>()
                                              .tasks[index]);
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

                    setState(() {});
                  },
                ),
                (context.watch<todoList>().tasks[index].dueDatePass)
                    ? SizedBox(
                        width: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                        ))
                    : SizedBox(
                        width: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                          ),
                        )),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => taskTitle(
                    task: context.read<todoList>().tasks[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
