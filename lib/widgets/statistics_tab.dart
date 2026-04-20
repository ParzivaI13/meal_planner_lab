import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/meal_state.dart';
import 'dart:math';

class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  int _parseValue(String valueStr) {
    return int.tryParse(valueStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<MealState>(
        builder: (context, mealState, child) {
          final allMeals = mealState.allMeals;

          final now = DateTime.now();
          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

          final weekMeals = allMeals.where((meal) {
            return meal.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
                   meal.date.isBefore(endOfWeek.add(const Duration(seconds: 1)));
          }).toList();

          int totalCalories = 0;
          List<int> caloriesPerDay = List.filled(7, 0); 
          
          int totalProtein = 0;
          int totalFat = 0;
          int totalCarbs = 0;

          for (var meal in weekMeals) {
            final cals = _parseValue(meal.calories);
            totalCalories += cals;
            
            int dayIndex = meal.date.weekday - 1;
            caloriesPerDay[dayIndex] += cals;
            
            totalProtein += _parseValue(meal.protein);
            totalFat += _parseValue(meal.fat);
            totalCarbs += _parseValue(meal.carbs);
          }

          int totalMealsCount = weekMeals.length;

          int totalMacros = totalProtein + totalFat + totalCarbs;
          int proteinPct = totalMacros > 0 ? (totalProtein / totalMacros * 100).round() : 0;
          int fatPct = totalMacros > 0 ? (totalFat / totalMacros * 100).round() : 0;
          int carbsPct = totalMacros > 0 ? (totalCarbs / totalMacros * 100).round() : 0;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'СТАТИСТИКА',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6C757D),
                        letterSpacing: 1,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Цей тиждень',
                        style: TextStyle(
                          color: Color(0xFF28a745),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
                    const Text(
                      'Загальні показники',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: totalCalories.toDouble()),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOutQuart,
                                  builder: (context, value, child) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF28a745),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Всього калорій',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: totalMealsCount.toDouble()),
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOutQuart,
                                  builder: (context, value, child) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF28a745),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Страв додано',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Графік калорій по днях',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF495057),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildChart(caloriesPerDay), 
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      'Фактичний баланс (БЖВ)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildBalanceBar('Білки', proteinPct, const Color(0xFF28a745)),
                    const SizedBox(height: 12),
                    _buildBalanceBar('Жири', fatPct, const Color(0xFFFFC107)),
                    const SizedBox(height: 12),
                    _buildBalanceBar('Вуглеводи', carbsPct, const Color(0xFF17A2B8)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChart(List<int> caloriesPerDay) {
    const days = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'НД'];
    
    final maxCal = caloriesPerDay.reduce(max);
    final safeMax = maxCal > 0 ? maxCal : 1; 

    return SizedBox(
      height: 150, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final val = caloriesPerDay[index];

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: val.toDouble()),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animatedVal, child) {
              final heightRatio = animatedVal / safeMax;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    val > 0 ? '${animatedVal.toInt()}' : '', 
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6C757D), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 100 * heightRatio,
                    decoration: BoxDecoration(
                      color: val > 0 ? const Color(0xFF28a745) : const Color(0xFFDEE2E6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF495057)
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildBalanceBar(String label, int percentage, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: percentage.toDouble()),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, animatedPercentage, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF495057),
                  ),
                ),
                Text(
                  '${animatedPercentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF495057),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedPercentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}