import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'meal_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import '../state/meal_state.dart';
import '../models/sort_type.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  int _getTotalCalories(List<Meal> meals) {
    return meals.fold(0, (sum, meal) {
      final calories =
          int.tryParse(meal.calories.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return sum + calories;
    });
  }

  Widget _buildSortButton(
    BuildContext context,
    String label,
    String criterion,
    SortType currentSort,
  ) {
    bool isTimeSorting =
        currentSort == SortType.timeAsc || currentSort == SortType.timeDesc;
    bool isCaloriesSorting =
        currentSort == SortType.caloriesAsc ||
        currentSort == SortType.caloriesDesc;

    bool isSelected =
        (criterion == 'time' && isTimeSorting) ||
        (criterion == 'calories' && isCaloriesSorting);

    IconData icon = Icons.sort;
    if (criterion == 'time' && currentSort == SortType.timeAsc) {
      icon = Icons.arrow_upward;
    } else if (criterion == 'time' && currentSort == SortType.timeDesc) {
      icon = Icons.arrow_downward;
    } else if (criterion == 'calories' &&
        currentSort == SortType.caloriesDesc) {
      icon = Icons.arrow_downward;
    } else if (criterion == 'calories' && currentSort == SortType.caloriesAsc) {
      icon = Icons.arrow_upward;
    }

    return OutlinedButton.icon(
      onPressed: () {
        context.read<MealState>().setSort(criterion);
      },
      icon: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : const Color(0xFF28a745),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : const Color(0xFF28a745),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        backgroundColor: isSelected
            ? const Color(0xFF28a745)
            : Colors.transparent,
        side: const BorderSide(color: Color(0xFF28a745), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MealState>(
        builder: (context, mealState, child) {
          final meals = mealState.meals;
          final currentSort = mealState.currentSort;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        FirebaseCrashlytics.instance.crash();
                      },
                      child: const Text(
                        'MealPlanner',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF28a745),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C757D),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'МР',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Text(
                        'Сьогодні, ${DateTime.now().day} жовтня',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF495057),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_getTotalCalories(meals)}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF28a745),
                            ),
                          ),
                          const Text(
                            'калорій сплановано',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSortButton(
                          context,
                          'За часом',
                          'time',
                          currentSort,
                        ),
                        _buildSortButton(
                          context,
                          'За калоріями',
                          'calories',
                          currentSort,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (meals.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: const [
                              Text('🍴', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 10),
                              Text(
                                'Додайте свою першу страву',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6C757D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...meals.map((meal) {
                        return Dismissible(
                          key: Key(meal.id), // Унікальний ключ обов'язковий
                          direction: DismissDirection
                              .endToStart, // Свайп справа наліво
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC3545), // Червоний колір
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            // Підтвердження видалення
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Підтвердження"),
                                  content: const Text(
                                    "Ви дійсно хочете видалити цю страву?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Ні"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Так",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            // Викликаємо метод видалення
                            context.read<MealState>().deleteMeal(meal.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${meal.name} видалено')),
                            );
                          },
                          child: MealCard(meal: meal),
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
