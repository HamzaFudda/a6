// this is a custom class to make todo task object in which we can handle our multiple parameters
class todoTask {
  String title;
  String description;

  //date time is due date
  DateTime dateTime;

  //done means if the task has been marked as done
  bool done;

  //it is late because it will be initialized when task is marked as done
  late DateTime completion_dateTime;

  // this flag would check whether the task has passed the due date or not
  bool dueDatePass;
  String docID;
  todoTask(
      {required this.title,
      required this.description,
      required this.dateTime,
      required this.done,
      required this.dueDatePass,this.docID=""});

  static todoTask fromJson(Map<String, dynamic> json) => todoTask(
    title: json['Title'],
    description: json['Description'],
    dateTime: DateTime.parse(json['Date']),
    done: json['Done'],
    dueDatePass: json['Due Date'],

     
      );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Title'] = title;
    data['Description'] = description;
    data['Date'] = dateTime.toIso8601String();
    data['Done'] = done;
    data['Due Date'] = dueDatePass;
    return data;
  }
}
