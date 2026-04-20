import 'package:flutter/material.dart';
import '../models/meal.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class AddMealScreen extends StatefulWidget {
  final Meal? mealToEdit;
  final DateTime? initialDate;

  const AddMealScreen({super.key, this.mealToEdit, this.initialDate});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool reminderEnabled = true;
  String selectedMealType = 'Сніданок';
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _caloriesController = TextEditingController();

  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  File? _selectedImage;
  bool _isSaving = false;
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedDate =
        widget.mealToEdit?.date ?? widget.initialDate ?? DateTime.now();

    if (widget.mealToEdit != null) {
      final meal = widget.mealToEdit!;
      _nameController.text = meal.name;
      _caloriesController.text = meal.calories.replaceAll(' ккал', '');
      _proteinController.text = meal.protein.replaceAll(' г', '');
      _fatController.text = meal.fat.replaceAll(' г', '');
      _carbsController.text = meal.carbs.replaceAll(' г', '');
      _ingredientsController.text = meal.ingredients;

      final typePart = meal.time.split('•').first.trim();
      if (typePart.contains('СНІД'))
        selectedMealType = 'Сніданок';
      else if (typePart.contains('ОБІД'))
        selectedMealType = 'Обід';
      else if (typePart.contains('ВЕЧЕР'))
        selectedMealType = 'Вечеря';
      else
        selectedMealType = 'Перекус';

      final timePart = meal.time.split('•').last.trim();
      final timeSegments = timePart.split(':');
      if (timeSegments.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(timeSegments[0]) ?? 8,
          minute: int.tryParse(timeSegments[1]) ?? 0,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF28a745)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF28a745)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ingredientsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  void _saveMeal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final Meal meal = Meal(
      id: widget.mealToEdit?.id ?? '',
      date: _selectedDate,
      time: '${selectedMealType.toUpperCase()} • $formattedTime',
      name: _nameController.text.trim(),
      calories: '${_caloriesController.text.trim()} ккал',
      protein: _proteinController.text.isNotEmpty
          ? '${_proteinController.text.trim()} г'
          : '0 г',
      fat: _fatController.text.isNotEmpty ? '${_fatController.text.trim()} г' : '0 г',
      carbs: _carbsController.text.isNotEmpty
          ? '${_carbsController.text.trim()} г'
          : '0 г',
      ingredients: _ingredientsController.text.trim(),
      imageUrl: widget.mealToEdit?.imageUrl,
    );
    
    final notificationId = meal.id.hashCode; 
    
    SharedPreferences.getInstance().then((prefs) {
      final globalPushEnabled = prefs.getBool('pushNotifications') ?? false;
      
      if (globalPushEnabled && reminderEnabled) {
        final scheduledTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        NotificationService().scheduleMealReminder(
          id: notificationId,
          title: 'Час для їжі! 🍽️',
          body: 'Заплановано: ${meal.name}',
          scheduledDate: scheduledTime,
        );
      } else {
        NotificationService().cancelReminder(notificationId);
      }
    });

    Navigator.pop(context, {'meal': meal, 'image': _selectedImage});
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
      body: Form(
        key: _formKey,
        child: ListView(
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
                  onTap: _pickImage,
                  child:
                      _selectedImage == null &&
                              widget.mealToEdit?.imageUrl == null
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
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF28a745)),
                ),
              ),
            const SizedBox(height: 30),
            
            TextFormField(
              controller: _nameController,
              decoration: _buildInputDecoration('Назва страви'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Будь ласка, введіть назву';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Калорії'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Обов\'язково';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Тільки числа';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMealType,
                    decoration: _buildInputDecoration(''),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Білки (г)'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Число';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _fatController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Жири (г)'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Число';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _carbsController,
                    keyboardType: TextInputType.number,
                    decoration: _buildInputDecoration('Вугл. (г)'),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                        return 'Число';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _ingredientsController,
              maxLines: 3,
              decoration: _buildInputDecoration('Інгредієнти'),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text:
                          '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: _buildInputDecoration('Дата').copyWith(
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(
                      text:
                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                    readOnly: true,
                    onTap: _selectTime,
                    decoration: _buildInputDecoration('Час').copyWith(
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF28a745), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC3545), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC3545), width: 2),
      ),
      errorStyle: const TextStyle(color: Color(0xFFDC3545), fontSize: 12),
    );
  }
}