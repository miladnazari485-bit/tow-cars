import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/habit_store.dart';
import 'add_item_sheet.dart';
import 'other_screens.dart';
import 'today_screen.dart';

class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();
    assert(scope != null, 'ShellScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) =>
      openDrawer != oldWidget.openDrawer;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<HabitStore>();
    final pages = const [
      TodayScreen(),
      NotesScreen(),
      CalendarScreen(),
      StatsScreen(),
    ];

    return ShellScope(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Habit Tracker',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Dark mode'),
                secondary: Icon(
                  store.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                value: store.themeMode == ThemeMode.dark,
                onChanged: (_) => store.toggleTheme(),
              ),
              ListTile(
                leading: const Icon(Icons.today_outlined),
                title: const Text('Today'),
                onTap: () {
                  setState(() => _index = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inbox_outlined),
                title: const Text('Inbox'),
                onTap: () {
                  setState(() => _index = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Calendar'),
                onTap: () {
                  setState(() => _index = 2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: const Text('Statistics'),
                onTap: () {
                  setState(() => _index = 3);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddItemSheet(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.copy_outlined),
            selectedIcon: Icon(Icons.copy),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Stats',
          ),
        ],
      ),
    ),
    );
  }
}
