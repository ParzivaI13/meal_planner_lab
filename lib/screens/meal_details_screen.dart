import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Потрібно для доступу до State
import 'dart:io'; // Потрібно для роботи з файлами (File)
import '../models/meal.dart';
import '../state/meal_state.dart';
import 'add_meal_screen.dart'; // Потрібно для навігації на екран редагування
import 'dart:convert';

class MealDetailsScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Деталі страви'),
        backgroundColor: const Color(0xFF28a745),
        foregroundColor: Colors.white,
        actions: [
          // --- КНОПКА РЕДАГУВАННЯ ---
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редагувати',
            onPressed: () async {
              // Відкриваємо екран додавання в режимі редагування (передаємо mealToEdit)
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMealScreen(mealToEdit: meal),
                ),
              );

              // Якщо повернувся результат (користувач натиснув "Зберегти")
              if (result != null && result is Map) {
                final updatedMeal = result['meal'] as Meal;
                final newImage = result['image'] as File?;

                if (context.mounted) {
                  // Викликаємо оновлення в базі даних через State
                  await context.read<MealState>().updateMeal(
                        updatedMeal, 
                        newImageFile: newImage
                      );
                  
                  // Повертаємось назад до списку, щоб дані оновились
                  Navigator.pop(context);
                }
              }
            },
          ),
          // ---------------------------
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Блок відображення фото
            if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Тут ми не можемо використати DecorationImage напряму з віджетом Image.memory
                  // Тому трохи змінимо підхід:
                ),
                clipBehavior: Clip.hardEdge, // Обрізаємо краї
                child: _buildImage(meal.imageUrl!), // Використовуємо той самий метод
              ),
            
            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meal.time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF495057),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.local_fire_department,
              title: 'Калорійність',
              value: meal.calories,
              color: const Color(0xFFDC3545),
            ),
            const SizedBox(height: 20),
            const Text(
              'Інгредієнти:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 10),
            meal.ingredients.isEmpty
                ? const Text(
                    'Не вказано',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
                  )
                : Text(
                    meal.ingredients,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF495057)),
                  ),
          ],
        ),
      ),
    );
    
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C757D),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageSource) {
    try {
      if (!imageSource.startsWith('http')) {
        return Image.memory(
          base64Decode(imageSource),
          fit: BoxFit.cover,
        );
      } else {
        return Image.network(
          imageSource,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return const Center(child: Icon(Icons.error));
    }
  }
}