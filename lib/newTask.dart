import 'package:assignment4/main.dart';
import 'package:assignment4/todo.dart';
import 'package:assignment4/todoList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class newTask extends StatefulWidget {
  const newTask({Key? key}) : super(key: key);

  @override
  _newTaskState createState() => _newTaskState();
}

class _newTaskState extends State<newTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Task"),
      ),
      body: Container(
        //SingleChildScrollView is used to avoid pixel overflow
        //taskForm() widget is used to avoid rebuilding of the whole screen
        child: SingleChildScrollView(child: taskForm()),
      ),
    );
  }
}

class taskForm extends StatefulWidget {
  const taskForm({Key? key}) : super(key: key);

  @override
  _taskFormState createState() => _taskFormState();
}

class _taskFormState extends State<taskForm> {
  //global key is used for form which can use validator which can make fields red when they are empty
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  TextEditingController titleMainController = TextEditingController();
  TextEditingController descriptionMainController = TextEditingController();

  //initial date
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: <Widget>[
        SizedBox(height: 100),
        //title widget
        title(
          titleController: titleMainController,
          submit: _submitted,
        ),
        //description widget
        description(
            descriptionController: descriptionMainController,
            submit: _submitted),
        //datePicker widget
        datePicker(
            selectedDate: selectedDate,
            //selected is updated through callback
            onPressedUpdate: (recieved_date) {
              selectedDate = recieved_date;
            },
            submit: _submitted),
        SizedBox(
          height: 40,
          //this widget will check whether all fields are filled or not
          //if filled it will add the task to the list
          child: ElevatedButton(
            onPressed: () {
              setState(() => _submitted = true);
              if (_formKey.currentState!.validate()) {
                context.read<todoList>().addTasks(
                    title_f: titleMainController.text,
                    description_f: descriptionMainController.text,
                    dateTime_f: selectedDate,
                    done_f: false);
                //print(titleMainController.text);
                //context.read<todoList>().printList();
                Navigator.pop(context);
              }
            },
            child: Text(
              'Submit',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}

//this widget will display a calendar to select the date for the task
class datePicker extends StatefulWidget {
  final Function(DateTime) onPressedUpdate;
  DateTime selectedDate;
  bool submit;

  datePicker(
      {Key? key,
      required this.selectedDate,
      required this.onPressedUpdate,
      required this.submit})
      : super(key: key);

  @override
  _datePickerState createState() => _datePickerState();
}

class _datePickerState extends State<datePicker> {
  TextEditingController _date = TextEditingController();
  DateTime? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
        child: TextFormField(
            //this will block keyboard
            showCursor: false,
            readOnly: true,
            controller: _date,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  //async and await to properly get the date
                  onPressed: () async {
                    await _selectDate(context);
                    (selected != null)
                        ? _date.text = DateFormat('dd-MMM-yyyy')
                            .format(widget.selectedDate)
                        //clear controller if no date is selected
                        : _date.clear();
                    setState(() {});
                  },
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Due date",
                hintStyle: TextStyle(
                    color: !widget.submit ? Colors.black : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
            autovalidateMode: widget.submit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Field Required';
              }
            }),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    selected = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != widget.selectedDate) {
      setState(() {
        widget.selectedDate = selected!;
      });
      //use of callback
      widget.onPressedUpdate(widget.selectedDate);
    }
    //print(selected);
  }
}

class title extends StatelessWidget {
  TextEditingController titleController = TextEditingController();
  bool submit;

  title({Key? key, required this.titleController, required this.submit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        child: TextFormField(
            controller: titleController,
            style: TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Title",
                hintStyle: TextStyle(
                    color: !submit ? Colors.black54 : Colors.red, fontSize: 20),
                disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
            autovalidateMode: submit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Field Required';
              }
            }),
      ),
    );
  }
}

class description extends StatelessWidget {
  TextEditingController descriptionController = TextEditingController();
  bool submit;

  description(
      {Key? key, required this.descriptionController, required this.submit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            controller: descriptionController,
            style: TextStyle(color: Colors.black, fontSize: 20),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(12, 50, 12, 10),
                fillColor: Colors.grey.shade100,
                filled: true,
                hintText: "Description",
                hintStyle: TextStyle(
                    color: !submit ? Colors.black54 : Colors.red, fontSize: 20),
                disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
            autovalidateMode: submit
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: (text) {
              if (text == null || text.isEmpty) {
                return 'Field Required';
              }
            }),
      ),
    );
  }
}
