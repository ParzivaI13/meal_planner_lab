import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/sort_type.dart';
import '../repositories/meals_repository.dart';

int _parseTime(String time) {
  try {
    final timeStr = time.split('•').last.trim();
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  } catch (e) {
    return 0;
  }
}

int _parseCalories(String calories) {
  return int.tryParse(calories.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

class MealState extends ChangeNotifier {
  final MealsRepository _repository = FirestoreMealsRepository();
  
  List<Meal> _meals = [];
  StreamSubscription<List<Meal>>? _mealsSubscription;
  StreamSubscription<User?>? _authSubscription; 

  SortType _currentSort = SortType.none;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  bool get isLoading => _isLoading;
  SortType get currentSort => _currentSort;
  DateTime get selectedDate => _selectedDate; 

  MealState() {
    _initAuthListener();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _meals = [];
        _mealsSubscription?.cancel();
        _mealsSubscription = null;
        notifyListeners();
      } else {
        _initMealsStream();
      }
    });
  }

  void _initMealsStream() {
    _mealsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _mealsSubscription = _repository.getMealsStream().listen((mealsData) {
      _meals = mealsData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Помилка отримання страв: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _mealsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  List<Meal> get allMeals => _meals; 

  List<Meal> get meals {
    final List<Meal> list = _meals.where((meal) {
      return meal.date.year == _selectedDate.year &&
             meal.date.month == _selectedDate.month &&
             meal.date.day == _selectedDate.day;
    }).toList();

    if (_currentSort == SortType.timeAsc || _currentSort == SortType.timeDesc) {
      list.sort((a, b) {
        final timeA = _parseTime(a.time);
        final timeB = _parseTime(b.time);
        final comparison = timeA.compareTo(timeB);
        return _currentSort == SortType.timeAsc ? comparison : -comparison;
      });
    } else if (_currentSort == SortType.caloriesAsc || _currentSort == SortType.caloriesDesc) {
      list.sort((a, b) {
        final calA = _parseCalories(a.calories);
        final calB = _parseCalories(b.calories);
        final comparison = calA.compareTo(calB);
        return _currentSort == SortType.caloriesAsc ? comparison : -comparison;
      });
    }

    return list;
  }

  void setSort(String criterion) {
    SortType newSort = SortType.none;

    if (criterion == 'time') {
      if (_currentSort == SortType.timeAsc) {
        newSort = SortType.timeDesc;
      } else if (_currentSort == SortType.timeDesc) {
        newSort = SortType.none;
      } else {
        newSort = SortType.timeAsc;
      }
    } else if (criterion == 'calories') {
      if (_currentSort == SortType.caloriesDesc) {
        newSort = SortType.caloriesAsc;
      } else if (_currentSort == SortType.caloriesAsc) {
        newSort = SortType.none;
      } else {
        newSort = SortType.caloriesDesc;
      }
    }

    if (_currentSort != newSort) {
      _currentSort = newSort;
      notifyListeners();
    }
  }

  Future<void> addMeal(Meal meal, {File? imageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _repository.uploadMealImage(imageFile);
      }

      final newMeal = Meal(
        date: meal.date, 
        time: meal.time,
        name: meal.name,
        calories: meal.calories,
        protein: meal.protein,
        fat: meal.fat,
        carbs: meal.carbs,
        ingredients: meal.ingredients,
        imageUrl: imageUrl,
      );

      await _repository.addMeal(newMeal);
      
    } catch (e) {
      print("Помилка додавання: $e");
    } finally {
      _isLoading = false; 
      notifyListeners(); 
    }
  }

  Future<void> deleteMeal(String id) async {
     await _repository.deleteMeal(id);
  }

  Future<void> updateMeal(Meal meal, {File? newImageFile}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl = meal.imageUrl;

      if (newImageFile != null) {
        imageUrl = await _repository.uploadMealImage(newImageFile);
      }

      final updatedMeal = Meal(
        id: meal.id,
        date: meal.date, 
        time: meal.time,
        name: meal.name,
        calories: meal.calories,
        protein: meal.protein,
        fat: meal.fat,
        carbs: meal.carbs,
        ingredients: meal.ingredients,
        imageUrl: imageUrl,
      );

      await _repository.updateMeal(updatedMeal);
      
    } catch (e) {
      print("Помилка оновлення: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}