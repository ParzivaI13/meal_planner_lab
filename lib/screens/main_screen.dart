import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../widgets/home_tab.dart';
import '../widgets/weekly_plan_tab.dart';
import '../widgets/statistics_tab.dart';
import '../widgets/settings_tab.dart';
import 'add_meal_screen.dart';
import 'package:provider/provider.dart';
import '../state/meal_state.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mealState = context.read<MealState>();

    final List<Widget> screens = [
      const HomeTab(),
      const WeeklyPlanTab(),
      const StatisticsTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
        floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1 // Додаємо на таб тижня теж
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMealScreen(
                      // Передаємо обрану дату з MealState
                      initialDate: context.read<MealState>().selectedDate, 
                    ),
                  ),
                );

                if (result != null && result is Map) {
                  final meal = result['meal'] as Meal;
                  final image = result['image'] as File?;
                  if (context.mounted) {
                     context.read<MealState>().addMeal(meal, imageFile: image);
                  }
                }
              },
              backgroundColor: const Color(0xFF28a745),
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF28a745),
        unselectedItemColor: const Color(0xFF6C757D),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Text('🏠', style: TextStyle(fontSize: 20)),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Text('📅', style: TextStyle(fontSize: 20)),
            label: 'Тиждень',
          ),
          BottomNavigationBarItem(
            icon: Text('📊', style: TextStyle(fontSize: 20)),
            label: 'Статистика',
          ),
          BottomNavigationBarItem(
            icon: Text('⚙️', style: TextStyle(fontSize: 20)),
            label: 'Налашт.',
          ),
        ],
      ),
    );
  }
}
