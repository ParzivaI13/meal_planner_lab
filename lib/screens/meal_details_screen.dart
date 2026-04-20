import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'dart:io'; 
import '../models/meal.dart';
import '../state/meal_state.dart';
import 'add_meal_screen.dart'; 
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
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редагувати',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMealScreen(mealToEdit: meal),
                ),
              );

              if (result != null && result is Map) {
                final updatedMeal = result['meal'] as Meal;
                final newImage = result['image'] as File?;

                if (context.mounted) {
                  await context.read<MealState>().updateMeal(
                        updatedMeal, 
                        newImageFile: newImage
                      );
                  
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (meal.imageUrl != null && meal.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildImage(meal.imageUrl!),
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
            const SizedBox(height: 15),

            // Блок макронутрієнтів
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroBadge('Білки', meal.protein, const Color(0xFF28a745)),
                _buildMacroBadge('Жири', meal.fat, const Color(0xFFFFC107)),
                _buildMacroBadge('Вуглеводи', meal.carbs, const Color(0xFF17A2B8)),
              ],
            ),
            
            const SizedBox(height: 25),
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

  Widget _buildMacroBadge(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
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