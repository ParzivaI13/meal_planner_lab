class Meal {
  final String id;
  final String time;
  final String name;
  final String
  calories;
  final String ingredients;
  final String? imageUrl;

  Meal({
    this.id = '',
    required this.time,
    required this.name,
    required this.calories,
    this.ingredients = '',
    this.imageUrl,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'time': time,
      'name': name,
      'calories': calories,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now()
          .toIso8601String(),
    };
  }

  factory Meal.fromFirestore(Map<String, dynamic> data, String docId) {
    return Meal(
      id: docId,
      time: data['time'] as String? ?? '',
      name: data['name'] as String? ?? '',
      calories: data['calories'] as String? ?? '',
      ingredients: data['ingredients'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toFirestore();
}