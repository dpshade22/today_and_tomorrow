import 'package:flutter/material.dart';
import 'dart:math';

class HabitView extends StatefulWidget {
  const HabitView({Key? key}) : super(key: key);

  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  final TextEditingController myController = TextEditingController();
  final List<HabitItem> _habits = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today and Tomorrow'),
        backgroundColor: const Color.fromRGBO(241, 81, 82, 1),
      ),
      body: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("You are level 21"),
          ),
          cardsOfHabits(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // When the user presses the button, show an alert dialog containing
        // the text that the user has entered into the text field.
        backgroundColor: const Color.fromRGBO(58, 46, 57, 1),
        onPressed: () {
          showHabitInputAlert();
        },
        tooltip: 'Show me the value!',
        child: const Icon(Icons.create),
      ),
    );
  }

  ListView cardsOfHabits() {
    return ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                  '${_habits[index].name} at level ${_habits[index].level}'),
              leading: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _updateCounter(index),
                focusColor: Colors.green,
              ),
              onLongPress: () => showHabitAlert(index),
              onTap: () =>
                  // showHabitAlert(index)
                  showHabitModal(context, index),
              trailing: Text(numToPercents(_habits[index].counter, index)),
            ),
          );
        });
  }

  Future<void> showHabitModal(BuildContext context, int index) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Habits ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                RichText(
                    text: TextSpan(
                        text: _habits[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Completed ${_habits[index].counter} times'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Level ${levelFormula(_habits[index].counter)}'),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showHabitInputAlert() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Retrieve the text the that user has entered by using the
          // TextEditingController.
          content: IntrinsicHeight(
            child: Column(
              children: [
                const Text("Enter new habit!"),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hoverColor: Color.fromRGBO(237, 177, 131, 1),
                      hintText: 'Enter a habit',
                    ),
                    onSubmitted: _newHabit,
                    controller: myController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showHabitAlert(int index) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // Retrieve the text the that user has entered by using the
          // TextEditingController.
          content: IntrinsicHeight(
            child: Column(
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Habits ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                RichText(
                    text: TextSpan(
                        text: _habits[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Completed ${_habits[index].counter} times'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text('Level ${levelFormula(_habits[index].counter)}'),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Delete'),
              style: TextButton.styleFrom(primary: Colors.red),
              onPressed: () {
                _delHabit(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _newHabit(input) {
    setState(() {
      HabitItem newHab = HabitItem(input, 0, 0, 0);

      _habits.add(newHab);
      Navigator.of(context).pop();
      myController.clear();
    });
  }

  void _updateCounter(index) {
    int numNextLevel = _habits[index].counter;
    int newCompleted = _habits[index].counter + 1;
    int numFloorLevel = _habits[index].counter;

    // Finds minimum number of tasks for the next level
    while (levelFormula(numNextLevel) < (levelFormula(newCompleted) + 1)) {
      numNextLevel++;
    }

    // Finds minimum number of tasks for the current level
    while (levelFormula(numFloorLevel) == levelFormula(newCompleted)) {
      numFloorLevel--;
    }
    numFloorLevel++;

    // Number of tasks completed in current level
    int currProgress = newCompleted - numFloorLevel;
    // Number of tasks until next level
    int tillNextLevel = (numNextLevel - newCompleted);
    // Percent progress until next level
    double progress = (currProgress / (tillNextLevel + currProgress) * 100);

    setState(() {
      _habits[index].counter = newCompleted;
      _habits[index].level = levelFormula(newCompleted);
      _habits[index].percentProgress = progress;
    });
  }

  void _delHabit(index) {
    setState(() {
      _habits.removeAt(index);
    });
  }

  String numToPercents(numCompleted, index) {
    return '${_habits[index].percentProgress.toStringAsFixed(2)}%';
  }

  int levelFormula(numCompleted) {
    return (1.5 * pow(19 * numCompleted, 1 / 3)).floor();
  }
}

class HabitItem {
  String name;
  int counter;
  int level;
  double percentProgress;

  HabitItem(this.name, this.counter, this.level, this.percentProgress);
}
