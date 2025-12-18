class Meal {
  final String id; // Додаємо ID для роботи з БД
  final String time;
  final String name;
  final String
  calories; // Зберігаємо як стрічку для UI "500 ккал", але в БД будемо чистити
  final String ingredients;
  final String? imageUrl; // Для майбутнього фото

  Meal({
    this.id = '', // По замовчуванню пустий, присвоїться з Firebase
    required this.time,
    required this.name,
    required this.calories,
    this.ingredients = '',
    this.imageUrl,
  });

  // Конвертація в Map для Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'time': time,
      'name': name,
      'calories': calories,
      'ingredients': ingredients,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now()
          .toIso8601String(), // Для сортування за датою створення
    };
  }

  // Створення об'єкта з документу Firestore
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

  // Старі методи toJson/fromJson можна залишити або видалити, якщо не плануєш кешувати локально json-ом
  Map<String, dynamic> toJson() => toFirestore();
}

  // для конвертації об'єкта Meal у Map
 /* Map<String, dynamic> toJson() {
    return {
      'time': time,
      'name': name,
      'calories': calories,
      'ingredients': ingredients,
    };
  }

  // конструктор для створення об'єкта Meal з Map
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      time: json['time'] as String,
      name: json['name'] as String,
      calories: json['calories'] as String,
      ingredients: json['ingredients'] as String? ?? '',
    );
  }
}*/