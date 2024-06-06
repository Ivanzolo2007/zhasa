import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zhasa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}

class Task {
  String name;
  String date;
  String time;
  bool isCompleted;

  Task({required this.name, required this.date, required this.time, this.isCompleted = false});
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  DateTime? selectedDate;

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _editTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index, bool? value) {
    setState(() {
      tasks[index].isCompleted = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Wednesday 12, Dec',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  DateTime today = DateTime.now();
                  DateTime weekDay = today.add(Duration(days: index - today.weekday + 1));
                  String dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekDay.weekday - 1];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = weekDay;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          dayName,
                          style: TextStyle(
                            color: selectedDate == weekDay ? Colors.white : Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          weekDay.day.toString(),
                          style: TextStyle(
                            color: selectedDate == weekDay ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.startToEnd) {
                        _deleteTask(index);
                      } else if (direction == DismissDirection.endToStart) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateTaskScreen(
                              onCreate: (task) => _editTask(index, task),
                              selectedDate: DateTime.parse(tasks[index].date),
                              existingTask: tasks[index],
                            ),
                          ),
                        );
                      }
                    },
                    child: Card(
                      color: tasks[index].isCompleted ? Colors.grey.shade300 : Colors.deepPurple,
                      child: ListTile(
                        leading: Checkbox(
                          value: tasks[index].isCompleted,
                          activeColor: Colors.deepPurple,
                          onChanged: (bool? value) {
                            _toggleTaskCompletion(index, value);
                          },
                        ),
                        title: Text(
                          tasks[index].name,
                          style: TextStyle(
                            color: tasks[index].isCompleted ? Colors.black : Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          '${tasks[index].date} - ${tasks[index].time}',
                          style: TextStyle(
                            color: tasks[index].isCompleted ? Colors.black : Colors.white70,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TaskDetailScreen(task: tasks[index])),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen(onCreate: _addTask)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
      ),
    );
  }

  TaskDetailScreen({required Task task}) {}
}

class CreateTaskScreen extends StatefulWidget {
  final Function(Task) onCreate;
  final DateTime? selectedDate;
  final Task? existingTask;

  CreateTaskScreen({required this.onCreate, this.selectedDate, this.existingTask});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _taskName = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _remindMe = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    if (widget.existingTask != null) {
      _taskName = widget.existingTask!.name;
      _selectedDate = DateTime.parse(widget.existingTask!.date);
      _selectedTime = TimeOfDay(
        hour: int.parse(widget.existingTask!.time.split(":")[0]),
        minute: int.parse(widget.existingTask!.time.split(":")[1]),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        ),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Create',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    Text(
    'New Task',
    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 16),
    TextFormField(
    initialValue: _taskName,
    decoration: InputDecoration(
    labelText: 'Task name',
    ),
    onSaved: (value) => _taskName = value ?? '',
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a task name';
    }
    return null;
    },
    ),
    SizedBox(height: 60),
    Container(
    width: double.infinity,
    height: 400,
    child: Card(
    child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
    children: [
    TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
      controller: TextEditingController(
        text: _selectedDate == null
            ? ''
            : _selectedDate!.toString().split(' ')[0],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a date';
        }
        return null;
      },
    ),
      SizedBox(height: 16),
      TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Time',
          suffixIcon: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: () => _selectTime(context),
          ),
        ),
        controller: TextEditingController(
          text: _selectedTime?.format(context) ?? '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a time';
          }
          return null;
        },
      ),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Remind me'),
          Switch(
            value: _remindMe,
            onChanged: (bool value) {
              setState(() {
                _remindMe = value;
              });
            },
          ),
        ],
      ),
      SizedBox(height: 130),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            widget.onCreate(Task(
              name: _taskName,
              date: _selectedDate?.toString().split(' ')[0] ?? '',
              time: _selectedTime?.format(context) ?? '',
              isCompleted: _remindMe,
            ));
            Navigator.pop(context);
          }
        },
        child: Text(
          widget.existingTask == null ? '+ Create Task' : 'Save Changes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // Set text color to white
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // Set button background color to purple
          minimumSize: Size(double.infinity, 60),
        ),
      ),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    ),
        ),
    );
  }
}
