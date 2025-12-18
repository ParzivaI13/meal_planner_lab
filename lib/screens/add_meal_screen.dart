import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddMealScreen extends StatefulWidget {
  final Meal? mealToEdit;

  const AddMealScreen({super.key, this.mealToEdit});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  bool reminderEnabled = true;
  String selectedMealType = 'Сніданок';
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();
  File? _selectedImage; // Змінна для збереження вибраного файлу
  bool _isSaving = false; // Для індикатора завантаження

  // Метод вибору фото
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (_nameController.text.isEmpty || _caloriesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Будь ласка, заповніть назву та калорії'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final timeMap = {
      'Сніданок': '8:00',
      'Обід': '13:00',
      'Вечеря': '19:00',
      'Перекус': '16:00',
    };

    final Meal meal = Meal(
      id: widget.mealToEdit?.id ?? '', // Якщо редагуємо, зберігаємо ID
      time: '${selectedMealType.toUpperCase()} • ${timeMap[selectedMealType]}',
      name: _nameController.text,
      calories: '${_caloriesController.text} ккал',
      ingredients: _ingredientsController.text.trim(),
      imageUrl: widget
          .mealToEdit
          ?.imageUrl, // Передаємо старий URL, він оновиться в State якщо треба
    );

    // Повертаємо {'meal': meal, 'image': _selectedImage}
    Navigator.pop(context, {'meal': meal, 'image': _selectedImage});
  }

  @override
  void initState() {
    super.initState();
    if (widget.mealToEdit != null) {
      final meal = widget.mealToEdit!;
      _nameController.text = meal.name;
      _caloriesController.text = meal.calories.replaceAll(
        ' ккал',
        '',
      ); // Чистимо текст
      _ingredientsController.text = meal.ingredients;

      // Парсимо тип прийому їжі з рядка "СНІДАНОК • 8:00"
      final typePart = meal.time.split('•').first.trim();
      // Приводимо до формату Dropdown (Перша велика, інші малі)
      // Або просто зробимо switch/case, якщо формати відрізняються.
      // Для простоти припустимо, що в Dropdown значення 'Сніданок', а в базі 'СНІДАНОК'
      // Спробуємо знайти відповідність:
      if (typePart.contains('СНІД'))
        selectedMealType = 'Сніданок';
      else if (typePart.contains('ОБІД'))
        selectedMealType = 'Обід';
      else if (typePart.contains('ВЕЧЕР'))
        selectedMealType = 'Вечеря';
      else
        selectedMealType = 'Перекус';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6C757D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mealToEdit == null ? 'Додати страву' : 'Редагувати страву',
        ),
        actions: [
          TextButton(
            onPressed: _saveMeal,
            child: const Text(
              'Зберегти',
              style: TextStyle(
                color: Color(0xFF28a745),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                border: Border.all(color: const Color(0xFFDEE2E6), width: 2),
                borderRadius: BorderRadius.circular(12),
                // Якщо фото вибрано, показуємо його як фон
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : (widget.mealToEdit?.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(widget.mealToEdit!.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null),
              ),
              child: InkWell(
                onTap: _pickImage, // Викликаємо пікер
                child:
                    _selectedImage ==
                        null // Показуємо іконку тільки якщо фото немає
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📷', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 5),
                          Text(
                            'Додати фото',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
          // Показуємо лоадер, якщо йде збереження
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF28a745)),
              ),
            ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Назва страви',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _ingredientsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Інгредієнти',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Калорії',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE9ECEF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE9ECEF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedMealType,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE9ECEF),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE9ECEF),
                        width: 2,
                      ),
                    ),
                  ),
                  items: ['Сніданок', 'Обід', 'Вечеря', 'Перекус'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMealType = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(
              hintText: 'Дата та час',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFE9ECEF),
                  width: 2,
                ),
              ),
              suffixIcon: const Icon(
                Icons.calendar_today,
                color: Color(0xFF6C757D),
              ),
            ),
            readOnly: true,
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Нагадування',
                  style: TextStyle(fontSize: 16, color: Color(0xFF495057)),
                ),
                Switch(
                  value: reminderEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      reminderEnabled = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF28a745),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
