import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/app_shell.dart';
import 'state/habit_store.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = HabitStore();
  await store.load();
  runApp(HabitTrackerApp(store: store));
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key, required this.store});

  final HabitStore store;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: store,
      child: Consumer<HabitStore>(
        builder: (context, store, _) {
          return MaterialApp(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: store.themeMode,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
