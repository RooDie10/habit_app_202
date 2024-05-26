import 'package:flutter/material.dart';
import 'package:habit_app_202/components/my_habits_tile.dart';
import 'package:habit_app_202/components/my_heat_map.dart';
import 'package:provider/provider.dart';
import '../components/my_drawer.dart';
import '../database/habit_database.dart';
import '../models/habit.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<DateTime?>? firstLaunchDateFuture;

  @override
  void initState() {
    super.initState();
    firstLaunchDateFuture = Provider.of<HabitDatabase>(context, listen: false).getFirstLaunchDate();
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
  }

final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create a new habit'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              String newHabitName = textController.text;
              if (newHabitName.isEmpty) {
                // Show a warning to the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Habit name cannot be empty')),
                );
              } else {
                context.read<HabitDatabase>().addHabit(newHabitName);
                Navigator.pop(context);
                textController.clear();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

void checkHabitOnOff(bool? value, Habit habit) {
  if (value != null) {
    context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
  }
}

  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                textController.clear();
              },
              child: const Text('Cancel'),
            ),
            MaterialButton(
              onPressed: () {
                String newHabitName = textController.text;
                if (newHabitName.isEmpty) {
                  // Show a warning to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Habit name cannot be empty')),
                  );
                } else {
                  context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
                  Navigator.pop(context);
                  textController.clear();
                }
              },
              child: const Text('Change'),
            ),
          ],
        )
    );
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete this habit?'),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
          MaterialButton(
            onPressed: () {
              context.read<HabitDatabase>().deleteHabit(habit.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          _buildHeatMap(),
          _buildHabitList(),
        ],
      ),
    );
  }

  Widget _buildHeatMap() {
    final habitDatabase = context.watch<HabitDatabase>();
    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
      future: firstLaunchDateFuture, // Use the stored Future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading...');
          return CircularProgressIndicator(); // return a loading indicator
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}'); // return an error message
        } else if (snapshot.hasData) {
          print('First Launch Date: ${snapshot.data}');
          DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
          DateTime normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);

          return MyHeatMap(
            startDate: normalizedStartDate,
            datasets: prepareHeatMapDataset(currentHabits),
          );
        } else {
          print('No data');
          return Container(); // return an empty container
        }
      },
    );
  }

  Widget _buildHabitList() {
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;
    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index)
    {
      final habit = currentHabits[index];
      bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
      return MyHabitTile(
        text: habit.name,
        isCompleted: isCompletedToday,
        onChanged: (value) => checkHabitOnOff(value, habit),
        editHabit: (content) => editHabitBox(habit),
        deleteHabit: (content) => deleteHabitBox(habit),
      );
    },
    );
  }
}