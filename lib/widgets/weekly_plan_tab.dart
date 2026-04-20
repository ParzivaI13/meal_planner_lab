import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/meal_state.dart';
import 'meal_card.dart';

class WeeklyPlanTab extends StatelessWidget {
  const WeeklyPlanTab({super.key});

  // Змінено: тепер тиждень вираховується від обраної дати, а не від "сьогодні"
  List<DateTime> _getWeekForDate(DateTime baseDate) {
    final startOfWeek = baseDate.subtract(Duration(days: baseDate.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getMonthName(int month) {
    const months = ['січня', 'лютого', 'березня', 'квітня', 'травня', 'червня', 'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня'];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const days = ['Понеділок', 'Вівторок', 'Середа', 'Четвер', 'П\'ятниця', 'Субота', 'Неділя'];
    return days[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    const shortDays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'НД'];

    return SafeArea(
      child: Consumer<MealState>(
        builder: (context, mealState, child) {
          final selectedDate = mealState.selectedDate;
          final weekDates = _getWeekForDate(selectedDate); // Використовуємо нову функцію
          final meals = mealState.meals;
          
          final totalCalories = meals.fold(0, (sum, meal) {
            final cals = int.tryParse(meal.calories.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
            return sum + cals;
          });

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ТИЖНЕВИЙ ПЛАН',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C757D),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Кнопка "Попередній тиждень"
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Color(0xFF495057)),
                          onPressed: () {
                            mealState.setSelectedDate(selectedDate.subtract(const Duration(days: 7)));
                          },
                        ),
                        Text(
                          '${weekDates.first.day} - ${weekDates.last.day} ${_getMonthName(weekDates.last.month)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF28a745),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Кнопка "Наступний тиждень"
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Color(0xFF495057)),
                          onPressed: () {
                            mealState.setSelectedDate(selectedDate.add(const Duration(days: 7)));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final date = weekDates[index];
                        final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;

                        return GestureDetector(
                          onTap: () => mealState.setSelectedDate(date),
                          child: Container(
                            width: 45,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF28a745) : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  shortDays[index],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF6C757D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xFF495057),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_getWeekdayName(selectedDate.weekday)}, ${selectedDate.day} ${_getMonthName(selectedDate.month)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF495057),
                          ),
                        ),
                        Text(
                          '$totalCalories ккал',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF28a745),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (meals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'На цей день немає запланованих страв',
                            style: TextStyle(color: Color(0xFF6C757D)),
                          ),
                        ),
                      )
                    else
                      ...meals.map((meal) => MealCard(meal: meal)),
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