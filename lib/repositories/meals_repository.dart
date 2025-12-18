import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal.dart';
import 'dart:io';
import 'dart:convert'; // <--- ВАЖЛИВО: Для кодування Base64

abstract class MealsRepository {
  Stream<List<Meal>> getMealsStream();
  Future<void> addMeal(Meal meal);
  Future<void> deleteMeal(String id);
  Future<void> updateMeal(Meal meal);
  Future<String?> uploadMealImage(File imageFile);
}

class FirestoreMealsRepository implements MealsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // FirebaseStorage більше не потрібен!

  CollectionReference _getMealsCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }
    return _firestore.collection('users').doc(user.uid).collection('meals');
  }

  @override
  Stream<List<Meal>> getMealsStream() {
    try {
      return _getMealsCollection()
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Meal.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  @override
  Future<void> addMeal(Meal meal) async {
    await _getMealsCollection().add(meal.toFirestore());
  }

  @override
  Future<void> deleteMeal(String id) async {
    await _getMealsCollection().doc(id).delete();
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    await _getMealsCollection().doc(meal.id).update(meal.toFirestore());
  }

  @override
  Future<String?> uploadMealImage(File imageFile) async {
    // ЗАМІСТЬ ЗАВАНТАЖЕННЯ В ХМАРУ — КОДУЄМО В РЯДОК
    try {
      final bytes = await imageFile.readAsBytes();
      // Повертаємо рядок Base64
      return base64Encode(bytes);
    } catch (e) {
      print('Помилка конвертації фото: $e');
      return null;
    }
  }
}