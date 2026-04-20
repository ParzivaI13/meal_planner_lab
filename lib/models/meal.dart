class Meal {
  final String id;
  final DateTime date;
  final String time;
  final String name;
  final String calories;
  final String protein; // Білки
  final String fat;     // Жири
  final String carbs;   // Вуглеводи
  final String ingredients;
  final String? imageUrl;

  Meal({
    this.id = '',
    required this.date,
    required this.time,
    required this.name,
    required this.calories,
    this.protein = '0',
    this.fat = '0',
    this.carbs = '0',
    this.ingredients = '',
    this.imageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Meal.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime parsedDate;
    if (data['date'] != null) {
      parsedDate = DateTime.parse(data['date']);
    } else if (data['createdAt'] != null) {
      parsedDate = DateTime.parse(data['createdAt']);
    } else {
      parsedDate = DateTime.now();
    }

    return Meal(
      id: docId,
      date: parsedDate,
      time: data['time'] as String? ?? '',
      name: data['name'] as String? ?? '',
      calories: data['calories'] as String? ?? '',
      protein: data['protein'] as String? ?? '0',
      fat: data['fat'] as String? ?? '0',
      carbs: data['carbs'] as String? ?? '0',
      ingredients: data['ingredients'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toFirestore();
}