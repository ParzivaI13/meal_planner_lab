import 'package:flutter/material.dart';

class WeeklyPlanTab extends StatefulWidget {
  const WeeklyPlanTab({super.key});

  @override
  State<WeeklyPlanTab> createState() => _WeeklyPlanTabState();
}

class _WeeklyPlanTabState extends State<WeeklyPlanTab> {
  int selectedDay = 27;

  final List<Map<String, dynamic>> weekDays = [
    {'day': 'ПН', 'date': 24},
    {'day': 'ВТ', 'date': 25},
    {'day': 'СР', 'date': 26},
    {'day': 'ЧТ', 'date': 27},
    {'day': 'ПТ', 'date': 28},
    {'day': 'СБ', 'date': 29},
    {'day': 'НД', 'date': 30},
  ];

  final List<Map<String, dynamic>> todayMeals = [
    {'name': 'Омлет', 'type': 'СНІДАНОК', 'color': Color(0xFF28a745)},
    {'name': 'Паста', 'type': 'ОБІД', 'color': Color(0xFFFFC107)},
    {'name': 'Риба', 'type': 'ВЕЧЕРЯ', 'color': Color(0xFF17A2B8)},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                    const Text(
                      'Тиждень',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const Text(
                      '24-30 листопада',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF28a745),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.map((day) {
                    final isSelected = day['date'] == selectedDay;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day['date'];
                        });
                      },
                      child: Container(
                        width: 45,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF28a745)
                              : const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day['day'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6C757D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day['date']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF495057),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
                    const Text(
                      'Четвер, 27 листопада',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF495057),
                      ),
                    ),
                    const Text(
                      '1,923 ккал',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF28a745),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ...todayMeals.map((meal) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: meal['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              meal['type'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meal['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF28a745),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Скопіювати план',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}