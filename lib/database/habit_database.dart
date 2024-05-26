import 'package:flutter/cupertino.dart';
import 'package:habit_app_202/models/app_settings.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';

// This class is responsible for managing the database operations related to habits.
class HabitDatabase extends ChangeNotifier {
  // Isar is an object database, similar to SQLite but with objects.
  static late Isar isar;

  // This method initializes the Isar database.
  static Future<void> initialize() async {
    // Get the application documents directory.
    final dir = await getApplicationDocumentsDirectory();
    // Open the Isar database in the application documents directory.
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema],
      directory: dir.path,
    );
    print('Database initialized');
  }

  // This method saves the first launch date of the app.
  Future<void> saveFirstLaunchDate() async {
    // Get the existing settings.
    final existingSettings = await isar.appSettings.where().findFirst();
    final settings = existingSettings ?? AppSettings(); // Use existing settings if available, otherwise create a new settings object
    settings.firstLaunchDate = DateTime.now(); // Set the current date as the first launch date
    // Save the settings object to the database.
    await isar.writeTxn(() => isar.appSettings.put(settings));
    print('Saved first launch date: ${settings.firstLaunchDate}');
  }

  // This method gets the first launch date of the app.
  Future<DateTime?> getFirstLaunchDate() async {
    // Get the settings.
    final settings = await isar.appSettings.where().findFirst();
    // Return the first launch date.
    return settings?.firstLaunchDate;
  }

  // This list holds the current habits.
  final List<Habit> currentHabits = [];

  // This method adds a new habit.
  Future<void> addHabit(String habitName) async{
    // Create a new habit object.
    final newHabit = Habit()..name = habitName;
    // Save the new habit to the database.
    await isar.writeTxn(() => isar.habits.put(newHabit));
    // Refresh the list of habits.
    readHabits();
  }

  // This method reads all habits from the database.
  Future<void> readHabits() async {
    // Get all habits from the database.
    List<Habit> fetchedHabits = await isar.habits.where().findAll();
    // Clear the current habits list.
    currentHabits.clear();
    // Add all fetched habits to the current habits list.
    currentHabits.addAll(fetchedHabits);
    // Notify listeners that the list of habits has changed.
    notifyListeners();
  }

  // This method updates the completion status of a habit.
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // Get the habit by id.
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          // If the habit is completed and today is not in the list of completed days, add today to the list.
          final today = DateTime.now();
          habit.completedDays.add(
            DateTime(today.year, today.month, today.day),
          );
        }
        else {
          // If the habit is not completed, remove today from the list of completed days.
          habit.completedDays.removeWhere((date) =>
          date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day);
        }
        // Save the updated habit to the database.
        await isar.habits.put(habit);
      });
    }
    // Refresh the list of habits.
    readHabits();
  }

  // This method updates the name of a habit.
  Future<void> updateHabitName(int id, String newName) async {
    // Get the habit by id.
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        // Update the name of the habit.
        habit.name = newName;
        // Save the updated habit to the database.
        await isar.habits.put(habit);
      });
    }
    // Refresh the list of habits.
    readHabits();
  }

  // This method deletes a habit.
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async{
      // Delete the habit by id.
      await isar.habits.delete(id);
    });
    // Refresh the list of habits.
    readHabits();
  }
}